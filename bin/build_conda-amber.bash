#!/usr/bin/env bash

#### This script is used to install:
####     * Conda
####     * A minimal AmberTools via Conda.
####         See instructions here:  https://ambermd.org/GetAmber.php
#### 
#### A separate script cleans.

source ./settings.bash
source ./etc/functions.bash

# First check to make sure the GLYCAM Delegator Docker Image is built.
# If not, we will just informt he user and exit.
does_image_exist "${IMAGE_NAME}:${IMAGE_TAG}" || {  print_error_and_exit "ERROR IN ${0}, THE DELEGATOR DOCKER IMAGE DOESNT EXIST" ; }

#update our the command that will be used to actually compile the GEMS/gmml code
COMPILER_COMMAND="bash /installers/conda_ambertools.bash"
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
