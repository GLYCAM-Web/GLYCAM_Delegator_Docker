#!/usr/bin/env bash

# should be called from the top-level dirctory
# this script is intended to be called when a user enters this command:
#   bash bin/run_tests.bash

echo "Starting to run the GlycoProtein Builder test."

# make a backup of the existing SessionSettings.bash
cp ./deps/share/SessionSettings.bash ./deps/share/SessionSettings.bash.testing-backup

# append the SessionSettings.bash with settings needed for the test
cat ./tests/GlycoProtein/SessionSettings_gitkeep_.bash >> ./deps/share/SessionSettings.bash

# source the SessionSettings.bash so that this script knows them
. ./tests/GlycoProtein/SessionSettings_gitkeep_.bash

# copy the inputs to a visible directory
cp ./tests/GlycoProtein/inputs/glycoprotein_test_input.csv  ./input-output/inputs/

# run the build
bash bin/run_command.bash Generate_GlycoProtein_From_PDB_ID_+_Links_List /inputs/glycoprotein_test_input.csv

# check the outputs of the good result
good_diffs="$(diff -r ./input-output/outputs/conjugate/gp/${OUT_SUBDIR}/PDB/*.pdb ./tests/GlycoProtein/correct_outputs/PDB/*.pdb)"
result="$?"
if [ "${result}" != "0" ] ; then
	echo "The test failed."
	echo "There was a problem diffing the files from the sucessful build."
	echo "Here is the return code: ${result}."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${good_diffs}
===========================================================
"""
exit 1
fi

# check the outputs of the bad result
bad_diffs="$(diff -r ./input-output/outputs/conjugate/gp/${OUT_SUBDIR}/PDB/rejected/*.pdb ./tests/GlycoProtein/correct_outputs/PDB/rejected/*.pdb)"
result="$?"
if [ "${result}" != "0" ] ; then
	echo "The test failed."
	echo "There was a problem diffing the files from the unsucessful build."
	echo "Here is the return code: ${result}."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${bad_diffs}
===========================================================
"""
exit 1
fi

passed="True"
if [ "${good_diffs}" != "" ] ; then
	echo "The test of the successful build failed."
	echo "The diffs were not empty, and they should be."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${good_diffs}
===========================================================
"""
fi
if [ "${bad_diffs}" != "" ] ; then
	echo "The test of the unsuccessful build failed."
	echo "The diffs were not empty, and they should be."
	echo "Here is the output that was returned (between two lines of equals-signs):"
	echo """===========================================================
${bad_diffs}
===========================================================
"""
passed="False"
fi

if [ "${passed}" != "True" ] ; then
	echo "One or more sub-tests failed. See above for info."
	echo "The test directory is at: ./input-output/outputs/conjugate/gp/${OUT_SUBDIR}"
	echo "That directory might contain information about the failure."
	exit 1
fi

# Still here? Yay!
echo "All sub-tests passed."
echo "Removing the test directory"
if [ -d "./input-output/outputs/conjugate/gp/${OUT_SUBDIR}" ] ; then
	rm -rf "./input-output/outputs/conjugate/gp/${OUT_SUBDIR}"
fi
echo "Restoring the original ./deps/share/SessionSettings.bash file."
cp ./deps/share/SessionSettings.bash.testing-backup ./deps/share/SessionSettings.bash 

