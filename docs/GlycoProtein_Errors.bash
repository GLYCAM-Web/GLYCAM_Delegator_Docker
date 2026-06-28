# Common GlycoProtein Builder User Errors

This is not a comprehensive list, but it comprises the main errors that a user is likely to see.

Please see the file `GlycoProtein_Error_Details.md` for the exact error text as well as the location of 
the error in the source code.

This file was generated with assistance from Gemini AI.

In the following table, a number in square brackets indicates a common error with a fix that might be 
easy for you. Please see the bottom of this file for details.

| Error Brief                         |   Meaning                                                                  |
|-------------------------------------|----------------------------------------------------------------------------|
| Incorrect Site Identifier Format    | The format used for your glycosylation site could not be understood.       |
| Missing Anomeric Carbon             | The anomeric carbon could not be found in a monosaccharide residue.        |
| Single-Residue Sugar Error          | Monosaccharides with an aglycon are expected to have at least 2 residues.  |
| Unsupported Glycosylation Site      | Glycosylation was requested for a residue other than ASN, THR, SER or TYR. |
| Missing Required Connection Atom    | A residue does not contain a key atom for making a connection.             |
| Missing Target Glycosite Residue    | The residue to be glycosylated could not be found.                         |
| Multiple Connections to an Aglycone | An aglycone with multiple monosaccharides is not supported.                |
| Empty Sequence                      | The provided sequence is empty.                                            |
| Easter Egg Validation Failure       | We found a cake in your sequence! And the cake is a lie!                   |
| Space Character inside Sequence     | Sequences cannot contain spaces.                                           |
| Forbidden Character in Sequence     | Your sequence contains a character that is not expected.                   |
| Mismatching Bracket Structure       | One of your brackets (of whatever type) was not part of a pair.            |
| Labeled Sequences Unsupported       | Sequences containing custom labels are not supported.                      |
| Sequence Graph Disconnectivity      | A part of your sequence could not be connected to the rest of it.          |
| Missing Element Definition [1]      | The element designation is unknown. [1]                                    |
| Missing Atomic Mass Metadata        | The code does not know the atomic mass for an element.                     |
| Missing Amino Acid Metadata         | This amino acid is not known to the code.                                  |
| Conformation Inconsistency          | The given and expected numbers of linkage conformers differs.              |
| Conformer Weight Mismatch           | The given and expected weights of linkage conformers differs.              |
| Disconnected Residues               | Two residues that were expected to connect cannot connect.                 |
| Missing Dihedral Angles/Metadata    | The dihedral angle probabilities for a linkage are not known.              |
| Unknown Rotamer Configuration Type  | The code does not know the meaning of the type given for a rotamer.        |
| Carbohydrate Parent Residue Removal | A parent residue was removed by chance, and likely by accident.            |
| PDB CONECT ID Parsing Failure       | A CONECT card in the PDB file could not be parsed.                         |
| PDB CONECT Atom Missing             | The atom's number was not found in the CONECT cards.                       |
| PDB File Open Failure               | The PDB file could not be opened/read.                                     |
| Prep File Read Failure              | The Prep file could not be opened/read.                                    |

[1] A workaround for this error is to remove all HETATM and ANISOU cards from the PDB file before processing.
