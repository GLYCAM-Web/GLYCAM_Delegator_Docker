#!/usr/bin/env bash
## Whatever sources this file should have sourced settings.bash first!

####
#### File git-settings.bash
####
#### Control info for which repositories, and their versions, are pulled.
####
#### You can expand or override these arrays in LocalGitSettings.bash.
####
#### Be cautious about changing paths because they might be referenced in many locations.
####

####
## Arrays used to control the repos - see the array contents below.
declare -A Repo_Directories             # Path, relative to this code, where the repo should go
declare -A Repo_Is_Submodule_Of         # If this repo is a submodule, who is the main repo?
declare -A Repo_URLs                    # Where the repo should be cloned/pulled from.
declare -A Repo_Branches                # The specific branch to pull.

####
## For now, only a few are pulled. This list can be altered in the local git settings file.
## Available repos:  gems gmml gmml2 md gm gmwebtool glycomimetics gwt-md 
##
## NOTE! Ensure that submodules appear after their parent.
##
## Repos to manage:
Repos=( gems gmml gmml2 md )

####
## If the repo is a parent, then give path relative to the main installation directory (where Install.bash is).
## If it is a sub-repo, the path is relative to the parent.
Repo_Directory=(
	["gems"]="${DEPENDENCIES_PATH}/gems"
	["gmml"]="gmml"
	["gmml2"]="gmml2"
	["md"]="External/MD_Utils"
	["gm"]="External/GM_Utils"
	["gmwebtool"]="${DEPENDENCIES_PATH}/glycomimeticsWebtool"
	["glycomimetics"]="internal/glycomimetics"
	["gwt-md"]="internal/MD_Utils"
)
Repo_Parent=(
	["gems"]="None"
	["gmml"]="gems"
	["gmml2"]="gems"
	["md"]="gems"
	["gm"]="gems"
	["gmwebtool"]="None"
	["glycomimetics"]="gmwebtool"
	["gwt-md"]="gmwebtool"
)
Repo_Target_Hash=(
	["gems"]="4aa2b09df45653633a4382daae491ea3ca758df9"
	["gmml"]="c7b519c67b0cfb103eabc103f1dc4138c380152f"
	["gmml2"]="25cdecb341d41e8e507d624e8c978f463ad220b0"
	["md"]="ce7be879941d95ce35e29d7fb9924a2aa717d451"
	["gm"]="4aa2b09df45653633a4382daae491ea3ca758df9"
	["gmwebtool"]="None"
	["glycomimetics"]="None"
	["gwt-md"]="None"
)
Repo_Target_Tag=(
	["gems"]="None"
	["gmml"]="None"
	["gmml2"]="None"
	["md"]="None"
	["gm"]="None"
	["gmwebtool"]="None"
	["glycomimetics"]="None"
	["gwt-md"]="None"
)
Repo_URL=(
	["gems"]="https://github.com/GLYCAM-Web/gems.git"
	["gmml"]="https://github.com/GLYCAM-Web/gmml.git"
	["gmml2"]="https://github.com/GLYCAM-Web/gmml2.git"
	["md"]="https://github.com/GLYCAM-Web/MD_Utils.git"
	["gm"]="https://github.com/GLYCAM-Web/GM_Utils.git"
	["gmwebtool"]="https://github.com/GLYCAM-Web/glycomimeticsWebtool.git"
	["glycomimetics"]="https://github.com/GLYCAM-Web/glycomimetics.git"
	["gwt-md"]="https://github.com/GLYCAM-Web/MD_Utils.git"
)
Repo_Branch=(
	["gems"]="gems-test"
	["gmml"]="gmml-test"
	["gmml2"]="main"
	["md"]="md-test"
	["gm"]="gm-test"
	["gmwebtool"]="feature_NoGmmlNoGmml2"
	["glycomimetics"]="webtoolOnlyBranch"
	["gwt-md"]="glycomimeticsWebtool"
)

if [ -f ./LocalGitSettings.bash ]; then
	source ./LocalGitSettings.bash
fi
