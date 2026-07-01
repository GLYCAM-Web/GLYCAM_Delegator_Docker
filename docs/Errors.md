# Errors

This error documentation applies to the users of the scripts provided for automating certain modeling
workflows, for example `Generate_GlycoProtein_From_PDB_ID_+_Links_List`(1). 

If you are doing custom work, these docs describe how the error-handling works for those scripts. You
can make use of the infrastructure if you want. See 'Custom Users' below for more.

(1) Right now, only the GlycoProtein script has these error reporting features.

### Overview

The scripts have methods for handling their own errors, but they also attempt to handle errors from the
external programs and scripts that they call. It is not possible to anticipate all problems.

If an error is detected from an external program, the error handling attempts to do two things:

1. Leave a message in a visible place that briefly announces the error.
2. Write a file, `Error_log.txt`, that contains details, in the project directory.

### Types of Errors Handled

This process concerns itself with errors that a user has some hope of addressing. If the code itself fails,
for example with a segmentation fault, these processes might be able to note that, but there will not be
any sort of detailed description.

### Descriptions of the Errors

Error descriptions that appear in normal code output have three parts:

- Number   - A number for easily referring to an error and for finding more information.
- Brief    - A short, 2-5 word, descriptive title for the error.
- Meaning  - A sentence-long, user-friendly description of the error.

Depending on the situation, all three parts might not be shown. Generally, the number is shown.

Other information is likely to be available in the docs folder:

- Path to the log file where the error was originally observed.
- Path to the source-code file where the error originated, with the line number.
- A representation of the error text in the source code, but without code-specific text.

The adventuresome user can also find:

- Grep strings for searching text for the error message.

### Numbers

99  : Number 99 indicates that multiple errors were detected.
      See the file `Error_log.txt` in the project directory.

500-599 : These numbers are reserved for the GlycoProtein Builder.


## Custom Users

In the mounts/sysetc/ directory, see `build_error.bash` and `GlycoProtein_Error_Dictionaries.bash` for 
examples of how to integrate built-in error handling into your workflows. 
