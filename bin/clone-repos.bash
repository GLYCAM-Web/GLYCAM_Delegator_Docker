#!/usr/bin/env bash

# Only for initial cloning!

source ./settings.bash
source ./etc/functions.bash
source ./git-settings.bash

Test="True"

for repo in ${Repos[@]} ; do
	echo "Working on this repository: ${repo}"
	submod="${Repo_Is_Submodule_Of[${repo}]}"
	if [ "${submod}" == "None" ] ; then
		if [ ! -e "${Repo_Directories[${repo}]}" ] ; then
			COM="git clone -b ${Repo_Branches[${repo}]} ${Repo_URLs[${repo}]} ${Repo_Directories[${repo}]}"
		else
		fi
	else
	fi

done
