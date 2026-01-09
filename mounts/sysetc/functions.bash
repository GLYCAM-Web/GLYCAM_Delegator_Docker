#!/usr/bin/env bash

#  variable_is_empty VARIABLE
variable_is_empty() {
        if [ "${1}zzz" == "zzz" ] ; then
                true
        else
                false
        fi
}

check_make_directory() {
        if variable_is_empty ${1} ; then
                print_error_and_exit "You must provide a directory name to check_make_directory."
        fi
        if [ -e ${1} ] && [ ! -d ${1} ] ; then
                print_error_and_exit "check_make_directory: Non-directory entity already exists with name ${1}."
        fi
        if [ ! -d ${1} ] ; then
                mkdir -p ${1}
        fi
}

# print_error_and_exit_failure [ ${ERROR} ]
print_error_and_exit() {
        if variable_is_empty ${1} ; then
                echo "There seems to have been a problem. See the output above for details. Exiting..."
        else
                echo "${1}"
        fi
        exit 1
}

does_image_exist() {
        if [ "$( docker images --format {{.Repository}}:{{.Tag}} | grep -c ${1} )" -eq "0" ]; then
                return 1
        fi
        return 0
}

# run command and log results
rclr()
{
	DoingWhat="${1}"  # Descriptive statement about what COM does, e.g., "Setting up cluster-side networking interface"
	COM="${2}" # The command to run
	DidWhat="${3}" # Brief title for what should have happened, e.g., "Cluster networking setup"

        echo "${DoingWhat} " >> ${LOGFILE}
	echo "The command(s) to be used: ${COM}"  >> ${LOGFILE}
	if [ "${TEST}" == "True" ] ; then
		echo "TEST is set to True. ${DidWhat} was not run." >> ${LOGFILE}
                echo "[INFO] : $(date) : ${DidWhat} was not run due to TEST=True" >> ${STATUSFILE}
	else
        	eval "${COM}" >> ${LOGFILE} 2>&1
        	returnVal=$?

        	if [ "${returnVal}" != "0" ] ; then
                	echo "...${DidWhat} failed with code ${returnVal}.  Exiting" >> ${LOGFILE}
                	echo "[ERROR] : $(date) : ${DidWhat} failed with code ${returnVal}" >> ${STATUSFILE}
                	exit 1
        	else
                	echo "...${DidWhat} completed on $(date)" >> ${LOGFILE}
                	echo "[INFO] : $(date) : ${DidWhat} completed" >> ${STATUSFILE}
        	fi
	fi
}

## Define the function that will check for preexistence of PDB file,
##
### - PDB files : /outputs/conjugate/gp/${OUT_SUBDIR}/ <-- this is the OutputDir
### - If file exists
### - Check if OVERWRITE_OUTPUT==True (env or settings)
### - Write messages to detailed log file and respond accordingly
generate_new_pdb_file() {
        # $1 is the directory where the file should be (OutputDir)
        # $2 is the Basename for the PDB file
	# $LOGFILE must be defined by the calling script
        if [ -e "${1}/${2}.pdb" ] ; then
                echo "Found existing file '${1}/${2}.pdb'" >> ${LOGFILE}
                if [ "${OVERWRITE_OUTPUT}" == "True" ] ; then
                        echo "Overwriting existing file" >> ${LOGFILE}
                        return 0
                else
                        echo "Not overwriting existing file" >> ${LOGFILE}
                        return 1
                fi
        else
                echo "Attempting to create brand-new file '${1}/${2}.pdb'" >> ${LOGFILE}
                return 0
        fi
}

