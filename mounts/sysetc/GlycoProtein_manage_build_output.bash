#!/usr/bin/env bash

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
		return "error"
	fi
	return "copy"
}

## 
# Source the file containing the error information
source /sysetc/GlycoProtein_GDD_Error_Dictionaries.bash

##
# Set a Prefix to use if the JSON response is bad
#
Prefix="${thisProjectID},${uniprotkb_canonical_ac},${pdb_id},unknown"

GoodJSON="True"

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
	Note="Providing a number of samples is not strictly necessary, but recommended."
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
	Note="Setting the number to one. If problems happen later, this might be why."
        echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	numberSamples="1"
fi
#
###

##
# Set a Prefix to use now that the pUUID is known and the project_id is known to be sane
#
Prefix="${project_id},${uniprotkb_canonical_ac},${pdb_id},${pUUID}"
#
###

##
# Part 3 - if no summary.txt file is present, complain but proceed
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
fi
#
###
	
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

# Set some record keeping variables
#
NumberGoodPDBs="0"
NumberBadPDBs="0"
NumberMissingPDBs="0"
GoodPDBIndexes=()
BadPDBIndexes=()
MissingPDBIndexes=()
OutFileBase="${project_id}"
OutFileBaseBare="${OutFileBase}"
if [ "${RescueResolvableSites}" == "True" ] ; then
	OutFileBase="${OutFileBase}_rescue"
fi

if [ "${numberSamples}" -eq "0" ] ; then 
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
	counter="0"
	goodCopied="False"
	while [ "${counter}" -lt "${numberSamples}" ] ; do
		From_GP_Name="${counter}_glycoprotein.pdb"
		Sample_GP_Name="${OutFileBase}_${counter}.pdb"
		Good_From_File="${projectDir}/outputs/samples/${From_GP_Name}"
		Bad_From_File="${projectDir}/outputs/samples/rejected/${From_GP_Name}"
		Good_Samples_To_File="${GoodPdbDir}/${Sample_GP_Name}"
		Bad_To_File="${SamplesBadPdbDir}/${Sample_GP_Name}"
		if [ -f "${Good_From_File}" ] ; then
			result="$(copy_or_log_error ${Good_From_File} ${Good_Samples_To_File})"
			if [ "${result}" == "copy" ] ; then
				NumberGoodPDBs="$((NumberGoodPDbs+1))"
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
			result="$(copy_or_log_error ${Bad_From_File} ${Bad_To_File})"
			if [ "${result}" == "copy" ] ; then
				NumberBadPDBs="$((NumberBadPDbs+1))"
				BadPDBIndexes+=("${counter}")
			fi
		else
			NumberMissingPDBs="$((NumberMissingPDbs+1))"
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
	Note="If you got a 'resolved' PDB file, you should check it carefully."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
elif [ "${totalPDBs}" -ge "${numExpectedPDBs}" ] ; then
	Result="Failure to complete project"
       	Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
	Code="501"
	Brief="${Error_Briefs[${Code}]}"
	Meaning="${Error_Meanings[${Code}]}"
	Text="Only ${numberExpectedPDBs} were requested, but ${totalPDBs} were produced. Something went wrong."
	Removed_Site=""
	Note="If you got a 'resolved' PDB file, you should check it carefully."
       	echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
else
	# Messages for resolved structures
	if [ "${NumberGoodPDBs}" -gt "0" ] ; then
		if [ "${NumberGoodPDBs}" -eq "${numExpectedPDBs}" ] ; then
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="0"
			Brief="-"
			Meaning="-"
			Text="All requested samples resolved."
			Removed_Site=""
			Note="-"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		else
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="-1"
			Brief="-"
			Meaning="-"
			Text="${NumberGoodPDBs} of the requested samples resolved."
			Removed_Site=""
			Note="-"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
		fi
	# Messages for unresolved structures
	elif [ "${NumberBadPDBs}" -gt "0" ] ; then
		if [ "${NumberBadPDBs}" -eq "${numExpectedPDBs}" ] ; then
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="500"
			Brief="${Error_Briefs[${Code}]}"
			Meaning="${Error_Meanings[${Code}]}"
			Text="All of the requested samples generated rejected PDB files."
			Removed_Site=""
			Note="If any of the individual sites resolved in each sample, there wil be another try."
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
			RescueResolvableSites="True"
		else
			Result="Finished normally"
       			Date_Time="$(date +\"%Y-%m-%d_%H:%M:%S\")"
			Code="-1"
			Brief="-"
			Meaning="-"
			Text="${NumberBadPDBs} of the ${numberExpectedPDBs} requested samples generated rejected PDB files."
			Removed_Site=""
			Note="-"
       			echo "${Prefix},${Result},${Date_Time},${Code},${Brief},${Meaning},${Text},${Removed_Site},${Note}" >> "${dbOutputFile}"
	fi
fi

if [ "${RescueResolvableSites}" == "True" ] ; then
If there were no resolved PDB files build a list to be used by the parent
fi

##
# Integrate any GMML2 errors 
# See the top of the gmml2 errors DB for instructions
