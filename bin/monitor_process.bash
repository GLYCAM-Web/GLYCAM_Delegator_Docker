#!/usr/bin/env bash

if [ -z "${1}" ] ; then
	echo "Must provide the process name on the command line"
	echo "NOTE! If the process contains spaces, enclose the proceess in single quotes."
fi

LOG_FILE="./logs/process_monitor.log"
PROCESS_NAME="${1}"

# Get CPU (%) and Memory (MiB) usage and append to the log file
# The 'ps' command is used to get a snapshot of process details
# 'ps aux' lists all processes, 'grep' filters for the process name
# 'grep -v grep' excludes the grep process itself
# 'awk' is used to format the output (PID, %CPU, %MEM, Command)
# '>>' appends the output to the log file
## The overall command is:
# ps aux | grep "$PROCESS_NAME" | grep -v grep | awk '{print "PID: "$2", CPU: "$3"%, MEM: "$4"%, Command: "$11}' 

ProcessExists="True"
while [ "${ProcessExists}" == "True" ] ; do 
	echo "$(date) - Monitoring $PROCESS_NAME" >> "$LOG_FILE"
	COM="ps aux | grep \"$PROCESS_NAME\" | grep -v grep | grep -v monitor_process.bash"
	result="$( eval ${COM} )"
	returnVal="$?"
	if [ "${result}" == "" ] ; then
		ProcessExists="False"
		echo "Monitoring ended because process ended" >> "$LOG_FILE"
		break
	fi
	if [ "${returnVal}" != "0" ] ; then
		ProcessExists="False"
		echo "Monitoring ended because monitoring process failed with return value ${returnVal}." >> "$LOG_FILE"
		echo "See below for output."
		echo """
${result}
"""
		break
	fi
	echo "${result}" | awk '{print "PID: "$2", CPU: "$3"%, MEM: "$4"%, Command: "$11}' >> "$LOG_FILE"
	sleep 300
done
