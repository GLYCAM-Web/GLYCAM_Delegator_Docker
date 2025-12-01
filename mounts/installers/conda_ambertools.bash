#!/usr/bin/env bash
################################################################
##########               Print help message         ############
################################################################

printHelp()
{
    echo "*************************************************************"
    echo "This script is used to install a minimal AmberTools via Conda."
    echo "    See instructions here:  https://ambermd.org/GetAmber.php"
    echo "*************************************************************\n"
    echo "Exiting."
    exit 1
}

CLEAN=""

### Installing AmberTools
UPDATE=''

if [ -d '/programs/conda' ] ; then
    UPDATE='-u'
fi


## Install Conda using MiniForge
mkdir -p /programs/src 
cd /programs/src 
wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" 
bash Miniforge3.sh ${UPDATE} -b -p "/programs/conda/"

## Install AmberTools using Conda
source "/programs/conda/etc/profile.d/conda.sh" 
conda create --name AmberTools25 python=3.12 
conda activate AmberTools25 
conda config --add channels conda-forge 
conda config --set channel_priority strict 
conda install dacase::ambertools-dac=25 
conda deactivate

# Don't do it.... conda init
