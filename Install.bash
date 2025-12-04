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

DATE="$( date +%Y-%m-%d-%H-%M-%S )"
STATUSFILE="./logs/status_${DATE}.log"
NUM="1"
# Uncomment the next if you want a dry run to show what will happen.
# TEST="True"

STEP="setup"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/setup.bash"
rclr "Ensure that directories exist and that required environment settings are in place." "${COM}" "(${NUM}) - Setup"
NUM="$((NUM+1))"

STEP="build-image"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build-image.bash"
rclr "Building the Docker image used for all operations." "${COM}" "(${NUM}) - Docker image build"
NUM="$((NUM+1))"

STEP="clone-repos"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/clone-repos.bash"
rclr "Cloning the repositories listed in git-settings.bash." "${COM}" "(${NUM}) - Repository initialization"
NUM="$((NUM+1))"

STEP="install-gems-gmml"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build_gems_gmml_gmml2.bash.bash"
rclr "Building GMML and GMML2 and wrapping with SWIG for use in GEMS." "${COM}" "(${NUM}) - GEMS/GMMLs builds"
NUM="$((NUM+1))"

STEP="install-amber-conda"
LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
COM="bash bin/build_conda-amber.bash"
rclr "Installing AmberTools using Conda" "${COM}" "(${NUM}) - AmberTools installation"
NUM="$((NUM+1))"

#STEP="short-name"
#LOGFILE="./logs/details_${DATE}_${NUM}_${STEP}.log"
#COM="bash bin/.bash"
#rclr "Detailed Description." "${COM}" "(${NUM}) - Short descriptive name"
#NUM="$((NUM+1))"

