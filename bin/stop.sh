#!/usr/bin/env bash

source ./settings.sh
source ./etc/functions.sh

DATE="$( date +%Y-%m-%d-%H-%M-%S )"
STDERR_FILE="./logs/stop_STDERR_${DATE}.log"
STDOUT_FILE="./logs/stop_STDOUT_${DATE}.log"

COMMAND="""
docker compose \
	--file ${DOCKER_COMPOSE_RUN_FILE} \
	-p ${PREFIX}-run \
	down \
	2>> ${STDERR_FILE} \
	>> ${STDOUT_FILE}
"""

echo ${COMMAND}
if [ "${TEST}" != "Y" ]; then
	eval ${COMMAND}
fi

# EXIT_SUCCESS
exit 0
