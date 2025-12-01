#!/usr/bin/env bash
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

### Installing AmberTools
UPDATE=''

if [ -d '/programs/conda' ] ; then
	if [ "${CLEAN}" == '-c' ] ; then
		rm -rf /programs/conda
	else
		UPDATE='-u'
	fi
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

