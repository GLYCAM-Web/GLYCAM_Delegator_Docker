# Configurable Aspects

Many of the aspects of the functioning of this software can be customized. This document introduces
a few that are likely to be of interest. 

Configuration is handled by allowing the user to add files that are not tracked by the repository.

Example files can be found here:

```
./examples/configs-settings/
```

## Example: Multiple containers for the same user

If you want to run multiple instances of this software on the same machine and as one user, then the
container name `username-delegator_interactive` will not be sufficient (of course, substitute your
username for 'username'). Docker will not allow multiple containers to have the same name.

The container name is set in the file `settings.bash`:

```
$ grep CONTAINER settings.bash 
CONTAINER_PREFIX="${PREFIX}-${SERVICE}"
export HOST_NAME="${CONTAINER_PREFIX}"
export CONTAINER_NAME="${CONTAINER_PREFIX}"
```

You can override this by making a file called LocalSettings.bash and overriding the `CONTAINER_NAME`
variable. You could do this by assigning a number to each instance:

```
grep CONTAINER LocalSettings.bash
export CONTAINER_NAME="${CONTAINER_PREFIX}-1"
```

## Example: Changing the logging level

By default, the logging level is 'error' (will only log errors). If you are trying to troubleshoot, you
might want more data. If you want to set the logging level higher, you can also add that to the
`LocalSettings.bash` file. 

```
$ cat LocalSettings.bash 
GEMS_LOGGING_LEVEL='debug'
```

## Tip

To find out what can be overriden in the `LocalSettings.bash` file, inspect the `settings.bash` file.

Note! Be aware of dependencies. Consider this series from above:

```
$ grep CONTAINER settings.bash
CONTAINER_PREFIX="${PREFIX}-${SERVICE}"
export HOST_NAME="${CONTAINER_PREFIX}"
export CONTAINER_NAME="${CONTAINER_PREFIX}"
```

If you override `CONTAINER_PREFIX` in your `LocalSettings.bash` file, the `CONTAINER_NAME` will not change.
This is because the `CONTAINER_NAME` is set before `LocalSettings.bash` is read. 

## Example: Changing the output subdirectory

In the examples, we saw that the default name for the output subdirectory is date-time based, e.g.:

```
outputs/
└── sequence
    └── cb
        └── 2025-12-07-02-12
            ├── 2025-12-07-02-12_Generate_Glycan_PDBs_From_Sequence_List_DB.csv
            ├── logs
            ├── PDB
            └── provenance
```

If you want the directory to be `MyFavoriteOutput` rather than `2025-12-07-02-12`, you can use the 
`SessionSettings.bash` file.

_Note!_  This file lives in the `deps/share` subdirectory, but a symbolic link is added to the top level
directory as a convenience.

```
$ cat SessionSettings.bash 
export OUT_SUBDIR="MyFavoriteOutput"
```


