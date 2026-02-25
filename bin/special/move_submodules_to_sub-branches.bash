#!/usr/bin/env bash

### If a repo with submodules is present, convert it to a subdirectory pattern
###
### Currently this is only expected in the deps/gems tree, and only from the very 
### first version. So hard-coding to that. 

## Check if there are submodules
#    - currently, these are only expected in the deps/gems tree.
if [ ! -e "deps/gems" ] ; then
	exit 0 ## There is no gems directory at all, so not a parent of submodules
fi
if [ ! -d "deps/gems" ] ; then
	message="[ERROR} Exiting: deps/gems exists but is not a directory. I don't know what to do with that."
	echo "${message}"
	exit 1 
fi
noSubmodules="True"
filesToCheck=( # if any of these exists as a file, there are submodules
	"deps/gems/.gitmodules"
	"deps/gems/gmml/.git"
	"deps/gems/gmml2/.git"
	"deps/gems/External/MD_Utils/.git"
)
for FILE in ${filesToCheck[@]} ; do
	if [ -f "${FILE}" ] ; then
		noSubmodules="False"
	fi
done
if [ "${noSubmodules}" == "True" ] ; then
	exit 0 # no evidence of submodules found
fi

# Still here? Undo the submodules.

for FILE in ${filesToCheck[@]} ; do
	if [ -f "${FILE}" ] ; then
		rm ${FILE}
	fi
done

declare -a reposToFix
reposToFix=( gmml gmml2 md )

declare -A repoBaseDir
repoBaseDir=( # move these back to being real directories
	["gmml"]="deps/gems/gmml/"
	["gmml2"]="deps/gems/gmml2/"
	["md"]="deps/gems/External/MD_Utils/"
)

declare -A gitDirToReplace
gitDirToReplace=( # move these back to being real directories
	["gmml"]="deps/gems/gmml/.git"
	["gmml2"]="deps/gems/gmml2/.git"
	["md"]="deps/gems/External/MD_Utils/.git"
)

declare -A gitDirCurrentLocation
gitDirCurrentLocation=( # move these back to being real directories
	["gmml"]="deps/gems/.git/modules/gmml"
	["gmml2"]="deps/gems/.git/modules/gmml2"
	["md"]="deps/gems/.git/modules/External/MD_Utils"
)

for REPO in ${reposToFix[@]} ; do 
	if [ ! -d "${repoBaseDir[${REPO}]}" ] ; then
		echo "No such directory: ${repoBaseDir[${REPO}]}"
		echo "This might cause trouble later."
		continue
	fi
	mv ${gitDirCurrentLocation[${REPO}]} ${gitDirToReplace[${REPO}]}
	sed -i '/worktree/d' ${gitDirToReplace[${REPO}]}/config
done

## Clean the parent (gems) repo
rmdir deps/gems/.git/modules/External
rmdir deps/gems/.git/modules
rm -f deps/gems/.gitmodules
sed -i '/submodule/,+2d' deps/gems/.git/config

(cd deps/gems && git restore --staged .gitmodules External/MD_Utils gmml gmml2)
