# Standalone GLYCAM Website Modeling Engine Using Docker

This software provides a standalone version of the engine used by GLYCAM Web [[glycam.org]] to build 
molecular models. 

_Prithee gentle Docker aficionados, read this:_

This software uses Docker in a non-standard manner. Its makers fully understand and appreciate the beauty 
of packaging all requirements for a task into a single image. Our needs and workflows do not necessarily
benefit from complete encapsulation. Aside from the fact that a fully-self-contained image for this project
would top 10 GB, it also means that we must spin up a container every time we need to look into the code
to figure out what went wrong and what to fix. Science is messy and its software is a moving target. That 
is why the Docker image contains all the stable requirements, but the scientific parts are mounted into
the running container rather than being part of it. Note that the code outside the container will not 
necessarily run anywhere except in the environment of the container. It's just visible outside.

## Prerequisites

Although not strictly required, a **Linux operating system** will be easier for you, and we will have an easier 
time helping you if you have trouble.

You need to install:

- [Docker Engine](https://docs.docker.com/engine/install/), preferred, or [Docker Desktop](https://docs.docker.com/desktop/)
  if Docker Engine is not feasible for you.
- [BASH](https://en.wikipedia.org/wiki/Bash_(Unix_shell)). This is usually preinstalled in all Linux variants and
  is easily obtainable in most MacOS and Windows installations.
- [Git](https://git-scm.com/install/), which is available for most every system.

Although the software will take care of most Docker actions for you, it will be helpful if you learn the basics of Docker. It
is always useful to know Git and BASH, but you need more knowledge of BASH than Git.

## Obtaining 

Use this command, in a terminal, or its equivalent for your system:

```
git clone https://github.com/GLYCAM-Web/GLYCAM_Delegator_Docker.git 
```

Alternately, go to [the repo](https://github.com/GLYCAM-Web/GLYCAM_Delegator_Docker) and use whatever method is your favorite.

## Installing

```
cd GLYCAM_Delegator_Docker
./Install.bash
```

## Key Concepts

There are many ways to use this software. First, there are a few key concepts to understand.

### Running Commands

Although many commands are located in subdirectories, they are written to be used from the main directory, e.g.,
the `GLYCAM_Delegator_Docker` directory that you got when you cloned the repo. There are usage examples below.

They are kept in subdirectories so that the main directory does not become cluttered. It is convenient to limit
the number of tasks that any one script does, so there are many scripts.

### Files and Directories

The scientific parts of the software are not built into the Docker image. For that reason, they must be mounted into
the containers at runtime.  The directories containing input and output are also mounted into the containers.

_Important:_ The paths inside the container are not the same as they are outside (on the host machine).

In the following table, all host-machine paths are relative to the `GLYCAM_Delegator_Docker` directory.

| Path on Host Machine     | Can Change? | Inside Container | Used for                                              | 
|--------------------------|-------------|------------------|-------------------------------------------------------|
| ./deps/                  | No          | /programs/       | Dependencies that should not be part of the main repo |
| ./input-output/inputs/   | Yes         | /inputs/         | User-supplied inputs                                  |
| ./input-output/outputs/  | Yes         | /outputs/        | Outputs from wrapper scripts and post-processors      |
| ./input-output/tests/    | Yes         | /tests/          | A convenient place to test custom user scripts, etc.  |
| ./input-output/work/     | Yes         | /work/           | Where the website engine saves its output             |
| ./mounts/installers/     | No          | /installers/     | Code used to install non-image dependencies           |
| ./mounts/sysetc/         | No          | /sysetc/         | Information useful to scripts provided by the repo    |
| ./mounts/sysbin/         | No          | /sysbin/         | Scripts provided by the repo                          |


If desired, the locations on the host machine of all the input-output subdirectories can be configured by 
the user. The user can also place custom scripts and code inside the subdirectories of `./deps/`. 

The important thing to note is that if a file, for example `marco.json`, is visible at this location outside the container:

` /absolute/path/to/your/GLYCAM_Delegator_Docker/input-output/inputs/marco.json `

...it will be visible to all processes inside the container at:

` /inputs/marco.json `

When starting commands to be run inside the container, please be aware of these mappings. There are examples below.

### Configurable Settings

Many settings, indeed most of them, can be overridden by the user. Be sure to consult any custom settings you might
have set when things behave differently that what you expect.

See [Configuration.md](./docs/Configuration.md) for details.

### Examples

Numerous sample inputs and configuration examples are available in the `examples` subdirectory.

### Logs

If things do not go as expected, consult the contents of the `./logs/` subdirectory.

## Using

These are the commands you are most likely to use:

```
./bin/run_interactive.bash   ##  Puts you into an interactive shell inside the container. Takes no arguments.

./bin/run_command.bash       ##  Runs the command, with arguments, that immediately follows on the command line.
```

You must run them from the `GLYCAM_Delegator_Docker` directory. If you change to the `GLYCAM_Delegator_Docker/bin`
directory, they are not guaranteed to work.

### Test Basic Function

In this section, we will run a simple command two different ways.

#### Copy in an input file

`cp ./examples/marco_polo.json ./input-output/inputs`

For GEMS, the `marco` service is sort-of like `ping`. It is the way to know that you are successfull getting json
to GEMS and that GEMS is able to return output. If succesful, you should get a json object containing the message 'polo'.

#### Try the interactive shell

To enter the interactive shell, simply enter this command:

`./bin/run_interactive.bash`

If all goes well, you will see something like this:

```
$ ./bin/run_interactive.bash 
[+] up 2/2
 ✔ Network glycam_delegator_docker_default Created 
 ✔ Container lachele-delegator_interactive Created 
container is up
glycam@lachele-delegator:/$ 
```

In the above, 'lachele' will be replaced by your username.

Try running marco-polo. Enter this command:

```
delegate /inputs/marco_polo.json 
```

Now you know why it is called `GLYCAM_Delegator_Docker`! 

GEMS is designed to have a simple and consistent interface. The `delegate` command takes in, and returns, 
only json objects. The command is called 'delegate' because the Delegator service inspects the json object 
and decides which `gemsModule` should be tasked with fulfilling the requested service.

If things go well, the interaction should look like this:

```
glycam@lachele-delegator:/$ delegate /inputs/marco_polo.json 
{"entity": {"type": "Delegator", "services": {"Default_Marco": {"type": "Marco", "myUuid": "20a8d10c-0a6e-4533-90a5-6f4c5bc18b78", "inputs": {"entity": null, "who_I_am": null}}}, "responses": {"Default_Marco": {"type": "Marco", "myUuid": "20a8d10c-0a6e-4533-90a5-6f4c5bc18b78", "outputs": {"message": "Polo", "info": null}}}, "procedural_options": {"context": "default", "force_serial_execution": true, "pretty_print": false, "md_minimize": false}}, "notices": {}}glycam@lachele-delegator:/$ 
glycam@lachele-delegator:/$ 
```

Note that the json object does not terminate with a new-line. That is expected; just hit enter again. Look at the json and find the 'Polo' response.

Now exit the container by entering:

```
exit
```

Doing that might take longer than you expect. The result should look like:

```
glycam@lachele-delegator:/$ exit
exit
exiting container and stopping service
[+] down 2/2
 ✔ Container lachele-delegator_interactive Removed  
 ✔ Network glycam_delegator_docker_default Removed 
```

#### Do that same thing from the command line

To run marco from the command line:

```
./bin/run_command.bash delegate /inputs/marco_polo.json
```

The process should look like:

```
$ ./bin/run_command.bash delegate /inputs/marco_polo.json
Using this as the command given to docker compose:
 delegate /inputs/marco_polo.json
[+] up 2/2
 ✔ Network glycam_delegator_docker_default     Created 
 ✔ Container lachele-delegator_running-command Created 
Attaching to lachele-delegator_running-command
lachele-delegator_running-command  | {"entity": {"type": "Delegator", "services": {"Default_Marco": {"type": "Marco", "myUuid": "b0bcee54-0a71-418b-9c05-244b590ddd56", "inputs": {"entity": null, "who_I_am": null}}}, "responses": {"Default_Marco": {"type": "Marco", "myUuid": "b0bcee54-0a71-418b-9c05-244b590ddd56", "outputs": {"message": "Polo", "info": null}}}, "procedural_options": {"context": "default", "force_serial_execution": true, "pretty_print": false, "md_minimize": false}}, "notices": {}}
lachele-delegator_running-command exited with code 0
container is up
[+] down 2/2
 ✔ Container lachele-delegator_running-command Removed 
 ✔ Network glycam_delegator_docker_default     Removed 
```

### Use A Wrapper Script 

In this section, we will use a provided wrapper script to generate PDB files for some glycans in a list.

The wrapper file that we will use is called `Generate_Glycan_PDBs_From_Sequence_List`. It needs an input file.
Put one of the example input files into the inputs directory:

```
cp ./examples/Sequence/inputs/short_glycan_input.csv ./input-output/inputs/
```

The file contains the [GlyTouCan](https://glytoucan.org/) accession number and the GLYCAM condensed IUPAC 
notation for nine common glycans. 

If you want to view the file, `cat` is easy:

```
$ cat ./input-output/inputs/short_glycan_input.csv
"glytoucan_ac","sequence_glycam_iupac"
"G00024MO","DGlcpb1-3DGlcpb1-3DGlcpb1-OH"
"G00025MO","DGlcpb1-4DGlcpb1-4DGlcpb1-4DGlcpb1-OH"
"G00027MO","DManpa1-3[DManpa1-6]DManpb1-4DGlcpNAcb1-OH"
"G00031MO","DGalpb1-3DGalpNAca1-OH"
"G00033MO","DGalpb1-3[DGlcpNAcb1-6]DGalpNAca1-OH"
"G00035MO","DGlcpNAcb1-3DGalpNAca1-OH"
"G00037MO","DGlcpNAcb1-3[DGlcpNAcb1-6]DGalpNAca1-OH"
"G00039MO","DGalpNAca1-3DGalpNAca1-OH"
"G00041MO","DGlcpNAcb1-6DGalpNAca1-OH"
```

Now, run the wrapper script with that file as an argument. Remember that the input file path must be the
path inside the container!

```
$ ./bin/run_command.bash Generate_Glycan_PDBs_From_Sequence_List /inputs/short_glycan_input.csv
###########
must push gems change before these can work

```
###########
###########
PUSH THE GEMS CHANGES!
###########

#### Find the output

The wrapper script makes it easy for you to request a build and then to retrieve only the results that
interest you. But, the modeling engine does the same amount of work nonetheless. This output is stored in
the `/work/` directory in a tree with this structure:

```
work/
└── sequence
    └── cb
        ├── Builds
        │   ├── 03bad31f-b1c2-4372-8c40-f4502a4ab338
        │   ├── 07c4cebb-93cf-4b4e-8c49-76664f9cb8b7
        │   ├── 8f1dafaf-c836-4fca-b61e-c57403bf638d
        │   ├── a00814dc-cb0c-4dda-864c-c51b50c6cb4b
        │   └── fcfdd556-c12b-40a0-b920-aec9eef4de79
        └── Sequences
            ├── 4d3d242c-4b2a-5437-b02f-1a1661776bba
            └── fc6085c0-822c-5655-b5be-88da496814cb
```

The Builds directories contain individual requests for a 3D model. The Sequences directories contain 
information about unique sequences. Of course, there might be many Builds for each Sequence.

For consistency and organizational reasons, the output from the wrapper script mimics the organization
of the output from the Sequence Entity.  The specific nature of the output will vary depending on the 
task, so the correlation isn't 1-to-1. In the current example, the wrapper script only collected the
minmized PDB files for the default conformer. It copied them from the relevant place in the `work` tree
and put them into the PDB directory in the `outputs` tree.

By default, service directories under 'outputs' are named for the date and time when they were requested. 
Users can override this behavior.

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

In the tree above, the directory named `2025-12-07-02-12` represents the user's request for the service.
The csv file just beneath contains a summary of the status of the requested PDB files. The logs directory
contains details that can be useful for troubleshooting. As mentioned above, the PDB directory contains
the PDB files. The provenance directory contains the json request objects that were sent to Delegator and 
the json objects that were returned in response. If the process needs to be repeated, it should only be
necessary to send the request json once more to Delegator. This procedure is the next example.

### Delegate a Build

In this section, we will send to the Delegator a json object requesting that the 3D structures for several 
sequence conformers be built.  We will inspect the input json and the resulting directory tree.

#### Copy and inspect the request json

Copy the file from the examples tree into the inputs directory:

```
cp examples/Sequence/inputs/multi-conformer-build.json input-output/inputs/
```

View the json. If you can open it in vim or in a special viewer for json, it will be much easier to parse.

But, here it is. It's large, but nowhere near the size of the response! 


```
{
        "entity": 
        {
                "type": "Sequence", 
                "services": 
                {
                        "build": 
                        {
                                "type": "Build3DStructure"
                        }
                }, 
                "inputs": 
                {
                        "sequence": 
                        {
                                "payload": "DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-4]DManpa1-3[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-6]DManpa1-6]DManpb1-4DGlcpNAcb1-4DGlcpNAcb1-OH"
                        }, 
                        "geometryOptions": 
                        {"linkages": 
                                {
                                        "linkageRotamerInfo": 
                                        {
                                                "singleLinkageRotamerDataList": 
                                                [
                                                        {
                                                                "indexOrderedLabel": "3", 
                                                                "linkageLabel": "3", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg"]
                                                                        }
                                                                ]
                                                        }, 
                                                        {
                                                                "indexOrderedLabel": "4", 
                                                                "linkageLabel": "4", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg"]
                                                                        }
                                                                ]
                                                        }, 
                                                        {
                                                                "indexOrderedLabel": "6", 
                                                                "linkageLabel": "6", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "phi", 
                                                                                "dihedralValues": ["t"]
                                                                        }, 
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg"]
                                                                        }
                                                                ]
                                                        }, 
                                                        {
                                                                "indexOrderedLabel": "9", 
                                                                "linkageLabel": "9", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "phi", 
                                                                                "dihedralValues": ["t"]
                                                                        }, 
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg"]
                                                                        }
                                                                ]
                                                        }, 
                                                        {
                                                                "indexOrderedLabel": "13", 
                                                                "linkageLabel": "13", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "phi", 
                                                                                "dihedralValues": ["t"]
                                                                        }, 
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg"]
                                                                        }
                                                                ]
                                                        }, 
                                                        {
                                                                "indexOrderedLabel": "16", 
                                                                "linkageLabel": "16", 
                                                                "selectedRotamers": 
                                                                [
                                                                        {
                                                                                "dihedralName": "phi", 
                                                                                "dihedralValues": ["t", "-g"]
                                                                        }, 
                                                                        {
                                                                                "dihedralName": "omg", 
                                                                                "dihedralValues": ["gg", "gt"]
                                                                        }
                                                                ]
                                                        }
                                                ]
                                        }
                                }
                        }, 
                        "buildOptions": 
                        {
                                "mdMinimize": "True"
                        }
                }
        }, 
        "prettyPrint": "True", 
        "mdMinimize": "True"
}
```

Near the end, notice the part that contains this information:


```
    "indexOrderedLabel": "16",
    "linkageLabel": "16",
    "selectedRotamers":
    [
            {
                    "dihedralName": "phi",
                    "dihedralValues": ["t", "-g"]
            },
            {
                    "dihedralName": "omg",
                    "dihedralValues": ["gg", "gt"]
            }
    ]
```

This means that the user wants the linkage numbered 16 (we'll learn how to understand that in a second) to
have its phi angle set to "t" (trans) and to "-g" (minus gauche) and its omega angle set to "gg" (gauche-gauche)
and to "gt" (gauche-trans). Since there are two options for phi and two for omega, a total of four (2x2) 
conformers have been requested.

About the linkage - In an evaluation step, this would have been present in the response:

```
          "indexOrderedLabeled": "DNeup5Ac&Label=residue-18;a2-6&Label=link-16;DGalp&Label=residue-17;b1-4&Label=link-15;DGlcpNAc&Label=residue-16;b1-2&Label=link-14;[DNeup5Ac&Label=residue-15;a2-6&Label=link-13;DGalp&Label=residue-14;b1-4&Label=link-12;DGlcpNAc&Label=residue-13;b1-4&Label=link-11;]DManp&Label=residue-12;a1-3&Label=link-10;[DNeup5Ac&Label=residue-11;a2-6&Label=link-9;DGalp&Label=residue-10;b1-4&Label=link-8;DGlcpNAc&Label=residue-9;b1-2&Label=link-7;[DNeup5Ac&Label=residue-8;a2-6&Label=link-6;DGalp&Label=residue-7;b1-4&Label=link-5;DGlcpNAc&Label=residue-6;b1-6&Label=link-4;]DManp&Label=residue-5;a1-6&Label=link-3;]DManp&Label=residue-4;b1-4&Label=link-2;DGlcpNAc&Label=residue-3;b1-4&Label=link-1;DGlcpNAc&Label=residue-2;b1-&Label=link-0;OH&Label=residue-1;"
```

This is our way of labeling the residues and linkages in a sequence. We mimic a method used in html. 
Look for `&Label=link-16;` - that is linkage 16. Of course, this is not intended for humans to read, at
least not on a regular basis. It helps computers present friendlier versions of the information.

By the way, if you want to see it, the complete evaluation response object (that contains the labeled sequence) is in:

```
./examples/Sequence/inputs/multi-conformer-evaluation-response.json 
```

#### Request the build

To recap, we are about to request 3D models for four conformers that the following sequence can adopt:

DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-4]DManpa1-3[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-6]DManpa1-6]DManpb1-4DGlcpNAcb1-4DGlcpNAcb1-OH


To make the request, do:

```
$ ./bin/run_command.bash delegate /inputs/multi-conformer-build.json
```

That will result in a lot of output, but you don't need to try to save it.

It will begin and end something like so:

```
$ ./bin/run_command.bash delegate /inputs/multi-conformer-build.json
Using this as the command given to docker compose:
 delegate /inputs/multi-conformer-build.json
[+] up 2/2
 ✔ Network glycam_delegator_docker_default     Created                                                                                                                                      0.1s 
 ✔ Container lachele-delegator_running-command Created                                                                                                                                      0.1s 
Attaching to lachele-delegator_running-command
lachele-delegator_running-command  | {
lachele-delegator_running-command  |   "timestamp": "2025-12-07_06:02:45",
lachele-delegator_running-command  |   "entity": {
lachele-delegator_running-command  |     "type": "Sequence",
lachele-delegator_running-command  |     "requestID": null,
lachele-delegator_running-command  |     "services": {
lachele-delegator_running-command  |       "build": {
lachele-delegator_running-command  |         "type": "Build3DStructure",


[snip]


lachele-delegator_running-command  |     "indexOrderedSequence": "DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-4]DManpa1-3[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-2[DNeup5Aca2-6DGalpb1-4DGlcpNAcb1-6]DManpa1-6]DManpb1-4DGlcpNAcb1-4DGlcpNAcb1-OH",
lachele-delegator_running-command  |     "seqID": "00e7d454-06dd-5067-b6c9-441dd52db586",
lachele-delegator_running-command  |     "selected_rotamers": ""
lachele-delegator_running-command  |   },
lachele-delegator_running-command  |   "prettyPrint": true,
lachele-delegator_running-command  |   "mdMinimize": true,
lachele-delegator_running-command  |   "options": null,
lachele-delegator_running-command  |   "notices": []
lachele-delegator_running-command  | }
lachele-delegator_running-command exited with code 0
container is up
[+] down 1/2
 ✔ Container lachele-delegator_running-command Removed                                                                                                                                      0.0s 
 ⠋ Network glycam_delegator_docker_default     Removing 
```

#### Inspect the output

Somewhere not far up from the bottom of the output, you should find an entry for `project_dir`. It will
look like the following but (almost certainly) with a different hash after 'Builds'.

```
"project_dir": "/work/sequence/cb/Builds/a6f7b3f3-8ed0-4ea6-9fc8-5f1b36e6376e",
```

This tells you that the output is visible to you at:

```
./input-output/work/sequence/cb/Builds/a6f7b3f3-8ed0-4ea6-9fc8-5f1b36e6376e/
```

Change to that directory and inspect the directory tree (installing 'tree' makes doing that easy):

```
cd ./input-output/work/sequence/cb/Builds/a6f7b3f3-8ed0-4ea6-9fc8-5f1b36e6376e/
$ tree -L 2
.
├── CB_project_a6f7b3f3_all.zip
├── default -> Existing_Builds/e6c2e2e8-758b-58b8-b5ff-d138da38dd22
├── Existing_Builds
│   ├── [if you have something here, that's a relatively harmless bug. please ignore.]
│   └── logs
├── logs
│   ├── ProjectLog.json
│   ├── request-initialized.json
│   ├── request-raw.json
│   └── response.json
├── New_Builds
│   ├── e6c2e2e8-758b-58b8-b5ff-d138da38dd22
AND THIS IS A SERIOUS BUG...
│   └── logs
├── Requested_Builds
│   └── e6c2e2e8-758b-58b8-b5ff-d138da38dd22 -> ../New_Builds/e6c2e2e8-758b-58b8-b5ff-d138da38dd22
├── Sequence_Repository -> ../../Sequences/00e7d454-06dd-5067-b6c9-441dd52db586
├── zip_details.log
└── zip_status.log
```






START: MOVE MOST OF THIS ELSEWHERE

The Delegator Entity was introduced above, as well as the delegate Service that it provides (Entity and 
Service are capitalized here to make plain that these are special terms used in the source code). When you
build the 3D structure of a glycan based on its sequence, it is the Sequence Entity that provides that 
Service. Because there are multiple Entities, each with one or more Services, output from GEMS, by default,
is grouped by Entity and Service. Sometimes Entities are grouped together into a meta-entity.

Consider the following tree (somewhat aspirational) of Entities and Services:

```
├── complex         # Entities that create complexes between separate molecules
│   ├── ad            # Antibody-Glycan Docking 
│   └── gm            # Glycomimetics
├── conjugate       # Entities that chemically join two moieties
│   └── gp            # Glycoprotein 
├── mmservice       # Entities that perform generic molecular modeling Services
│   └── md            # Molecular Dynamics 
├── sequence        # The Entity that performs Services based on a molecular Sequence
│   └── cb            # Build 2D Models
├── structurefile   # The Entity that performs Services on files containing molecular structures
│   └── pdb           # Process PDB files in various ways
├── query           # Entities that perform queries of datasets/databases
│   └── gf            # GlyFinder (search the wwPDB)
```

END: MOVE MOST OF THIS ELSEWHERE



