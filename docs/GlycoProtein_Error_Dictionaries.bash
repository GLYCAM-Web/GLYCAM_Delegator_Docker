#!/usr/bin/env bash

declare -A Error_Briefs
declare -A Error_Meanings
declare -A Error_Generic_Text
declare -A Source_File_and_Line
declare -A Error_Grep_Strings


# Common GlycoProtein Builder User Errors
# This is not a comprehensive list, but it comprises the main errors that a user is likely to see.
#
#Please see the file `GlycoProtein_Error_Details.md` for the exact error text as well as the location of 
#the error in the source code.
#
#This file was generated with assistance from Gemini AI.
#
#In the following table, a number in square brackets indicates a common error with a fix that might be 
#easy for you. Please see the bottom of this file for details.
## | Missing Element Definition [1]      | The element designation is unknown. [1]                                    |
## [1] A workaround for this error is to remove all HETATM and ANISOU cards from the PDB file before processing.


Error_Briefs=(
   ["501"]=["Incorrect Site Identifier Format"]
   ["502"]=["Missing Anomeric Carbon"]
   ["503"]=["Single-Residue Sugar Error"]
   ["504"]=["Unsupported Glycosylation Site"]
   ["505"]=["Missing Required Connection Atom"]
   ["506"]=["Missing Target Glycosite Residue"]
   ["507"]=["Multiple Connections to an Aglycone"]
   ["508"]=["Empty Sequence"]
   ["509"]=["Easter Egg Validation Failure"]
   ["510"]=["Space Character inside Sequence"]
   ["511"]=["Forbidden Character in Sequence"]
   ["512"]=["Mismatching Bracket Structure"]
   ["513"]=["Labeled Sequences Unsupported"]
   ["514"]=["Sequence Graph Disconnectivity"]
   ["515"]=["Missing Element Definition"]
   ["516"]=["Missing Atomic Mass Metadata"]
   ["517"]=["Missing Amino Acid Metadata"]
   ["518"]=["Conformation Inconsistency"]
   ["519"]=["Conformer Weight Mismatch"]
   ["520"]=["Disconnected Residues"]
   ["521"]=["Missing Dihedral Angles/Metadata"]
   ["522"]=["Unknown Rotamer Configuration Type"]
   ["523"]=["Carbohydrate Parent Residue Removal"]
   ["524"]=["PDB CONECT ID Parsing Failure"]
   ["525"]=["PDB CONECT Atom Missing"]
   ["526"]=["PDB File Open Failure"]
   ["527"]=["Prep File Read Failure"]
)
Error_Meanings=(
   ["501"]=["The format used for your glycosylation site could not be understood."]
   ["502"]=["The anomeric carbon (or other anomeric atom) could not be found in a monosaccharide residue."]
   ["503"]=["Monosaccharides with an aglycone are expected to have at least 2 residues."]
   ["504"]=["Glycosylation was requested for a residue other than ASN, THR, SER or TYR."]
   ["505"]=["A residue does not contain a key atom for making a connection."]
   ["506"]=["The residue to be glycosylated could not be found."]
   ["507"]=["An aglycone with multiple monosaccharides is not supported."]
   ["508"]=["The provided sequence is empty."]
   ["509"]=["We found a cake in your sequence! And the cake is a lie!"]
   ["510"]=["Sequences cannot contain spaces."]
   ["511"]=["Your sequence contains a character that is not expected."]
   ["512"]=["One of your brackets (of whatever type) was not part of a pair."]
   ["513"]=["Sequences containing custom labels are not yet supported."]
   ["514"]=["A part of your sequence could not be connected to the rest of it."]
   ["515"]=["The element designation is unknown to this code."]
   ["516"]=["The code does not know the atomic mass for this element."]
   ["517"]=["This amino acid is not known to the code."]
   ["518"]=["The given and expected numbers of linkage conformers differs."]
   ["519"]=["The given and expected weights of linkage conformers differs."]
   ["520"]=["Two residues that were expected to connect cannot be connected."]
   ["521"]=["The dihedral angles and/or probabilities for a linkage are not known."]
   ["522"]=["The code does not know the meaning of the type given for a rotamer."]
   ["523"]=["A parent residue was removed by chance, and likely by accident."]
   ["524"]=["A CONECT card in the PDB file could not be parsed."]
   ["525"]=["The atom's number was not found in the CONECT cards."]
   ["526"]=["The PDB file could not be opened/read."]
   ["527"]=["The Prep file could not be opened/read."]
)
Error_Generic_Text=(
   ["501"]=["userSelection (<userSelection>) for residue to glycosylate is incorrect format. Must be chain_residueNumber_insertionCode. InsertionCode is optional. Chain can be ? if no chain numbers are in input. Examples: ?_24_? or ?_24 will use the first residue it encounters numbered 24. A_24_B is A chain, residue 24, insertion code B"]
   ["502"]=["Did not find a C1 or C2 with a foreign neighbor in residue: <residueStringId>, thus no anomeric atom was found."]
   ["503"]=["Reducing residue and aglycone requested for Carbohydrate with name <glycanName>, but it doesn't have more than 1 residue"]
   ["504"]=["Problem creating glycosylation site. The amino acid requested: <residueId> has name (<name>) that isn't supported. Currently you can glycosylate ASN, THR, SER or TYR."]
   ["505"]=["Error: atom '<name>' not found in residue <residueId> with atoms: <list of atoms>"]
   ["506"]=["Error: Did not find a residue with id matching <proteinResidueId>"]
   ["507"]=["Error: found more than 1 linkage to aglycone in <glycanInput>"]
   ["508"]=["Error: sequence is empty:>>><sequence><<<"]
   ["509"]=["Error: the cake is a lie:>>><sequence><<<"]
   ["510"]=["Error: sequence contains a space:>>><sequence><<<"]
   ["511"]=["Error: sequence cannot contain this:'<char>':>>><sequence><<<"]
   ["512"]=["Did not find corresponding '<bracket>' for character '<bracket>' at position <index> of sequence: <sequence>"]
   ["513"]=["Error: SequenceParser can't read labeled sequences yet: <sequence>"]
   ["514"]=["Error: sequence graph not fully connected"]
   ["515"]=["Did not find this Element in the list of atomic Elements: <element>"]
   ["516"]=["Error: missing atomic mass for element: <element>"]
   ["517"]=["Error: amino acid not found in metadata: <name>"]
   ["518"]=["error: different number of conformers in linkage: <linkage_details>"]
   ["519"]=["error: conformers have different weight in linkage: <linkage_details>"]
   ["520"]=["Two residues passed into findResidueLink that have no connection atoms."]
   ["521"]=["missing dihedrals or metadata in residue linkage: <linkage_details>"]
   ["522"]=["Error: Unknown rotamer type: <type>"]
   ["523"]=["Error: required parent residue removed by random chance. Check sequence definition"]
   ["524"]=["Error: could not parse conect id: <line>"]
   ["525"]=["Error: conect row atom id not found: <line>"]
   ["526"]=["PdbFile constructor could not open this file: <pdbFilePath>"]
   ["527"]=["Prep file exists but couldn't be opened."]
)
## File locations relative to the GMML2 root directory.
Source_File_and_Line=(
   ["501"]=["64 : src/glycoprotein/glycoproteinCreation.cpp"
   ["502"]=["115 : src/glycoprotein/glycoproteinCreation.cpp"
   ["503"]=["136 : src/glycoprotein/glycoproteinCreation.cpp"
   ["504"]=["153 : src/glycoprotein/glycoproteinCreation.cpp"
   ["505"]=["202 : src/glycoprotein/glycoproteinCreation.cpp"
   ["506"]=["268 : src/glycoprotein/glycoproteinCreation.cpp"
   ["507"]=["322 : src/glycoprotein/glycoproteinCreation.cpp"
   ["508"]=["207 : src/sequence/sequenceParser.cpp"
   ["509"]=["211 : src/sequence/sequenceParser.cpp"
   ["510"]=["215 : src/sequence/sequenceParser.cpp"
   ["511"]=["223 : src/sequence/sequenceParser.cpp"
   ["512"]=["229 : src/sequence/sequenceParser.cpp"
   ["513"]=["412 : src/sequence/sequenceParser.cpp"
   ["514"]=["357 : src/sequence/sequenceManipulation.cpp"
   ["515"]=["314 : src/metadata/elements.cpp"
   ["516"]=["244 : src/metadata/elements.cpp"
   ["517"]=["272 : src/metadata/aminoAcids.cpp"
   ["518"]=["133 : src/CentralDataStructure/residueLinkage/residueLinkageCreation.cpp"
   ["519"]=["145 : src/CentralDataStructure/residueLinkage/residueLinkageCreation.cpp"
   ["520"]=["205 : src/CentralDataStructure/residueLinkage/residueLinkageCreation.cpp"
   ["521"]=["294 : src/CentralDataStructure/residueLinkage/residueLinkageCreation.cpp"
   ["522"]=["41 : src/CentralDataStructure/residueLinkage/residueLinkageFunctions.cpp"
   ["523"]=["360 : src/carbohydrate/carbohydrate.cpp"
   ["524"]=["37 : src/fileType/pdb/pdbFile.cpp"
   ["525"]=["43 : src/fileType/pdb/pdbFile.cpp"
   ["526"]=["212 : src/fileType/pdb/pdbFile.cpp"
   ["527"]=["33 : src/fileType/prep/prepFile.cpp"
)
## Using this array
##
##    Use 'grep -E' to get the equivalent of this:
## grep -E "userSelection \([^)]+\) for residue to glycosylate is incorrect format\. Must be chain_residueNumber_insertionCode"
Error_Grep_Strings=(
   ["501"]=["userSelection \([^)]+\) for residue to glycosylate is incorrect format\. Must be chain_residueNumber_insertionCode"]
   ["502"]=["Did not find a C1 or C2 with a foreign neighbor in residue: .+, thus no anomeric atom was found\."]
   ["503"]=["Reducing residue and aglycone requested for Carbohydrate with name .+, but it doesn't have more than 1 residue"]
   ["504"]=["Problem creating glycosylation site\. The amino acid requested: .+ has name \([^)]+\) that isn't supported"]
   ["505"]=["Error: atom '[^']+' not found in residue .+ with atoms:"]
   ["506"]=["Error: Did not find a residue with id matching .+"]
   ["507"]=["Error: found more than 1 linkage to aglycone in .+"]
   ["508"]=["Error: sequence is empty:>>>.*<<<"]
   ["509"]=["Error: the cake is a lie:>>>.*<<<"]
   ["510"]=["Error: sequence contains a space:>>>.*<<<"]
   ["511"]=["Error: sequence cannot contain this:'[^']+':>>>.*<<<"]
   ["512"]=["Did not find corresponding '[^']+' for character '[^']+' at position [0-9]+ of sequence:"]
   ["513"]=["Error: SequenceParser can't read labeled sequences yet: .+"]
   ["514"]=["Error: sequence graph not fully connected"]
   ["515"]=["Did not find this Element in the list of atomic Elements: .+"]
   ["516"]=["Error: missing atomic mass for element: .+"]
   ["517"]=["Error: amino acid not found in metadata: .+"]
   ["518"]=["[Ee]rror: different number of conformers in linkage: .+"]
   ["519"]=["[Ee]rror: conformers have different weight in linkage: .+"]
   ["520"]=["Two residues passed into findResidueLink that have no connection atoms\."]
   ["521"]=["missing dihedrals or metadata in residue linkage: .+"]
   ["522"]=["Error: Unknown rotamer type: .+"]
   ["523"]=["Error: required parent residue removed by random chance\. Check sequence definition"]
   ["524"]=["Error: could not parse conect id: .+"]
   ["525"]=["Error: conect row atom id not found: .+"]
   ["526"]=["PdbFile constructor could not open this file: .+"]
   ["527"]=["Prep file exists but couldn't be opened\."]
)
#
##
#  One grep string to check them all at once
GP_ALL_ERROR_GREP="userSelection \([^)]+\) for residue to glycosylate is incorrect format|Did not find a C1 or C2 with a foreign neighbor|doesn't have more than 1 residue|isn't supported\. Currently you can glycosylate|not found in residue .+ with atoms:|Did not find a residue with id matching|found more than 1 linkage to aglycone|sequence is empty:>>>|the cake is a lie:>>>|sequence contains a space:>>>|sequence cannot contain this:'[^']+':>>>|Did not find corresponding '[^']+' for character '[^']+' at position|SequenceParser can't read labeled sequences yet|sequence graph not fully connected|Did not find this Element in the list of atomic Elements|missing atomic mass for element|amino acid not found in metadata|[Ee]rror: different number of conformers in linkage|[Ee]rror: conformers have different weight in linkage|no connection atoms\.|missing dihedrals or metadata in residue linkage|Unknown rotamer type|required parent residue removed by random chance|could not parse conect id|conect row atom id not found|PdbFile constructor could not open this file|Prep file exists but couldn't be opened" 
## The following is an example use
#if grep -q -E \
#  "userSelection \([^)]+\) for residue to glycosylate is incorrect format|Did not find a C1 or C2 with a foreign neighbor|doesn't have more than 1 residue|isn't supported\. Currently you can glycosylate|not found in residue .+ with atoms:|Did not find a residue with id matching|found more than 1 linkage to aglycone|sequence is empty:>>>|the cake is a lie:>>>|sequence contains a space:>>>|sequence cannot contain this:'[^']+':>>>|Did not find corresponding '[^']+' for character '[^']+' at position|SequenceParser can't read labeled sequences yet|sequence graph not fully connected|Did not find this Element in the list of atomic Elements|missing atomic mass for element|amino acid not found in metadata|[Ee]rror: different number of conformers in linkage|[Ee]rror: conformers have different weight in linkage|no connection atoms\.|missing dihedrals or metadata in residue linkage|Unknown rotamer type|required parent residue removed by random chance|could not parse conect id|conect row atom id not found|PdbFile constructor could not open this file|Prep file exists but couldn't be opened" ${GP_Log} ; then
#    echo "Known Glycoprotein Builder domain error detected!"
#fi
