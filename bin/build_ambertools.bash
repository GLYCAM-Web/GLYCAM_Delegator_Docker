#!/usr/bin/env bash

# USAGE: bash ./bin/install_ambertools.bash [ OPTIONS ]
#
# OPTIONS:
# 		-c :  Delete existing files before installing (clean).

source ./settings.bash
source ./etc/functions.bash

################################################################
##########               Print help message         ############
################################################################

printHelp()
{
    echo "*************************************************************"
	echo "This script is used to install a minimal AmberTools via Conda."
        echo "    See instructions here:  https://ambermd.org/GetAmber.php"
	printf "*************************************************************\n"
	printf "Options are as follows:\n"
	printf "\t-c\t\t\tClean all files from previous builds\n"
        printf "\t-h\t\t\tPrint this help message and exit\n"
        printf "*************************************************************\n"
	echo "Exiting."
	exit 1
}

CLEAN=""

################################################################
#########               COMMAND LINE INPUTS            #########
################################################################

while getopts "ch" option
do
    case "${option}" in
        c) 
		CLEAN="-c" 
		;; 
	h)
                printHelp
                ;;
	*)
                echo -e "${ERROR_STYLE}ERROR INCORRECT FLAG USED${RESET_STYLE}"
		printHelp
		;;
	esac
done

# First check to make sure the GLYCAM Delegator Docker Image is built.
# If not, we will just informt he user and exit.
does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}" || {  print_error_and_exit "ERROR IN ${0}, THE DELEGATOR DOCKER IMAGE DOESNT EXIST" ; }


#update our the command that will be used to actually compile the GEMS/gmml code
COMPILER_COMMAND="bash /installers/install_ambertools.bash ${CLEAN}"
export COMPILER_COMMAND

set -o pipefail
# Second, run docker compose up to compile everything.
DOCKER_COMMAND="docker compose --file ${DOCKER_COMPOSE_COMPILE_FILE} up --exit-code-from delegator"
( ${DOCKER_COMMAND} | grep -i --color=always -e '^' -e 'error.*' | GREP_COLOR='01;35' grep -i --color=always -e '^' -e 'warning.*' | GREP_COLOR='01;36' grep -i --color=always -e '^' -e 'note.*' ; ) || {  print_error_and_exit "ERROR UPPING COMPILE IMAGE IN COMPILE.SH" ; } 

# Third, once done compiling then run docker compose down.
DOCKER_COMMAND="docker compose --file ${DOCKER_COMPOSE_COMPILE_FILE} down"
( ${DOCKER_COMMAND} ) || {  print_error_and_exit "ERROR DOWNING COMPILE IMAGE IN COMPILE.SH" ; }

# EXIT_SUCCESS
exit 0
