#!/usr/bin/env bash

# Install the environment needed for GLYCAM Delegator Docker to function
#
# Each part of the process takes this form: 
#
# STEP="short-name"
# LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
# COM="bash bin/X.bash"
# rclr "Detailed Description." "${COM}" "(${NUM}) - Short descriptive name"
# NUM="$((NUM+1))"
#
# Want to make this even less repetitive? Go for it.

source ./settings.bash

DATE="$( date +%Y-%m-%d-%H-%M-%S )"
STATUSFILE="./logs/status_${DATE}.log"
NUM="1"
# Uncomment the next if you want a dry run to show what will happen.
# TEST="True"

echo "Setting up"

# Setup is special 
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/setup.bash"
eval "${COM}" 
echo "[INFO] : $(date) : Finished setup." >> ${STATUSFILE}
NUM="$((NUM+1))"
source ./etc/functions.bash

echo """
Some of these processes can take a while.
    To check status or follow along, look at files in the logs directory.
    You can also check a process monitor (e.g., 'top') if the logs seem quiet.
"""

echo "Building the image. If this is the first time, it could take a while."

STEP="build-image"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build_image.bash"
rclr "Building the Docker image used for all operations." "${COM}" "(${NUM}) - Docker image build"
NUM="$((NUM+1))"

echo "Cloning the repos"

STEP="clone-repos"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/manage_repos.bash"
rclr "Cloning the repositories listed in git-settings.bash." "${COM}" "(${NUM}) - Repository initialization"
NUM="$((NUM+1))"

echo "Installing gems, gmml and gmml2. This can also take a while."

STEP="install-gems-gmml"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build_gems_gmml_gmml2.bash"
rclr "Building GMML and GMML2 and wrapping with SWIG for use in GEMS." "${COM}" "(${NUM}) - GEMS/GMMLs builds"
NUM="$((NUM+1))"

echo "Installing AmberTools using Conda. This isn't the longest task, but it is the last one."

STEP="install-amber-conda"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build_conda-amber.bash"
rclr "Installing AmberTools using Conda" "${COM}" "(${NUM}) - AmberTools installation"
NUM="$((NUM+1))"

## Template for adding more
#STEP="short-name"
#LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
#COM="bash bin/.bash"
#rclr "Detailed Description." "${COM}" "(${NUM}) - Short descriptive name"
#NUM="$((NUM+1))"

