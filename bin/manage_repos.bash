#!/usr/bin/env bash

# Manage the repos, whatever the state

ScriptName="$(basename ${0})"
if [ -z "${DATENOW}" ] ; then
        export DATENOW="$(date +%Y-%m-%d-%H-%M)"
fi
if [ -z "${LOGFILE}" ] ; then
        export LOGFILE="logs/details_${DATENOW}_${ScriptName}.log"
fi
if [ -z "${STATUSFILE}" ] ; then
        export STATUSFILE="logs/status_${DATENOW}_${ScriptName}.log"
fi

source ./settings.bash
source ./etc/functions.bash
source ./git-settings.bash
echo """
If successful, these repos should be added or updated:
   ${Repos[@]}
Follow progress by examining:
   ${LOGFILE}
   ${STATUSFILE}
"""

for repo in ${Repos[@]} ; do
        echo "Working on this repository: ${repo}"
        submod="${Repo_Is_Submodule_Of[${repo}]}"
        if [ "${submod}" == "None" ] ; then
                if [ ! -d "${Repo_Directories[${repo}]}/.git" ] ; then
                        COM="git clone -b ${Repo_Branches[${repo}]} ${Repo_URLs[${repo}]} ${Repo_Directories[${repo}]}"
                        rclr "About to clone the parent repo: ${repo}" "${COM}" "Cloning ${repo}"
                else
                        echo "The repo ${repo} appears to already be cloned. Skipping."
                fi
        else
                if [ ! -d "${Repo_Directories[${submod}]}/.git" ] ; then
                        print_error_and_exit "The parent repo should already exist. It is: ${Repo_Directories[${submod}]}"
                fi
                if [ -e "${Repo_Directories[${submod}]}/.git" ] ; then
                        COM="""( cd ${Repo_Directories[${submod}]} \
        && git submodule add  -f -b ${Repo_Branches[${repo}]} ${Repo_URLs[${repo}]} ${Repo_Directories[${repo}]})"""
                        rclr "About to clone the submodule ${repo} of parent ${submod}" "${COM}" "Cloning ${repo} as submodule"
                else
                        echo "The submodule ${repo} appears to already exist. Skipping."
                fi
        fi

done
