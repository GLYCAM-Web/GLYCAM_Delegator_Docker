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

WorkDir="$(pwd)"

## This can go away after a while. It is only needed by folks who used the very earliest versions of the code.
## Submodules turned out to be a bit more hassle than just using sub-repos.
bash bin/special/move_submodules_to_sub-branches.bash
result="$?"
if [ "${result}" != "0" ] ; then
	echo "Non-zero status returned from bin/special/move_submodules_to_sub-branches.bash - exiting."
	echo "Please contact the developers and/or make a bug report. Please include the git hash."
	echo "To do that, use 'git rev-parse HEAD' from a command line inside the repo."
	exit 1
fi

for repo in ${Repos[@]} ; do
        echo "Working on this repository: ${repo}"
        parent="${Repo_Parent[${repo}]}"
        if [ "${parent}" == "None" ] ; then
                if [ ! -d "${Repo_Directory[${repo}]}/.git" ] ; then
                        COM="git clone -b ${Repo_Branch[${repo}]} ${Repo_URL[${repo}]} ${Repo_Directory[${repo}]}"
                        rclr "About to clone parent repo: ${repo}" "${COM}" "Cloning ${repo}"
                fi

		targetHash="${Repo_Target_Hash[${repo}]}"
		if [ "${targetHash}" == "None" ] ; then
			cd "${WorkDir}"
			continue  
		fi

		cd "${Repo_Directory[${repo}]}"
		theHash="$(git rev-parse HEAD)"
		if [ "${theHash}" != "${targetHash}" ] ; then
			COM="git revert ${targetHash}"
			rclr "Ensuring that the repo is on the target hash." "${COM}" "Target hash setting"
		fi
        else
		parentDir="${Repo_Directory[${parent}]}"
                if [ ! -d "${parentDir}/.git" ] ; then
                        print_error_and_exit "The parent repo should already exist. It is: ${Repo_Directory[${parent}]}"
                fi
		cd ${parentDir}
                COM="git clone -b ${Repo_Branch[${repo}]} ${Repo_URL[${repo}]} ${Repo_Directory[${repo}]}"
                rclr "About to clone the sub repo ${repo} of parent ${parent}" "${COM}" "Cloning ${repo} as sub repo"

		targetHash="${Repo_Target_Hash[${repo}]}"
		if [ "${targetHash}" == "None" ] ; then
			cd "${WorkDir}"
			continue
		fi

		cd ${Repo_Directory[${repo}]}
		theHash="$(git rev-parse HEAD)"
		if [ "${theHash}" != "${targetHash}" ] ; then
			COM="git revert ${targetHash}"
			rclr "Ensuring that the repo is on the target hash." "${COM}" "Target hash setting"
		fi
        fi
	cd "${WorkDir}"
done
