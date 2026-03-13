# Monitoring Processes

A simple script for monitoring processes has been added to the bin directory. It is not very flexible, 
but it is easy to copy and modify. It can be used to monitor processes generally. 

Acknowledgment: Google's Gemini wrote the first draft of this.

## Monitor requirments and capabilities

This is for the script as written.

Requirements:
- A process that lasts at least five minutes
- Write permissions to `./logs/process_monitor.log`
- These utilities: ps, grep, awk, date (most `*NIX` systems have these)

Capabilities:
- Will check CPU and Memory usage every 5 minutes
- Will automatically stop once the process ends or if the monitoring fails.

## Using the file

1. Start a lengthy process that you want to monitor.
2. Inspect the process list and find a unique string to use (example below).
3. Run the monitor (example below).
4. Optionally, `tail -f` the file `./logs/process_monitor.log`

## Modifying the file

Don't modify the file provided with this repo. Instead, copy it to a new filename and modify that. 
You can change the wait time (in seconds - see `sleep`) or the `LOG_FILE`. If you learn a little
bash and awk, you can change the output.

## Example

### Start a command

This command is prefaced with /usr/bin/time to get the overall time. Timing the process overall is
optional. It is included here to explain a little about the processes (see below).

```
/usr/bin/time ./bin/run_command.bash Generate_Glycan_PDBs_From_Sequence_List /inputs/long_example_input.csv
```

### Use `ps` to find related processes. 

This example searches for the string 'command'. Alter your search as needed.

```
$ ps -ef | grep command
lachele  1530896 1433319  0 01:40 pts/19   00:00:00 /usr/bin/time ./bin/run_command.bash Generate_Glycan_PDBs_From_Sequence_List /inputs/long_example_input.csv
lachele  1530897 1530896  0 01:40 pts/19   00:00:00 bash ./bin/run_command.bash Generate_Glycan_PDBs_From_Sequence_List /inputs/long_example_input.csv
lachele  1530916 1530897  0 01:40 pts/19   00:00:00 docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
lachele  1530937 1530916  0 01:40 pts/19   00:00:00 /usr/libexec/docker/cli-plugins/docker-compose compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
lachele  1531602 1479355  0 01:40 pts/13   00:00:00 grep --color=auto command
```

### Choose a process

In our list above, you want to choose the specific process that needs to be monitored.

- `/usr/bin/time` is (typically) not going to use many system resources. So, this is not a good choice.
- `bash ./bin/run_command...` is a good option that monitors the work done.
- `docker compose...` is also good as it monitors the resources taken up by docker.
- `/usr/libexec/docker...` is not a main process, so unless you suspect it, this is not a good choice.

This time, we will choose `docker compose...`.

### Represent your process with a unique identifier

Using 'command' isn't good enough because of the number of processes that contain the string (the list above).

There are two options:

- You can choose by name to make your logs more readable. If you do this, ensure you have a unique string.
- You can choose by process ID if you do not need the process text to be in your file.

Using our list above:

Name: `docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator`

Process ID: `1530916`

If you choose to use the name, enclose it in quotes on the command line, like so:

```
bash bin/monitor_process.bash "docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator"
```

There will be no output to the terminal where the process is begun. 

Use `nohup ... &` if you are going to log out from your account while it runs.

### Check the logs

The logs should look something like this:

```
Fri Mar 13 01:42:27 AM EDT 2026 - Monitoring docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
PID: 1530916, CPU: 1.0%, MEM: 0.0%, Command: docker
Fri Mar 13 01:47:27 AM EDT 2026 - Monitoring docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
PID: 1530916, CPU: 0.0%, MEM: 0.0%, Command: docker
Fri Mar 13 01:52:27 AM EDT 2026 - Monitoring docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
PID: 1530916, CPU: 0.0%, MEM: 0.0%, Command: docker
Fri Mar 13 01:57:27 AM EDT 2026 - Monitoring docker compose --file ./docker-compose.run.yml -p lachele-run-command up delegator
Monitoring ended because process ended
```

It is expected that generating glycans (what this is monitoring) on modern computers will not 
consume many resources: small CPU and MEM numbers make sense here.

