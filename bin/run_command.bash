#!/usr/bin/env bash

source ./settings.bash
source ./etc/functions.bash

# First check to make sure the GRPC Delegator Docker Image is built.
# If not, we will just informt he user and exit.
does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}" || {  print_error_and_exit "ERROR IN COMPILE.SH, THE DELEGATOR DOCKER IMAGE DOESNT EXIST" ; }

if [ ! -d './deps/gems/External/MD_Utils/' ] ; then
	echo "It appears that you have not pulled in the submodules for this repo."
	echo "Please see the README.md file for information. Exiting."
	exit 1
fi

export RUN_COMMAND="${1}"
export CONTAINER_NAME="${CONTAINER_NAME}_running-command"

# Second, run docker compose up.
COMMAND="docker compose --file ${DOCKER_COMPOSE_RUN_FILE} up delegator"
( ${COMMAND} ) || {  print_error_and_exit "ERROR UPPING RUN command IMAGE" ; } 
echo "container is up"

# Third, once done compiling then run docker compose down.
COMMAND="docker compose --file ${DOCKER_COMPOSE_RUN_FILE} down"
( ${COMMAND} ) || {  print_error_and_exit "ERROR DOWNING RUN command IMAGE" ; }

# EXIT_SUCCESS
exit 0
