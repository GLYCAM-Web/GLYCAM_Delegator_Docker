#!/usr/bin/env bash

## This script will generate errors documentation from a properly formatted error-database script.
#
# It should be called from the GLYCAM_Delegator_Docker directory.
#
# This first version of this script is based on: GlycoProtein_Error_Dictionaries.bash
#
# The name of the error-database script must be given as an argument.
#
# Note on error-database script formatting:
#   It should not 'exit'. If it is necessary to include a script-stopping command, use 'return'.
#
# Conversely, this file contains 'exit' commands. It should NOT be 'sourced'.
#
# Informtion from following arrays are included in the documentation.
# Contents appear in this order, grouped by Error Number.
#	Error Number
#	Error Brief
#	Error Meaning
#	Error Log File
#	Source File and Line
#	Error Generic Text
#

if [ -z "${1}" ] ; then 
	echo "Must supply the name of the Error-database script."
	exit 1
fi

## Set generic paths to the work and project directories from the main repo directory.
Work_Directory="input-output/work/conjugate/gp/pUUID"
Project_Directory="input-output/outputs/conjugate/gp/projectDir"

source "${1}"

if [ -e "docs/${Document_Name}" ] ; then
	echo "A document called docs/${Document_Name} already exists. Overwriting."
fi

Docs_Preamble="""# Common ${Service_Name} User Errors

This is not a comprehensive list, but it comprises the main errors that a user is likely to see.


## Main file contents overview

Beneath this preamble, for every covered error, you will find, sorted by error number:

- Error Number  : an error number for easy reference.
- Error Brief   : a very brief title/label for the error
- Error Meaning : a sentence-length user-friendly description of the error
- Path (1) to the log file where the error message can be found in context.
- Path to the source file where the error originates and the specific line in that file.
- A generic representation of the raw text supplied by source code when it throws the error.

(1) In this document, this path is the default location relative to the \`GLYCAM_Delegator_Docker\`
    main directory. Depending on your setup, the actual path could differ. Also, the place-holders
    pUUID and projectDir should be replaced by their values which will change for each run.

If you need grep strings for the error messages, see this file:
      \`${1}\`
The most likely location for the file is: \`GLYCAM_Delegator_Docker/mounts/sysetc\`


This file may have been generated with assistance from Gemini AI.

"""

echo "${Docs_Preamble}" > "docs/${Document_Name}"
echo """
Document created on $(date) by script \`${0}\`.
""" >> "docs/${Document_Name}"

the_number="${Min_Err_Number}"

while [ "${the_number}" -le "${Max_Err_Number}" ] ; do
	echo """---
${the_number}
${Error_Briefs[${the_number}]}
${Error_Meanings[${the_number}]}
\`${Error_Log_Files[${the_number}]}\`
\`${Source_File_and_Lines[${the_number}]}\`
\`${Error_Generic_Text[${the_number}]}\`
""" >> "docs/${Document_Name}"

	the_number="$((the_number + 1))"
done
