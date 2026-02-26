#!/usr/bin/env bash

# should be called from the top-level dirctory
# this script is intended to be called when a user enters this command:
#   bash bin/run_tests.bash

echo "Starting to run the GlycoProtein Builder test."

# make a backup of the existing SessionSettings.bash
cp ./deps/share/SessionSettings.bash ./deps/share/SessionSettings.bash.testing-backup

# append the SessionSettings.bash with settings needed for the test
cat ./tests/GlycoProtein/SessionSettings.bash >> ./deps/share/SessionSettings.bash

# source the SessionSettings.bash so that this script knows them
. ./tests/GlycoProtein/SessionSettings.bash

# copy the inputs to a visible directory
cp ./tests/GlycoProtein/inputs/glycoprotein_test_input.csv  ./input-output/inputs/

# run the build
bash bin/run_command.bash Generate_GlycoProtein_From_PDB_ID_+_Links_List /inputs/glycoprotein_test_input.csv

# check the outputs
the_diffs="$(diff -r ./input-output/outputs/conjugate/gp/${OUT_SUBDIR}/PDB ./tests/GlycoProtein/correct_outputs/PDB)"
result="$?"
if [ "${result}" != "0" ] ; then
	echo "The test failed."
	echo "There was a problem diffing the files."
	echo "Here is the return code: ${result}."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${the_diffs}
===========================================================
"""
exit 1
fi

if [ "${the_diffs}" != ""] ; then
	echo "The test failed."
	echo "The diffs were not empty, and they should be."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${the_diffs}
===========================================================
"""
exit 1
fi

# Still here? Yay!
echo "The test passed."
