#!/usr/bin/env bash

##############################################################################################################
##############################################################################################################
#
#  This file has multiple purposes. 
#
#  Relevant to all purposes:  Provide an error-message database.
#
#    Purpose 1: Simplify human-friendly error message generation at runtime.
#
#               The 'build_error.bash' file contains auxiliary functions that use this information.
#
#    Purpose 2: Provide infrastructure for automated error message documentation that is assured
#               to be up-to-date with the actual error messages.
#                 
#               The file build_docs.bash is the utility for generating the documentation.                 
#               See below for information about additional infrastructure in this file.
#
##############################################################################################################
##############################################################################################################


##############################################################################################################
## For all purposes: Provide an error-message database.
#                    See functions.bash for convenient usage utilities and for examples.
##############################################################################################################
##
# The following are the arrays that store the data. They are filled out below.
# The keys for all of these arrays are the error number.
declare -A Error_Briefs           # Abbreviated, descriptive message. Five words or less, ideally.
declare -A Error_Meanings         # Sentence length user-friendly meaning of the message.
#
# The is relevant to the database, but is primarily useful for the documentation generation.
# Minimum and maximum numbers assigned to errors here.
Min_Err_Number="500"
Max_Err_Number="509"
#
# Text to be used when directing the user to additional information.
More_Info_Text="Please see the GLYCAM_Delegator_Docker/docs directory for more information."
#
##############################################################################################################

##############################################################################################################
## Automating the generation of error-message documentation.
##############################################################################################################
#
# Name of the documentation file to be written.
Document_Name="GlycoProtein_GDD_Error_Details_autogen_.md"
#
# Name of this service to be used within the file named above
Service_Name="GlycoProtein Builder"
#
##############################################################################################################

Error_Briefs=(
   ["500"]="Undesirable Outcome"
   ["501"]="Generic Failure"
   ["502"]="JSON Response Missing"
   ["503"]="JSON Response Incomplete"
   ["504"]="Summary Files Missing"
   ["505"]="No PDB Files Produced"
   ["506"]="Some PDB Files Missing"
   ["507"]="Unexpected Entry"
   ["508"]="No Available Sites"
   ["509"]="Cannot Rescue Build"
)
Error_Meanings=(
   ["500"]="The program finished without errors but the result is probably undesirable."
   ["501"]="This code is used when there is not a pre-defined code."
   ["502"]="The JSON Respose either was not received or was not recorded."
   ["503"]="The JSON Response is missing one or more critical pieces of data."
   ["504"]="Cannot find the files summarizing the outcomes of the glycosylation attempts."
   ["505"]="The project completed but no PDB files were found."
   ["506"]="The project completed but the expected number of PDB files was not found."
   ["507"]="The value of an entry or other variable is unexpected."
   ["508"]="There are no sites available for glycosylation."
   ["509"]="Unable to find a remedy for the previous failed build."
)



