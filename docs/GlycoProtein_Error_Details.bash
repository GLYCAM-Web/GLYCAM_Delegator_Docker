# GlycoProtein Builder Error Message Details

These are tables providing additional information about GP Builder error messages.

After the message detail tables, there is a table for the locations of source code files relative to 
the GMML2 root directory.

The tables are not in any obvious order. It is best to search the file for your error message. 

Using grep is probably the best method for finding information, e.g.:

```
grep 'Single-Residue Sugar Error' GlycoProtein_Error_Details.md
```

This file was generated with assistance from Gemini AI.


## Message Details Tables

### Full Message

| Brief Message                       | Full Message                                                                                                                                                             |
|-------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Incorrect Site Identifier Format    | `userSelection (<userSelection>) for residue to glycosylate is incorrect format. Must be chain_residueNumber_insertionCode. InsertionCode is optional...`                |
| Missing Anomeric Carbon             | `Did not find a C1 or C2 with a foreign neighbor in residue: <residueStringId>, thus no anomeric atom was found.`                                                        |
| Single-Residue Sugar Error          | `Reducing residue and aglycone requested for Carbohydrate with name <glycanName>, but it doesn't have more than 1 residue`                                               |
| Unsupported Glycosylation Site      | `Problem creating glycosylation site. The amino acid requested: <residueId> has name (<name>) that isn't supported. Currently you can glycosylate ASN, THR, SER or TYR.` |
| Missing Required Connection Atom    | `Error: atom '<name>' not found in residue <residueId> with atoms: <list of atoms>`                                                                                      |
| Missing Target Glycosite Residue    | `Error: Did not find a residue with id matching <proteinResidueId>`                                                                                                      |
| Multiple Connections to an Aglycone | `Error: found more than 1 linkage to aglycone in <glycanInput>`                                                                                                          |
| Empty Sequence                      | `Error: sequence is empty:>>><sequence><<<`                                                                                                                              |
| Easter Egg Validation Failure       | `Error: the cake is a lie:>>><sequence><<<`                                                                                                                              |
| Space Character inside Sequence     | `Error: sequence contains a space:>>><sequence><<<`                                                                                                                      |
| Forbidden Character in Sequence     | `Error: sequence cannot contain this:'<char>':>>><sequence><<<`                                                                                                          |
| Mismatching Bracket Structure       | `Did not find corresponding '<bracket>' for character '<bracket>' at position <index> of sequence: <sequence>`                                                           |
| Labeled Sequences Unsupported       | `Error: SequenceParser can't read labeled sequences yet: <sequence>`                                                                                                     |
| Sequence Graph Disconnectivity      | `Error: sequence graph not fully connected`                                                                                                                              |
| Missing Element Definition          | `Did not find this Element in the list of atomic Elements: <element>`                                                                                                    |
| Missing Atomic Mass Metadata        | `Error: missing atomic mass for element: <element>`                                                                                                                      |
| Missing Amino Acid Metadata         | `Error: amino acid not found in metadata: <name>`                                                                                                                        |
| Conformation Inconsistency          | `error: different number of conformers in linkage: <linkage_details>`                                                                                                    |
| Conformer Weight Mismatch           | `error: conformers have different weight in linkage: <linkage_details>`                                                                                                  |
| Disconnected Residues               | `Two residues passed into findResidueLink that have no connection atoms.`                                                                                                |
| Missing Dihedral Angles/Metadata    | `missing dihedrals or metadata in residue linkage: <linkage_details>`                                                                                                    |
| Unknown Rotamer Configuration Type  | `Error: Unknown rotamer type: <type>`                                                                                                                                    |
| Carbohydrate Parent Residue Removal | `Error: required parent residue removed by random chance. Check sequence definition`                                                                                     |
| PDB CONECT ID Parsing Failure       | `Error: could not parse conect id: <line>`                                                                                                                               |
| PDB CONECT Atom Missing             | `Error: conect row atom id not found: <line>`                                                                                                                            |
| PDB File Open Failure               | `PdbFile constructor could not open this file: <pdbFilePath>`                                                                                                            |
| Prep File Read Failure              | `Prep file exists but couldn't be opened.`                                                                                                                               |


### Location In Source Code

| Brief Message                       | File                        | Line |
|-------------------------------------|-----------------------------|------|
| Incorrect Site Identifier Format    | glycoproteinCreation.cpp    | 64   |
| Missing Anomeric Carbon             | glycoproteinCreation.cpp    | 115  |
| Single-Residue Sugar Error          | glycoproteinCreation.cpp    | 136  |
| Unsupported Glycosylation Site      | glycoproteinCreation.cpp    | 153  |
| Missing Required Connection Atom    | glycoproteinCreation.cpp    | 202  |
| Missing Target Glycosite Residue    | glycoproteinCreation.cpp    | 268  |
| Multiple Connections to an Aglycone | glycoproteinCreation.cpp    | 322  |
| Empty Sequence                      | sequenceParser.cpp          | 207  |
| Easter Egg Validation Failure       | sequenceParser.cpp          | 211  |
| Space Character inside Sequence     | sequenceParser.cpp          | 215  |
| Forbidden Character in Sequence     | sequenceParser.cpp          | 223  |
| Mismatching Bracket Structure       | sequenceParser.cpp          | 229  |
| Labeled Sequences Unsupported       | sequenceParser.cpp          | 412  |
| Sequence Graph Disconnectivity      | sequenceManipulation.cpp    | 357  |
| Missing Element Definition          | elements.cpp                | 314  |
| Missing Atomic Mass Metadata        | elements.cpp                | 244  |
| Missing Amino Acid Metadata         | aminoAcids.cpp              | 272  |
| Conformation Inconsistency          | residueLinkageCreation.cpp  | 133  |
| Conformer Weight Mismatch           | residueLinkageCreation.cpp  | 145  |
| Disconnected Residues               | residueLinkageCreation.cpp  | 205  |
| Missing Dihedral Angles/Metadata    | residueLinkageCreation.cpp  | 294  |
| Unknown Rotamer Configuration Type  | residueLinkageFunctions.cpp | 41   |
| Carbohydrate Parent Residue Removal | carbohydrate.cpp            | 360  |
| PDB CONECT ID Parsing Failure       | pdbFile.cpp                 | 37   |
| PDB CONECT Atom Missing             | pdbFile.cpp                 | 43   |
| PDB File Open Failure               | pdbFile.cpp                 | 212  |
| Prep File Read Failure              | prepFile.cpp                | 33   |



## File locations relative to the GMML2 root directory.

```
src/carbohydrate/                                carbohydrate.cpp
src/CentralDataStructure/residueLinkage/         residueLinkageCreation.cpp
                                                 residueLinkageFunctions.cpp
src/fileType/lib/                                libraryFile.cpp
             pdb/                                pdbFile.cpp
             prep/                               prepFile.cpp
src/glycoprotein/                                glycanShape.cpp
                                                 glycoproteinCreation.cpp
src/metadata/                                    aminoAcids.cpp
                                                 elements.cpp
src/sequence/                                    sequenceManipulation.cpp
                                                 sequenceParser.cpp
```

