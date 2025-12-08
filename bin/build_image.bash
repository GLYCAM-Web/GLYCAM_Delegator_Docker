#!/usr/bin/env bash

################################################################
#########                SET UP DEFAULTS               #########
################################################################

# Number of processors to use during compiles
BUILD_PROCS=4

################################################################
##########               Print help message         ############
################################################################

printHelp()
{
    echo ""
    echo "Right now the only thing that $0 can take in is number of jobs."
    echo "There may be some other things we want to add in the future but"
    echo "that will happen when the time comes. Number of jobs is important"
    echo "because we build swig from source."
    echo ""
    echo "*************************************************************"
    printf "Options are as follows:\n"
    printf "\t-j <NUM_JOBS>\t\tCompile our code with <NUM_JOBS>\n"
    echo "*************************************************************"
    echo ""
    echo "Exiting"
    exit 1
}

################################################################
#########               COMMAND LINE INPUTS            #########
################################################################

while getopts "j:h" option
do
    case "$option" in
        j)
            jIn=${OPTARG}
            if [[ ${jIn} =~ ^[0-9]+$ ]]; then
                BUILD_PROCS=${jIn}
            else
                printHelp
            fi
        ;;
        h)
            printHelp
        ;;
        *)
            printHelp
        ;;
    esac
done


source ./settings.bash
source ./etc/functions.bash

#if ! bash ./bin/setup.bash; then
#	print_error_and_exit "Something happened when running the setup.bash script. Exiting..."
#fi

# Check if the Delegator Image is already built.
if does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}"; then
	echo "The Glycam Web Delegator Docker Image is already built on your machine."
	echo "If you want to force it to be rebuilt, use the following and re-run this script."
	echo "    docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
	exit 0
fi

DATE="$( date +%Y-%m-%d-%H-%M-%S )"

STDERR_FILE="./logs/build_STDERR_${DATE}.log"
STDOUT_FILE="./logs/build_STDOUT_${DATE}.log"
DOCKER_COMMAND="""
docker compose \
	--file ${DOCKER_COMPOSE_BUILD_FILE} \
	-p ${PREFIX}-build \
	build \
	--build-arg BUILD_PROCS=${BUILD_PROCS}
	--parallel \
	delegator \
	2>> ${STDERR_FILE} \
	>> ${STDOUT_FILE}
"""
echo "Building Glycam Web Delegator Docker Image on: $( hostname ) with command:"
echo ${DOCKER_COMMAND}
if [ "${TEST}" != "Y" ]; then
	eval ${DOCKER_COMMAND}
	if ! does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}"; then
		print_error_and_exit "Something went wrong building the Delegator Docker Image. See ${STDERR_FILE} and/or ${STDOUT_FILE} for more information. Exiting..."
	fi
fi

# EXIT_SUCCESS
exit 0
