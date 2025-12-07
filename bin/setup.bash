#!/usr/bin/env bash

source ./settings.bash
source ./etc/functions.bash

#########################################
#		     Ensure Directories				#
#########################################
DelegatorDirectories=(
	./config_history/
	./deps/
	./env/
	./logs/
	./mounts/containerUser/
	./input-output/inputs/
	./input-output/tests/
	./input-output/outputs/
	./input-output/work/
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
GEMS_OUTPUT_PATH='/work/'
USE_AMBER_CONDA='True'
""" > ${DELEGATOR_ENV_FILE}

echo """#!/usr/bin/env bash
#########  Added by GLYCAM Delegator Docker setup  #########
export PATH=/programs/bin:/programs/gems/bin:${PATH}
if [[ \"\${PYTHONPATH}\" == *\"/programs/gems\"* ]] ; then
	:
elif [ -z \"\${PYTHONPATH}\" ] ; then
	PYTHONPATH=/programs/gems
else
	PYTHONPATH=/programs/gems:\${PYTHONPATH}
fi
export PYTHONPATH
############################################################
""" > ./mounts/containerUser/.bashrc

# EXIT_SUCESS
exit 0
