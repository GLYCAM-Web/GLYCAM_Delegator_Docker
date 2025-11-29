#!/usr/bin/env bash

source ./settings.sh
source ./etc/functions.sh

#########################################
#		     Ensure Directories				#
#########################################
DelegatorDirectories=(
	./env/
	./logs/
	../Web_Data/userdata/
	)
for directory in ${DelegatorDirectories[@]} ; do
	check_make_directory ${directory}
done

#########################################
#			Delegator Setup				#
#########################################
echo """${FILE_MESSAGE}
GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
GEMS_LOGGING_LEVEL=${GEMS_LOGGING_LEVEL}
GEMS_FORCE_SERIAL_EXECUTION=${GEMS_FORCE_SERIAL_EXECUTION}
GEMS_MD_TEST_WORKFLOW=${GEMS_MD_TEST_WORKFLOW}
""" > ${DELEGATOR_ENV_FILE}


# EXIT_SUCESS
exit 0
