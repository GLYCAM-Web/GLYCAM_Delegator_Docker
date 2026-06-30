#!/usr/bin/env bash

## This script will generate errors documentation from a properly formatted error-management script.
#
# This first version of this script is based on: GlycoProtein_Error_Dictionaries.bash
#
# The name of the error-management script must be given as an argument.
#
# Note on error-management script formatting:
#   It should not 'exit'. If it is necessary to include a script-stopping command, use 'return'.
#
# Conversely, this file contains 'exit' commands. It should NOT be 'sourced'.

if [ -z "${1}" ] ; then 
	echo "Must supply the name of the Error-management script."
	exit 1
fi

source "${1}"

if [ -e "docs/${Document_Name}" ] ; then
	echo "A document called docs/${Document_Name} already exists. Overwriting."
fi

echo "${Docs_Preamble}" > "docs/${Document_Name}"
echo """
Document created on $(date) by script ${0}.
""" >> "docs/${Document_Name}"

# For each entry in Docs_Order
