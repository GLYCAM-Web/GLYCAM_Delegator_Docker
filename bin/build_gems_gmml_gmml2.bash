#!/usr/bin/env bash

# USAGE: bash ./bin/compile.bash [ OPTIONS ]
#
# OPTIONS:
# 		clean	Make sure to clean the repositories before compiling.

source ./settings.bash
source ./etc/functions.bash

################################################################
##########               Print help message         ############
################################################################

printHelp()
{
    echo "*************************************************************"
	echo "This script is used to both compile and wrap GMML & GMML2,"
	echo "and allow GEMS to use the compiled code."
	printf "*************************************************************\n"
	printf "Options are as follows:\n"
	printf "\t-c\t\t\tClean all files from previous builds\n"
	printf "\t-j <NUM_JOBS>\t\tPrepare GEMS and GMML/GMML2 with <NUM_JOBS>\n"
	printf "\t-o <O0/O2/OG/debug>\tBuild and wrap GMML/GMML2 using no optimization, 2nd \n\t\t\t\tlevel optimization, or with debug symbols\n"
    printf "\t-h\t\t\tPrint this help message and exit\n"
    printf "*************************************************************\n"
	echo "Exiting."
	exit 1
}

################################################################
#########                SET UP DEFAULTS               #########
################################################################
CLEAN=""
BUILD_LEVEL="O2"
COMPILE_JOBS=4


################################################################
#########               COMMAND LINE INPUTS            #########
################################################################

while getopts "j:o:ch" option
do
	case "${option}" in
			j)
				jIn="${OPTARG}"
				if [[ "${jIn}" =~ ^[1-9][0-9]*$ ]]; then
					COMPILE_JOBS="${jIn}"
				else
                    #peep etc/functions
                    optionsBorkedMsg "${option}" "badArg"
					printHelp
				fi
				;;
			o)
				oIn="${OPTARG}"
				if [ "${oIn}" == "O0" ] || [ "${oIn}" == "no_optimize" ]; then
					BUILD_LEVEL="O0"
				elif [ "${oIn}" == "O2" ] || [ "${oIn}" == "optimize" ]; then
					BUILD_LEVEL="O2"
				elif [ "${oIn}" == "debug" ] || [ "${oIn}" == "OG" ]; then
					BUILD_LEVEL="OG"
				else
                    optionsBorkedMsg "${option}" "badArg"
					printHelp
				fi
				;;
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

# First check to make sure the GRPC Delegator Docker Image is built.
# If not, we will just informt he user and exit.
does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}" || {  print_error_and_exit "ERROR IN COMPILE.SH, THE DELEGATOR DOCKER IMAGE DOESNT EXIST" ; }

if [ ! -d './deps/gems/External/MD_Utils/' ] ; then
	echo "It appears that you have not pulled in the submodules for this repo."
	echo "Please see the README.md file for information. Exiting."
	exit 1
fi


#update our the command that will be used to actually compile the GEMS/gmml code
COMPILER_COMMAND="cd /programs/gems && bash make.sh -j ${COMPILE_JOBS} -o ${BUILD_LEVEL} ${CLEAN}"
export COMPILER_COMMAND

# Second, run docker compose up to compile everything.
COMMAND="docker compose --file ${DOCKER_COMPOSE_COMPILE_FILE} up --exit-code-from delegator"
( ${COMMAND} ) || {  print_error_and_exit "ERROR UPPING COMPILE IMAGE IN COMPILE.SH" ; } 
#( ${COMMAND} | grep -i --color=always -e '^' -e 'error.*' | GREP_COLOR='01;35' grep -i --color=always -e '^' -e 'warning.*' | GREP_COLOR='01;36' grep -i --color=always -e '^' -e 'note.*' ; ) || {  print_error_and_exit "ERROR UPPING COMPILE IMAGE IN COMPILE.SH" ; } 

# Third, once done compiling then run docker compose down.
COMMAND="docker compose --file ${DOCKER_COMPOSE_COMPILE_FILE} down"
( ${COMMAND} ) || {  print_error_and_exit "ERROR DOWNING COMPILE IMAGE IN COMPILE.SH" ; }

# EXIT_SUCCESS
exit 0
