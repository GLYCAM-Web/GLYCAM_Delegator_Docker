# Errors

This error documentation applies to the users of the scripts provided for automating certain modeling
workflows, for example `Generate_GlycoProtein_From_PDB_ID_+_Links_List`(1). 

If you are doing custom work that does not use a built-in script, these docs might not apply. You can make 
use of the infrastructure if you want. See 'Custom Users' below for more.

(1) Right now, only the GlycoProtein script has these error reporting features.

### Overview

The scripts have methods for handling their own errors, but they also attempt to handle errors from the
external programs and scripts that they call. It is not possible to anticipate all problems.

If an error is detected from an external program, the error handling attempts to do two things:

1. Leave a message in a visible place that briefly announces the error.
2. Write a file, `error_logs/project_id_errors.txt`, that contains details, in the project directory.

### Types of Errors Handled

This process concerns itself with errors that a user has some hope of addressing. If the code itself fails,
for example with a segmentation fault, these processes might be able to note that, but there will not be
any sort of detailed description.

### Descriptions of the Errors

Error descriptions that appear in normal code output have three parts:

- Number   - A number for easily referring to an error and for finding more information.
- Brief    - A short, 2-5 word, descriptive title for the error.
- Meaning  - A sentence-long, user-friendly description of the error.

In files in the `error_logs` directory, the original error message will also appear.

Depending on the situation, all three parts might not be shown. Generally, the number is shown.

Other information is likely to be available in the docs folder:

- Path to the log file where the error was originally observed.
- Path to the source-code file where the error originated, with the line number.
- A representation of the error text in the source code, but without code-specific text.

The adventuresome user can also find:

- Grep strings for searching text for the error message.

### Numbers

#### Exit codes

Search on "standard linux exit codes" for more information about this standard class of errors.

0       : As is standard, zero indicates that there were no errors.

1       : As is standard, one indicates a general, unspecified error. 

2-255   : These errors are likely to be other standard errors with meanings specific to the process 
          that generated them. 

64-113  : Reserved for error exit codes related to the `GLYCAM_Delegator_Docker` software itself.

#### Error codes for `GLYCAM_Delegator_Docker`

To minimize confusion, errors reported by `GLYCAM_Delegator_Docker` do not use numbers in the range of 
normal exit codes. Generally, a single service will be allotted a range of one hundred codes starting 
with the same number, for example 500-599.

0       : Zero is also used here to indicate success.

n00     : The '00' of the allotted codes (e.g., 300, 400, etc.) indicates that everything went well in 
          terms of the process, but that the result is somehow undesirable. For example, the GlycoProtein
          builder might be unable to resolve all clashes in all attached glycans. This might be a correct
          result, but it is still something that the user probably wants to know. 

256-299 : Reserved for problems related to the `GLYCAM_Delegator_Docker` software itself that are not in a
          context where an exit code is appropriate. 

256     : The script or program could not execute properly. This is likely to be accompanied by and exit
          code of '1'. 

299     : Multiple errors were detected.  They will usually be listed in the file 
          `error_logs/<project_id>_errors.txt` in the project directory.

300-399 : Reserved for the Sequence Builder.

500-599 : Reserved for the GlycoProtein Builder.


## Custom Users

In the mounts/sysetc/ directory, see `build_error.bash` and `GlycoProtein_Error_Dictionaries.bash` for 
examples of how to integrate built-in error handling into your workflows. 
