#!/usr/bin/env bash

echo "at top of GP output manager"
echo "the db output file name is >>>${dbOutputFile}<<<"
#echo "Top: RescueCycles is >>>${RescueCycles}<<<"
#echo "Top: MaxRescueCycles is >>>${MaxRescueCycles}<<<"

##
# This script is meant to be sourced as if it is source code.
# Many variables used in this script are defined in the caller script.
# Because this file is sourced, 'exit' should not be used unless all parent callers should also exit.
#
# Typically, the caller will be Generate_GlycoProtein_From_PDB_ID_+_Links_List
#
# Error codes that are assigned by this script (not counting any assigned by children of this script).
#
#     Error Brief                  Error Code      Fatal?
#     ----------------------------------------------------
#     JSON missing                 502             Y
#     JSON response incomplete     503             Y
#     Summary file missing         504             N
#     No PDB files produced        505             N
#     Some PDB files missing       506             N
#
# If the errors above are not found, then we assume that the process went approximately as planned.
# Checks for unplanned results will also occur.
# If non-fatal errors are found, further information might be found in error messages from child code.
# Where possible, this script will trigger checks for error messages from child code.
##  

##
# A few values that stay the same during a run:
#     project_id
#     uniprotkb_canonical_ac
#     pdb_id
#     pUUID  <--- this one cannot be known unless the JSON response is good
# Make these be one variable "Prefix" that only needs to be generated once per call

copy_or_log_error()
{
	# $1 is the source file
	# $2 is the destination file
	command="cp ${1} ${2} >> $LOGFILE 2>&1"
	eval "${command}"
	result="$?"
	if [ "${result}" != "0" ] ; then
		echo "[ERROR] : $(date) : Could not copy file >>>${1}<<< to its destination." >> $STATUSFILE
		echo """See output above. It results from trying to copy file:
	>>>${1}<<< 
to:
	>>>${2}<<<""" >> $LOGFILE
		Result="Failure to complete project"
       		Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
		Code="256"
		Brief="Copy Procedure Failed"
		Meaning="Could not copy a file or other asset as required."
		Text="Could not copy file >>>${1}<<< to the desired output location."
		Removed_Site=""
		Note="This is a failure. More information might follow."
       		echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		echo "error"
		return 
	fi
	echo "copy"
	return 
}

## 
# Source the file containing the error information
source /sysetc/GlycoProtein_GDD_Error_Dictionaries.bash

# Set some record keeping variables
#
NumberGoodPDBs="0"
NumberBadPDBs="0"
NumberMissingPDBs="0"
GoodPDBIndexes=()
BadPDBIndexes=()
MissingPDBIndexes=()
OutFileBase="${thisProjectID}"
OutFileBaseBare="${OutFileBase}"
if [ "${RescueResolvableSites}" == "True" ] ; then
	OutFileBase="${OutFileBase}_rescue"
fi

##
# Set a Prefix to use if the JSON response is bad
#
Prefix="${thisProjectID},${the_uniprotkb_canonical_ac},${the_pdb_id},unknown"
#echo "The Prefix is:"
#echo "${Prefix}"

GoodJSON="True"

echo "about to check JSON from GP output manager"

##
# Part 1 - check that the JSON response is present - fail if not
#
if [ ! -f "${jsonResponseFileName}" ] ; then
	Result="Fatal error"
        Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="502"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="Could not find the required file with this name: ${jsonResponseFileName}"
	Removed_Site=""
	Note="This is a fatal error for this build."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
        return
fi
# 
##

##
# Part 2 - check that the JSON response contains the needed information - fail if not

# Set code info for this error to be used if problems are found
Result="Fatal error"
Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
Code="503"
Brief="${Error_Briefs[${Code}]}"
Meaning="${Error_Meanings[${Code}]}"

# Given Name 
# this is the expected project_id:  ${thisProjectID}
command="grep givenName ${jsonResponseFileName} | cut -d '\"' -f 4"
project_id="$( eval ${command} )"
# expect 'null' if bad, but check for empty
if [ "${project_id}" == "null" ] || [ -z "${project_id}" ] ; then
	echo "Fatal error: grep result for givenName is null or empty: >>>${project_id}<<<" >> $LOGFILE
	Text="Could not find the givenName in this file: ${jsonResponseFileName}"
	Removed_Site=""
	Note="The givenName should be present and the same as the caller's project_id. This is a fatal error."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	project_id="missing"
	GoodJSON="False"
elif [ "${project_id}" != "${thisProjectID}" ] ; then
	echo "Fatal error: grep result for givenName is >>>${project_id}<<< which does not match >>>${thisProjectID}<<<" >> $LOGFILE
	Text="Unexpected givenName, >>>${project_id}<<<, in this file: ${jsonResponseFileName}"
	Removed_Site=""
	Note="The givenName should be >>>${thisProjectID}<<<. This is a fatal error."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	project_id="mismatched"
	GoodJSON="False"
fi

# PUUID 
command="grep -m1 pUUID ${jsonResponseFileName} | cut -d '\"' -f 4"
pUUID="$( eval ${command} )"
# expect empty if bad
if [ "${pUUID}" == "null" ] || [ -z "${pUUID}" ] ; then
	echo "Fatal error: grep result for pUUID is >>>${pUUID}<<<" >> $LOGFILE
	Text="Could not find the pUUID in this file: ${jsonResponseFileName}"
	Removed_Site=""
	Note="The pUUID must be present in the JSON response. This is a fatal error."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	pUUID="missing"
	GoodJSON="False"
fi

# Project Directory 
command="grep project_dir ${jsonResponseFileName} | cut -d '\"' -f 4"
projectDir="$( eval ${command} )"
# expect empty if bad
if [ "${projectDir}" == "null" ] || [ -z "${projectDir}" ] ; then
	echo "Fatal error: grep result for project_dir is >>>${projectDir}<<<" >> $LOGFILE
	Text="Could not find the project directory in this file: ${jsonResponseFileName}"
	Removed_Site=""
	Note="The project_dir must be present in the JSON response. This is a fatal error."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	projectDir="missing"
	GoodJSON="False"
fi

# See if there is any other useful information available
# if any of the above have happened, check JSON for notices and spew to the status & log files if present
if [ "${GoodJSON}" == "False" ] ; then
	echo "[ERROR] : $(date) : Something went wrong generating PDB files for project_id=${thisProjectID}" >> $STATUSFILE
	echo "[INFO] : $(date) : Attempting to determine cause of issue with project_id=${thisProjectID}" >> $STATUSFILE
	echo "Checking for notices related to failure of project_id=${thisProjectID}" >> $LOGFILE
	command="grep -m1 '\"brief\":' ${jsonResponseFileName} | cut -d '\"' -f 4"
	brief="$( eval ${command} )"
       	if [ ! -z "${brief}" ] ; then
		Result="Failure: ${brief}"
		echo "Found a notice brief: ${brief}" >> $LOGFILE
	else
		Result="Failure: unspecified reason"
		echo "Could not find a notice brief." >> $LOGFILE
	fi
	###     - Set the Note to '"message":' or to hint or to the filename
	command="grep -m1 '\"message\":' ${jsonResponseFileName} | cut -d '\"' -f 4"
	message="$( eval ${command} )"
       	if [ ! -z "${message}" ] ; then
		Note="${message}"
		echo "Found a notice message: ${message}" >> $LOGFILE
	else
		echo "Could not find a notice message." >> $LOGFILE
	fi
	command="grep -m1 '\"hint\":' ${jsonResponseFileName} | cut -d '\"' -f 4"
	hint="$( eval ${command} )"
       	if [ ! -z "${hint}" ] ; then
		Note="${Note}; Hint: ${hint}"
		echo "Found a notice hint: ${hint}" >> $LOGFILE
	else
		echo "Could not find a notice hint." >> $LOGFILE
	fi
       	if [ -z "${Note}" ] ; then
		echo "Could not find information." >> $LOGFILE
		echo "Please see JSON Response: ${jsonResponseFileName}" >> $LOGFILE
		Note="See ${jsonResponseFileName}"
	fi
	# set a final error message and return
	Result="Fatal error"
        Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="503"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="One or more problems found with the JSON response"
	Removed_Site=""
	Note="This is a fatal error. This file might contain additional information if it exists: ${LOGFILE} "
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	return
fi
#
##



##
# Number of Samples - ok if missing, but need to check.
#
command="grep number_of_samples ${jsonResponseFileName} | cut -d '\"' -f 4"
numberSamples="$( eval ${command} )"
# if empty, assume the default, which is 1
if [ "${numberSamples}" == "null" ] || [ -z "${numberSamples}" ] ; then
	echo "Number of samples not determined, assuming the default value of 1." >> $LOGFILE
	echo "[INFO] : $(date) : Number of samples assumed to be 1." >> $STATUSFILE
	Result="General information"
        Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="-1"
	Brief="Set Value To Default"
	Meaning="An expected value was not found so was set to its default."
	Text="Setting number of samples to one because not set in this file: ${jsonResponseFileName}"
	Removed_Site=""
	Note="Providing a number of samples recommended but is not strictly necessary."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	numberSamples="1"
elif  [[ ! "${numberSamples}" =~ ^[0-9]+$ ]] ; then
        echo "The requested number of samples is not a positive integer." >> $LOGFILE
        echo "This situation is very unexpected. Something is probably very wrong." >> $LOGFILE
        echo "[WARNING] : $(date) : Number of samples is not a positive integer." >> $STATUSFILE
        echo "[WARNING] : $(date) : Setting number of samples to zero." >> $STATUSFILE
	Result="Unexpected entry"
        Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="507"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="The number of samples is not an integer. It is >>>${numberSamples}<<< See: ${jsonResponseFileName}"
	Removed_Site=""
	Note="Setting the number to one. This might cause problems later."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	numberSamples="1"
fi
#
###

##
# Set a Prefix to use now that the pUUID is known and the project_id is known to be sane
#
Prefix="${project_id},${the_uniprotkb_canonical_ac},${the_pdb_id},${pUUID}"
#echo "The Prefix is now:"
#echo "${Prefix}"
#
###
#
echo "about to check summary file in GP output manager"

##
# Part 3 - if no summary.txt file is present, complain but proceed
#          if it is present, copy it over
#
if [ ! -f "${projectDir}/outputs/summary.txt" ] ; then
	echo "[Error] : $(date) : Cannot find summary.txt for project_id=${thisProjectID}." >> $STATUSFILE
	echo "Summary file missing. Pressing on, but not optimistic." >> $LOGFILE
	# set an error message and see what else there is
	Result="Failure to complete project"
        Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="504"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="Could not find file >>>${projectDir}/outputs/summary.txt<<<."
	Removed_Site=""
	Note="This is not a good sign but we will look for other outputs/information."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
else
	From_File="${projectDir}/outputs/summary.txt"
	To_File="${SummariesDir}/${OutFileBase}_summary.txt"
	result="$(copy_or_log_error ${From_File} ${To_File})"
fi
#
###
	
echo "about to check PDB Files in GP output manager"
##
# Part 4 -  if no PDB files can be found, report "Failure to complete project" code 505
# Part 5 -  if some PDB files are missing, report this error as "Anomalous project completion" code 506
#
# Regardless of the two above, if any appropriate PDB file was generated, give a code "0" and a "PDB successfully generated"
#
# If no PDB file was resolved, give a "Finished normally" with a "0" code. Also give a 500 with "No resolved PDB found".
#     - Save a list of all 'rejected' sites to error notices
#       - Here, we check across ALL attempts. For now, if a site fails at any time, we will not consider it.
#       - Later versions can make other attempts. This method maximizes chances for success.
#     - Save any remaining sites to glycositeResolvedData and set RescueResolvableSites="True"
#       - It is up to the parent to decide what to do with the information.
#     - If no sites always resolved, then give another 500 with "No sites consistently resolved".
#     
# Check the output, copying over the relevant files as needed.
#
# At the end, based on the counts of PDB files found, leave messages and/or errors
#
# Checking for the expected number of PDBs varies for number of samples requested.
#
#   Files/paths are relative to the outputs/ directory.
#
#   numberSamples  :  Check for this
#   ---------------------------------------------------------------------------------
#    0             :  default.pdb 
#
#    1             :  samples/glycoprotein.pdb (good) 
#                  :  samples/rejected/glycoprotein.pdb (bad)
#
#    2+            :  samples/N_glycoprotein.pdb (good) 
#                  :  samples/rejected/N_glycoprotein.pdb (bad)
#                  :  0 -le N -lt numberSamples
#

#echo "checking on number of samples"
if [ "${numberSamples}" -eq "0" ] ; then 
#	echo "is number of samples 0 ?"
	From_File="${projectDir}/outputs/default.pdb"
	To_File="${GoodPdbDir}/${OutFileBaseBare}.pdb"
	if [ -f "${From_File}" ] ; then
		result="$(copy_or_log_error ${From_File} ${To_File})"
		if [ "${result}" == "copy" ] ; then
			NumberGoodPDBs="1"
			GoodPDBIndexes+=("0")
		fi
	else
		Result="Failure to complete project"
        	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
		Code="505"
		Brief="${Error_Briefs[${Code}]}"
		Meaning="${Error_Meanings[${Code}]}"
		Text="Could not find file >>>${From_File}<<<."
		Removed_Site=""
		Note="This is a failure. More information might follow."
        	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	fi
elif [ "${numberSamples}" -eq "1" ] ; then 
#	echo "is number of samples 1 ?"
	Good_From_File="${projectDir}/outputs/samples/glycoprotein.pdb"
	Good_To_File="${GoodPdbDir}/${OutFileBaseBare}.pdb"
	Bad_From_File="${projectDir}/outputs/samples/rejected/glycoprotein.pdb"
	Bad_To_File="${BadPdbDir}/${OutFileBase}.pdb"
	if [ -f "${Good_From_File}" ] ; then
		result="$(copy_or_log_error ${Good_From_File} ${Good_To_File})"
		if [ "${result}" == "copy" ] ; then
			NumberGoodPDBs="1"
			GoodPDBIndexes+=("0")
		fi
	elif [ -f "${Bad_From_File}" ] ; then
		result="$(copy_or_log_error ${Good_From_File} ${Good_To_File})"
		if [ "${result}" == "copy" ] ; then
			NumberBadPDBs="1"
			BadPDBIndexes+=("0")
		fi
	else
		Result="Failure to complete project"
        	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
		Code="505"
		Brief="${Error_Briefs[${Code}]}"
		Meaning="${Error_Meanings[${Code}]}"
		Text="Could not find glycoprotein.pdb."
		Removed_Site=""
		Note="This is a failure. More information might follow."
        	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	fi

else 
#	echo "is number of samples -gt 1 ?"
	counter="0"
	goodCopied="False"
	while [ "${counter}" -lt "${numberSamples}" ] ; do
#		echo "the counter is ${counter}"
		From_GP_Name="${counter}_glycoprotein.pdb"
		Sample_GP_Name="${OutFileBase}_${counter}.pdb"
		Good_From_File="${projectDir}/outputs/samples/${From_GP_Name}"
		Bad_From_File="${projectDir}/outputs/samples/rejected/${From_GP_Name}"
		Good_Samples_To_File="${GoodPdbDir}/all_samples/${Sample_GP_Name}"
		Bad_To_File="${SamplesBadPdbDir}/${Sample_GP_Name}"
		if [ -f "${Good_From_File}" ] ; then
#			echo "we found a good 'from' file"
			result="$(copy_or_log_error ${Good_From_File} ${Good_Samples_To_File})"
			if [ "${result}" == "copy" ] ; then
				NumberGoodPDBs="$((NumberGoodPDBs+1))"
				GoodPDBIndexes+=("${counter}")
			fi
			if [ "${goodCopied}" == "False" ] ; then
				Good_Default_To_File="${GoodPdbDir}/${OutFileBaseBare}.pdb"
				result="$(copy_or_log_error ${Good_From_File} ${Good_Default_To_File})"
				if [ "${result}" == "copy" ] ; then
					goodCopied="True"
				else
					goodCopied="Error"
				fi
			fi
		elif [ -f "${Bad_From_File}" ] ; then
#			echo "we found a bad 'from' file"
			result="$(copy_or_log_error ${Bad_From_File} ${Bad_To_File})"
			if [ "${result}" == "copy" ] ; then
				NumberBadPDBs="$((NumberBadPDBs+1))"
				BadPDBIndexes+=("${counter}")
			fi
		else
#			echo "the file is missing"
			NumberMissingPDBs="$((NumberMissingPDBs+1))"
			MissingPDBIndexes+=("${counter}")
		fi
		counter="$((counter+1))"
	done

fi

numExpectedPDBs="${numberSamples}"
if [ "${numExpectedPDBs}" -eq "0" ] ; then
	numExpectedPDBs="1"
fi
totalPDBs="$((NumberGoodPDBs+NumberBadPDBs))"
echo "the total number of PDBs produced, good or bad, is: ${totalPDBs}"

# Message if all of the requested PDBs were not produced (resolved or not)
if [ "${totalPDBs}" -eq "0" ] ; then
	Result="Failure to complete project"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="505"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="None of the ${numberExpectedPDBs} were generated at all, resolved or not."
	Removed_Site=""
	Note="This is a fatal error for this build."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
elif [ "${totalPDBs}" -lt "${numExpectedPDBs}" ] ; then
	Result="Failure to complete project"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="506"
	Brief="${Error_Briefs[${Code}]}"
	Text="Only ${totalPDBs} of the ${numberExpectedPDBs} were generated at all (resolved or not)."
	Meaning="${Error_Meanings[${Code}]}"
	Removed_Site=""
	Note="Check any 'resolved' PDB file carefully."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
elif [ "${totalPDBs}" -gt "${numExpectedPDBs}" ] ; then
	Result="Failure to complete project"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="501"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="Only ${numberExpectedPDBs} were requested, but ${totalPDBs} were produced. Something went wrong."
	Removed_Site=""
	Note="Check any 'resolved' PDB file carefully."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
else
	# Messages for resolved structures
#	echo "the number of pdbs matches the number expected?"
	if [ "${NumberGoodPDBs}" -gt "0" ] ; then
#		echo "num good is ${NumberGoodPDBs} num expected is ${numExpectedPDBs}"
		if [ "${NumberGoodPDBs}" -eq "${numExpectedPDBs}" ] ; then
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="0"
			Brief="-"
			Meaning="-"
			Text="All requested samples resolved."
			Removed_Site=""
			Note="-"
#			echo "about to write to the db"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		else
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="-1"
			Brief="General Information"
			Meaning="-"
			Text="${NumberGoodPDBs} of the requested samples resolved."
			Removed_Site=""
			Note="-"
#			echo "about to write to the db"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		fi
	# Messages for unresolved structures
	elif [ "${NumberBadPDBs}" -gt "0" ] ; then
#		echo "num bad is ${NumberBadPDBs} num expected is ${numExpectedPDBs}"
		if [ "${NumberBadPDBs}" -eq "${numExpectedPDBs}" ] ; then
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="500"
			Brief="${Error_Briefs[${Code}]}"
			Meaning="${Error_Meanings[${Code}]}"
			Text="All of the requested samples generated rejected PDB files."
			Removed_Site=""
			Note="-"
#			echo "about to write to the db"
echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
			## Consider rescuing if possible
			RescueResolvableSites="True"
		else
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="-1"
			Brief="General Information"
			Meaning="-"
			Text="${NumberBadPDBs} of the ${numberExpectedPDBs} requested samples generated rejected PDB files."
			Removed_Site=""
			Note="-"
#			echo "about to write to the db"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		fi
	fi
fi

##
# Integrate any GMML2 errors 
#
# Set the I/O
the_error_db_file="/sysetc/GlycoProtein_GMML2_Error_Dictionaries.bash"
Read_From="${projectDir}/gpBuilder.log"
Write_To="${dbOutputFile}"
#
# Call the parser and store the result in a mapfile
mapfile -t error_data < <( /sysetc/parse_error_log.bash \
"${the_error_db_file}" \
"${Read_From}" \
"${Write_To}" \
2>> "${Write_To}.stderr" )
#
# Check to see if the process failed altogether
script_exit_code="${PIPESTATUS[0]}"
#
# If the process failed, do something sensible
if (( script_exit_code != 0 )); then
	echo "Error parsing script (/sysetc/parse_error_log.bash) failed with exit code: $script_exit_code"
	echo "If any error message (from the script) was returned it will be found here:"
	echo "${Write_To}.stderr"
fi
#
# If there are no errors to report, return to the parent
number_of_errors="${error_data[0]}"
echo "The number of errors is: >>>${number_of_errors}<<<"
if [ "${number_of_errors}" -eq "0" ] ; then
	echo "There are no GMML2 errors to report." >> $LOGFILE
	echo "[INFO] : $(date) : There are no GMML2 errors to report." >> $STATUSFILE
else
	echo "There are ${number_of_errors} GMML2 errors to report." >> $LOGFILE
	echo "[WARNING] : $(date) : There are ${number_of_errors} GMML2 errors to report." >> $STATUSFILE
	echo "[WARNING] : $(date) : See $LOGFILE for details.." >> $STATUSFILE
	# 
	# Set some values that won't change
	Result="Reporting GMML2 Errors"
	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Removed_Site=""
	Note="More info can be found in the docs folder and the project directory: ${projectDir}. See particularly gpBuilder.log and gpBuilder.err"
	#
	# Loop through the other errors and save them as needed.
	counter="0"
	while [ "${counter}" -lt "${number_of_errors}" ] ; do
		count_base="$((4*counter))"
		Code="${error_data["$((count_base+1))"]}"
		Brief="${error_data["$((count_base+2))"]}"
		Meaning="${error_data["$((count_base+3))"]}"
		Text="${error_data["$((count_base+4))"]}"
       		echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		counter="$((counter+1))"
	done
fi

#echo "about to see about rescuing the build in GP output manager"
# NumberGoodPDBs="0"
# NumberBadPDBs="0"
# NumberMissingPDBs="0"
# GoodPDBIndexes=()
# BadPDBIndexes=()
# MissingPDBIndexes=()
# OutFileBase="${project_id}"
# OutFileBaseBare="${OutFileBase}"
# if [ "${RescueResolvableSites}" == "True" ] ; then
	# OutFileBase="${OutFileBase}_rescue"
# fi

## 
if [ "${RescueResolvableSites}" == "True" ] ; then
if [ "${RescueCycles}" -ge "${MaxRescueCycles}" ] ; then
	RescueResolvableSites="False"
#	Result="Maximum Rescue Tries Reached"
#	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
#	Code="-1"
#	Brief="General Information"
#	Meaning="-"
#	Text="The maximum allowed rescue attempts, ${MaxRescueCycles}, has been reached."
#	Removed_Site="-"
#	Note="-"
#	echo "about to write to the db"
#	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
fi
fi
# If there were no resolved PDB files build a list to be used by the parent
if [ "${RescueResolvableSites}" == "True" ] ; then
	File="${SummariesDir}/${OutFileBase}_summary.txt"
	if [ ! -f "${File}" ] ; then
		Result="Failure to rescue resolved sites"
       		Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
		Code="504"
		Brief="${Error_Briefs[${Code}]}"
		Meaning="${Error_Meanings[${Code}]}"
		Text="The file >>>${File}<<< could not be found."
		Removed_Site=""
		Note="The summary file contains rejected glycosite information."
       		echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		RescueResolvableSites="False"
	else
		COM="grep rejected ${File} | sed 's/   /,/g' | tr -s ',' | cut -d ',' -f4 | tr -s ' ' | tr ' ' '\\n' | sort | grep -v \"^$\""
		all_the_Sites=( $( eval "${COM}" ) )
		echo "all the Sites is : >>>${all_the_Sites[@]}<<<"
# original was:	COM="grep rejected ${File} | sed 's/   /,/g' | tr -s ',' | cut -d ',' -f4 | tr -s ' ' | tr ' ' '\\n' | sort | uniq | grep -v \"^$\""
		mapfile -t the_uniq_Sites< <(printf "%s\n" "${all_the_Sites[@]}" | sort -u)
		#the_uniq_Sites=( $( uniq <<< "${all_the_Sites[@]}"  ) )
		echo "the uniq Sites is : >>>${the_uniq_Sites[@]}<<<"
		numRejected="${#the_uniq_Sites[@]}"
		echo "there were ${sitecount} requested sites." >> $LOGFILE
		echo "there are ${numRejected} rejected sites. They are:" >> $LOGFILE
		echo "${the_uniq_Sites[@]}" >> $LOGFILE
		if [ "${numRejected}" -eq "${sitecount}" ] ; then
			Result="Failure to rescue resolved sites"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="508"
			Brief="${Error_Briefs[${Code}]}"
			Meaning="${Error_Meanings[${Code}]}"
			Text="There are no sites that resolved in every sample."
			Removed_Site=""
			Note="The number of rejected sites (${numRejected}) is the same as the number in the original request."
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
			Result="Failure to rescue resolve sites"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="509"
			Brief="${Error_Briefs[${Code}]}"
			Meaning="${Error_Meanings[${Code}]}"
			Text="It is not possible to rescue this build using the given constraints."
			Removed_Site=""
			Note="Request more samples or relax the number of resolved samples required per site."
			### ! the second suggestion in the Note above will require code changes.
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
			RescueResolvableSites="False"
		fi
	fi
fi
##
# If the rescue attempt passed the tests in the last block, try to rescue the build
#
if [ "${RescueResolvableSites}" == "True" ] ; then
	RescueCycles="$(( RescueCycles+1 ))"
	numGood="$(( sitecount - numRejected  ))"
	Result="Attempting Rescue"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="-1"
	Brief="General Information"
	Meaning="-"
	Text="Attempting to rescue the build using sites that resolved in every sample."
	Removed_Site=""
	Note="The number of the of the original ${sitecount} sites that are eligible for rescue is: ${numGood}."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	i="0"
	newNum="0"
	declare -A newList
	declare -A newSites
	##
	# The following is an all-to-all search. There is probably a faster way. Feel free to implement it.
	while [ "${i}" -lt "${sitecount}" ] ; do
		sitematch="No"
		# if this glycositeDataList entry contains the Chain, Residue Number and Insertion Code 
		# for any of the rejected sites, then remove it from the array.
		for site in ${the_uniq_Sites[@]} ; do
			IFS='_' read -r chain resNum IC <<< "$site"
			match="Yes"
			if [[ ${glycositeDataList[$i]} !=  *"\"Chain\": \"${chain}\""* ]] ; then
				match="No"
			fi
			if [[ ${glycositeDataList[$i]} !=  *"\"ResidueNumber\": \"${resNum}\""* ]] ; then
				match="No"
			fi
			if [[ ${glycositeDataList[$i]} !=  *"\"InsertionCode\": \"${IC}\""* ]] ; then
				match="No"
			fi
			if [ "${match}" == "Yes" ] ; then
				sitematch="Yes"
				the_match="${site}"
			fi
	        done
		if [ "${sitematch}" == "Yes" ] ; then
			number_Fails="$(grep -o "${the_match}" <<< "${all_the_Sites[@]}" | wc -l)"
			Result="Attempting Rescue"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="-1"
			Brief="General Information"
			Meaning="-"
			Text="Removing failed site."
			Removed_Site="${the_match}"
			Note="Failed in this many samples: ${number_Fails}"
echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		else
			newList[${newNum}]="${glycositeDataList[$i]}"
			newSites[${newNum}]="${the_match}"
			newNum="$(( newNum+1 ))"
		fi
                i="$((i+1))"
        done
	echo "Copying the resolved glycosite information to the glycositeDataList." >> $LOGFILE
#	unset -v glycositeDataList
#	declare -A glycositeDataList
#	for key in "${!newList[@]}" ; do
#   	     glycositeDataList["${key}"]="${newList["${key}"]}"
#        done

#	echo "Bottom: RescueCycles is >>>${RescueCycles}<<<"
#	echo "Bottom: MaxRescueCycles is >>>${MaxRescueCycles}<<<"
#	echo "sitecount is ${sitecount} and newNum is ${newNum} (they should NOT be equal)"
#	echo "newList is:"
#	echo "${newList[@]}"
	i=0
	while [ "${i}" -lt "${sitecount}" ] ; do
		if [ "${i}" -lt "${newNum}" ] ; then
#			echo "setting glycositeDataList[${i}] to >>>${newList[${i}]}"
			glycositeDataList[${i}]="${newList[${i}]}"
		else
#			echo "unsetting glycositeDataList[${i}]"
			unset -v "glycositeDataList[${i}]"
		fi
		i="$((i+1))"
	done
	sitecount="${newNum}"
#	echo "sitecount is ${sitecount} and newNum is ${newNum} (they should be equal)"
#	echo "glycositeDataList is :"
#	echo "${glycositeDataList[@]}"
	##
	## Leave a note about the site(s) that passed
	Result="Attempting Rescue"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="-1"
	Brief="General Information"
	Meaning="-"
	Text="List of sites for rescue attempt."
	Removed_Site="-"
	Note="${newSites[@]}"
	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	##
	export glycositeDataList
	process_the_build
fi
# Close the rescue attempt
##

