#!/bin/bash

# Define the input file name
CSV_FILE="minimal.csv"

# Set the Internal Field Separator (IFS) to a comma for correct field splitting
IFS=","

# Read the first line (header) into an array named 'header'
read -r -a header < "$CSV_FILE"

# Print the header for confirmation
echo "Header columns are: ${header[@]}"

randomNumber="0"
tail -n +2 "$CSV_FILE" | while read -r -a column
do
  # Access data using array indices (e.g., first column is ${columns[0]})
  echo "Processing row"
    randomNumber="1000"
    echo "the random number is: ${randomNumber}"
    # export randomNumber ## doesn't matter
done

echo "the random number is: ${randomNumber}"


