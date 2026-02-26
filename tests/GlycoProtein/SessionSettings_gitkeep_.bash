#!/usr/bin/env bash

## SessionSettings.bash to be appended to existing file during testing

export OUT_SUBDIR="TEST_OF_GLYCOPROTEIN_BUILDER"

export OVERWRITE_OUTPUT="True"

export KEEP_TEMPORARY_FILES="True"

export APPEND_DATETIME_TO_OUTFILES="False"

declare -a GPB_Options
declare -A GPB_Options_Values
GPB_Options=(
    number_of_samples
    persist_cycles
    rng_seed
    overlap_rejection_threshold
    prepare_for_md
    use_initial_glycosite_residue_conformation
    move_overlapping_sidechains
    delete_unresolvable_glycosites
)
GPB_Options_Values=(
    ["number_of_samples"]="1"
    ["persist_cycles"]="5"
    ["rng_seed"]="5408925415593553639"
    ["overlap_rejection_threshold"]="0.0"
    ["prepare_for_md"]="False"
    ["use_initial_glycosite_residue_conformation"]="True" # This is the default here, not in the code
    ["move_overlapping_sidechains"]="False"
    ["delete_unresolvable_glycosites"]="False"
)
export GPB_Options GPB_Options_Values
