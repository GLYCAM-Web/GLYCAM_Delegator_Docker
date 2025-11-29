#!/usr/bin/env bash

source ./settings.bash
source ./etc/functions.bash


if ! bash ./bin/setup.bash; then
	print_error_and_exit
fi

if ! bash ./bin/build.bash; then
	print_error_and_exit
fi

DATE="$( date +%Y-%m-%d-%H-%M-%S )"
STDOUT_FILE="./logs/start_STDOUT_${DATE}.log"
STDERR_FILE="./logs/start_STDERR_${DATE}.log"

COMMAND="""
docker compose \
	--file ${DOCKER_COMPOSE_RUN_FILE} \
	-p ${PREFIX}-run \
	up -d \
	2>> ${STDERR_FILE} \
	>> ${STDOUT_FILE}
"""

echo ${COMMAND}
if [ "${TEST}" != "Y" ]; then
	eval ${COMMAND}
fi

# EXIT_SUCCESS
exit 0
