#!/usr/bin/env bash

## This script, possibly with modification, will search for locations of error messages in source code.
#
# It should be called from the GLYCAM_Delegator_Docker directory.
#
# The output goes to stdout. 
#

if [ -z "${1}" ] ; then 
	echo "Must supply the name of the Error-database script."
	exit 1
fi
if [ -z "${2}" ] ; then 
	echo "Must supply the name of the source code tree to search."
	exit 1
fi

source "${1}"

source_tree="${2}"
if [ ! -e "${source_tree}" ] ; then
	echo "Cannot find the source tree >>>${source_tree}<<<."
	exit 1
fi

the_number="${Min_Err_Number}"

while [ "${the_number}" -le "${Max_Err_Number}" ] ; do
	CMD="grep -nrs -E  \"${Error_Grep_Strings[${the_number}]}\" ${source_tree}"
	echo """==================================================================================
Working on error ${the_number} with brief: ${Error_Briefs[${the_number}]}
Using grep command:
${CMD}
----------
""" 
	eval "${CMD}"

	echo "=================================================================================="

	the_number="$((the_number + 1))"
done
