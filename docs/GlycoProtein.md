# GlycoProtein Builder Docs

## Can be run either interactively or as a command.

### As a command:

```
bash bin/run_command.bash Generate_GlycoProtein_From_PDB_ID_+_Links_List </container/path/to/input_file>
```

### Interactively

```
bash bin/run_interactive.bash
# [ once inside the container ]
Generate_GlycoProtein_From_PDB_ID_+_Links_List </container/path/to/input_file>
```

### To print the usage statement

Just use either method above, but do not supply the path to an input file.

### To run the test

From the command line:

```
bash tests/GlycoProtein/run_test.bash
```

### Pro-tip

Check out the file `tests/GlycoProtein/SessionSettings_gitkeep_.bash` for some available control options.

## The USAGE statement

```
USAGE:

   Generate_GlycoProtein_From_PDB_ID_+_Links_List <Input-File>

Generate a set of PDB files containing 3D structures of glycoproteins based on a list of PDB IDs, linkage sites, and sequences.

    Input-File format: 
   
        Comma-separated table containing columns with the parsed headers, in any order. 
 
          -  !! The first line must contain headers.
          -  If a header entry starts with a hash ('#'), the hash will be removed before processing. 

        Parsed headers: 

            -  Headers can be in any order. Non-parsed headers can be present.
            -  Parsed headers must be spelled as shown below.
            -  For convenience below, parsed headers are listed in order of requirement status.

            (*) : required column
            (!) : possibly required column
            (+) : recommended column
            (-) : optional column
        
            pdb_id (*) : The PDB ID used in the wwPDB at rcsb.org.

            amino_acid_chain (*) : The Chain ID (typically a capital letter) for the chain containing the residue to glycosylate.

            glycosylation_site_pdb (*) : The Residue Number of the residue to be glycosylated.

            sequence_glycam_iupac (*) : The glycan to place at the site in GLYCAM Condensed IUPAC format.

            insertion_code (!) : The Insertion Code (IC) of the residue to be glycosylated. Might be required.
              -  If none of your residues have insertion codes, this column can be omitted.
              -  If your residues contain insertion codes, they MUST BE GIVEN. The residue cannot be uniquely
                 identified without the IC.
                 -  You can add the IC to the end of the residue number. For example, residue 85 with IC 'E' can be written '85E'.
                 -  Here is a nice explanation of ICs:
                    https://bioinformatics.stackexchange.com/questions/11587/what-is-the-aim-of-insertion-codes-in-the-pdb-file-format

            start_aa || amino_acid_pdb (+) : The PDB-style three-letter-code for the amino acid to glycosylate. Recommended.
              -  Header can have either name. It will be 'amino_acid_pdb' in outputs.
              -  This is not used. If you get an error message about the site, it might be useful to have this handy.

            glycosylation_type (+) : The type of linkage to the amino acid. Recommended.
              -  This is not used. If you get an error message about the site, it might be useful to have this handy.

            project_id (-) : Preferred key to identify a glycoprotein build. Also called the Basename. Optional.
              -  Keep it *NIX friendly (e.g., no spaces, asterisks, etc.)
              -  Use only the project_id you want for output files, no 'pdb' suffix - or your files will be named 'project_id.pdb.pdb'
              -  This name will also be used for error outputs, histories, results db, etc.
              -  IF MISSING - the basename/project_id will be the pdb_id. See also notes on filenames and uniprotkb_canonical_ac.

            uniprotkb_canonical_ac (-) : Uniprot Knowledgebase Canonical Accession identifier. 
              -  If this is present, and if the project_id is NOT present, then the project_id will be: 'uniprotkb_canonical_ac'_'pdb_id'
                 -  For example, if uniprotkb_canonical_ac='P13671-1' and pdb_id='3T5O', project_id='P13671-1_3T5O'
              -  If the project_id column is populated, that project_id will not be overwritten.

        Notes on input file parsing:

          -  Input errors include:
             -  Required Headers columns are missing. 
                -  This will cause the entire process to stop. No lines will be processed.
             -  Duplicate lines : The associated project_id will not be processed. 
             -  More than one pdb_id per uniprotkb_canonical_ac : The relationship must be 1:1. The associated project_id will not be processed.
                - If you want to have multiple pdb_id's associated with a single uniprotkb_canonical_ac, you must use the project_id field to
                  separate them into distinct projects.
             -  The presence of a project_id column, but the column contains one or more entries that are empty or 'null'.
                -  This will cause the entire process to stop. No lines will be processed.
          -  The lines in the file will be sorted. 
             -  This simplifies finding other input errors.
             -  It also means that the order of the outputs will be sorted by the first Parsed Header column in the input.
          -  The modified data are always written to the Treated_Input subdirectory.
          -  Errors and non-trivial / non-documented changes will be logged in detail.
             -  Example : Your file contains duplicate lines.
                -  The status log file will contain only a reference to the situation.
                -  The main log file (the 'details' log) will contain a listing of all lines that were not processed.
                   - This includes all lines associated with the project, duplicated or not.
                   - The duplicated line(s) and the number of duplicates for each line will be noted.
          -  Documented and trivial changes will be logged only tersely.
             -  Example : Your file contains uniprotkb_canonical_ac and pdb_id but NOT project_id:
                -  The log files will note that the project_id is being assigned based on uniprotkb_canonical_ac and pdb_id.
                -  They will not enumerate every new project_id because those are visible in Treated_Input/.

     
        Samples of first few lines of input:

          Minimal input file:
            -  Note that if any glycosylation site has an insertion code as part of its name, it must be included!
               This example does not include the insertion code.

pdb_id,amino_acid_chain,glycosylation_site_pdb,sequence_glycam_iupac
3T5O,A,17,DGlcpb1-3LFucpa1-OH
4E0S,B,17,DGlcpb1-3LFucpa1-OH
3VN4,A,115,DGlcpb1-3LFucpa1-OH
6RUR,A,65,DGlcpb1-3LFucpa1-OH
6RUR,C,65,DGlcpb1-3LFucpa1-OH
6RUR,D,18,DGlcpb1-3LFucpa1-OH
6RUR,B,18,DGlcpb1-3LFucpa1-OH

          Input file with other columns (parsed and not parsed):

#project_id,glycosylation_type,pdb_id,my_special_column,amino_acid_chain,glycosylation_site_pdb,start_aa,sequence_glycam_iupac
my_gp_1,O-linked,3T5O,my_info,A,17,THR,DGlcpb1-3LFucpa1-OH
my_gp_2,O-linked,4E0S,my_info,B,17,THR,DGlcpb1-3LFucpa1-OH
my_gp_3,O-linked,3VN4,my_info,A,115,SER,DGlcpb1-3LFucpa1-OH
my_gp_4,O-linked,6RUR,my_info,A,65,THR,DGlcpb1-3LFucpa1-OH
my_gp_4,O-linked,6RUR,my_info,C,65,THR,DGlcpb1-3LFucpa1-OH
my_gp_4,O-linked,6RUR,my_info,D,18,THR,DGlcpb1-3LFucpa1-OH
my_gp_4,O-linked,6RUR,my_info,B,18,THR,DGlcpb1-3LFucpa1-OH

          Sample input file error: 
            -  Here, a Uniprot ID is used as the project_id. but it refers to two different PDB IDs. This will cause an error.
 
!!   #project_id,glycosylation_type,pdb_id,my_special_column,amino_acid_chain,glycosylation_site_pdb,start_aa,sequence_glycam_iupac
!!   P13671-1,38,Thr,G36855WW,O-linked,3T5O,pdb_00003t5o,A,17,38,38,THR,THR,T,DGlcpb1-3LFucpa1-OH
!!   P13671-1,38,Thr,G36855WW,O-linked,4E0S,pdb_00004e0s,B,17,38,38,THR,THR,T,DGlcpb1-3LFucpa1-OH
 
  Outputs: various files
  
    Mostly, you will be interested in: 
    - PDB files : ${OUTPUTS_DIR}/conjugate/gp/${OUT_SUBDIR}/PDB/
    - Treated input files, if any : ${OUTPUTS_DIR}/conjugate/gp/${OUT_SUBDIR}/Treated_Inputs

    Note that inside the Docker container:
    - INPUTS_DIR is always '/inputs/'.
    - OUTPUTS_DIR is always '/outputs/'.
    - WORK_DIR is always '/work/'.
   
    Also there are:
    - Provenance trail: ${OUTPUTS_DIR}/conjugate/gp/$OUT_SUBDIR/provenance/
    - Build DB: ${OUTPUTS_DIR}/conjugate/gp/$OUT_SUBDIR/Generate_GlycoProtein_From_PDB_ID_+_Links_List_DB.csv  
      - Where "Generate_GlycoProtein_From_PDB_ID_+_Links_List" is the name of this script.
      - This will contain sufficient information to easily determine where to find the structure's provenance.
      - This provenance info is also in the ${responseJSON} in the provenance directory, but that's not as easy to read.
      - Contents:
        - Comma-separated table of: (still TBD)

    For those who need all the details:
    - The workspace for generating the structures: ${WORK_DIR}/conjugate/gp/${pUUID}/
      - You can find the value of ${pUUID} in the ${responseJSON} in the provenance directory.

```
