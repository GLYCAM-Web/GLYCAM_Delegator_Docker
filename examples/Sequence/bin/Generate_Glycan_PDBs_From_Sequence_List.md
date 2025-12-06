# Documentation for `Generate_Glycan_PDBs_From_Sequence_List`

## Purpose of the script

Generate a set of PDB files containing 3D structures of glycans based on a list of sequences.

## How to use it

1. Place the proper inputs in the directory that appears at `/inputs/` inside the Docker container.
2. If desired, specify your output subdirectory, and any other desired custom settings, in the 
   SessionSettings.bash file.
3. TODO - write this and fill it in...  how to run the thing.


## Summary of mechanism

This script generates JSON files, suitable for use with the GEMS delegator, that request Evaluations 
from the Sequence entity. It submits the JSON files to the delegator, briefly inspects and summarizes 
the results, then places successfully generated PDB files into a convenient directory.

## Requirements for inputs

Input to this script is a file containing a comma-separated table. The table columns are:
  
    Filename Basename , Glycan Sequence in Glycam Condensed IUPAC Format

Other important information:
   
    -  The first line is ignored. Use it for headers or a title or leave it blank.
       -  If it helps your other programs, comment out the first line, etc. This script ignores it entirely.
    -  Avoid spaces anywhere in the file
    -  Filename Basenames:
       -  Keep them *NIX friendly (e.g., no spaces in the Basename)
       -  Use only the Basename, with no 'pdb' suffix - or your files will be named 'Basename.pdb.pdb'
       -  Keep them unique (at least within the same output directory)!
   
Sample first few lines of input:

    \"glytoucan_ac\",\"sequence_glycam_iupac\"
    \"G00024MO\",\"DGlcpb1-3DGlcpb1-3DGlcpb1-OH\"
    \"G00025MO\",\"DGlcpb1-4DGlcpb1-4DGlcpb1-4DGlcpb1-OH\"
    \"G00027MO\",\"DManpa1-3[DManpa1-6]DManpb1-4DGlcpNAcb1-OH\"

## Outputs

The output contains various files organized into subdirectories.

You will have (explicitly or by default) specified a parent directory for the outputs. It is called:

    OUT_SUBDIR

Here is a sample tree of that directory as viewed from within the Docker container. 

    /outputs/sequence/cb/${OUT_SUBDIR}
    ├── <DateTime_>Generate_Glycan_PDBs_From_Sequence_List_DB.csv
    ├── logs
    │   ├── details_${DateTime}_Generate_Glycan_PDBs_From_Sequence_List.log
    │   └── status_${DateTime}_Generate_Glycan_PDBs_From_Sequence_List.log
    ├── PDB
    │   └── GoodRequest.pdb
    └── provenance
        ├── BadRequest_request.json
        ├── BadRequest_response.json
        ├── GoodRequest_request.json
        └── GoodRequest_response.json

The tree above assumes that the input file contained one good request and one bad request. The good request 
resulted in a PDB file being made. The bad request did not. The 'provenance' directory records the JSON files
that were used as input to the delegator and the responses. 

At the top of the tree are the database of activity in the current directory and the directory containing logs
resultinf from the activity. Optionally, the database can be prepended with a date-time entry. The logs are 
always given date-time stamps.

The activity database is a comma-separated table with these columns:

     - Basename             -  The basename of the PDB file
     - Sequence_Provided    -  The sequence provided in the input file
     - Sequence_Processed   -  The index-ordered sequence from the JSON reponse
     - sequence_ID          -  The GLYCAM sequence identifier
     - pUUID                -  The project identifier assigned to the build
     - conformerID          -  The identifier for the conformer present in the PDB file
     - Result               -  The script's opinion of whether the PDB generation was successful
     - date-time            -  The date and time when the current line was written
     - Note                 -  Possibly useful information if something went wrong

The log files:

     - details_${DateTime}_Generate_Glycan_PDBs_From_Sequence_List.log

       Contains detailed information about the processing of each sequence.       

     - status_${DateTime}_Generate_Glycan_PDBs_From_Sequence_List.log

       Contains summary information regarding the status of each build.

## Note that inside the Docker container:

     - INPUTS_DIR is always '/inputs/'.
     - OUTPUTS_DIR is always '/outputs/'.
     - WORK_DIR is always '/work/'.

By default, these live in the `inputs-outputs` directory.  As with all capabilities of this software, you 
can override these locations. Keep in mind that the script doing the processing has no idea where on your 
host these directories reside.









