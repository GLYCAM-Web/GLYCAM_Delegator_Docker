#!/usr/bin/env bash

source ./settings.bash
source ./etc/functions.bash

#########################################
#                    Ensure Directories                         #
#########################################
DelegatorDirectories=(
        ./config_history/
        ./deps/share
        ./deps/src
        ./env/
        ./logs/
        ./mounts/containerUser/
        ./mounts/sysetc/
        ./mounts/sysbin/
        ./input-output/inputs/
        ./input-output/tests/
        ./input-output/outputs/
        ./input-output/work/
        )
for directory in ${DelegatorDirectories[@]} ; do
        check_make_directory ${directory}
done

#########################################
#                       Delegator Setup                         #
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
export PATH=/programs/bin:/sysbin:/programs/gems/bin:\${PATH}
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

echo """
if [ -z \"\${DATENOW}\" ] ; then
        OUT_SUBDIR=\"GenericDirectory\"
else
        OUT_SUBDIR=\"\${DATENOW}\"
fi

export OUT_SUBDIR  
export OVERWRITE_OUTPUT=\"False\"
export UNMIN_SUFFIX=\"_un-min\"
export DATE_BUILD_DATABASE=\"True\"

""" > ./mounts/sysetc/_autogen_config.bash

if [ ! -e "./_autogen_config.bash" ] ; then
        ln -s ./mounts/sysetc/_autogen_config.bash
fi

echo """
## SessionSettings.bash
##
## See example at: ./examples/configs-settings/SessionSettings.bash.example
##
## Also see: ./docs/Configuration.md
""" > ./deps/share/SessionSettings.bash

if [ ! -e "./SessionSettings.bash" ] ; then
        ln -s ./deps/share/SessionSettings.bash
fi

if [ ! -e "./etc" ] ; then
        ln -s ./mounts/sysetc etc
fi

