# Common IoC data gathering script
Check for common indicators of compromise in a system. No specific vulnerability, but system-level. From history cleanups to scheduled persistance.

----

## What is this?
This is a script that will check a system for common indicators of having been compromised. These are indicators that have been generalized as much as possible for data gathering. This is not checking for any specific vulnerability, but for generalized post-exploitation techniques that leave a trace on your systems.

## What systems are supported?
Any `debian`-based system using `systemd`. More checking and conditional configuration is being worked on to support more platforms.

## How do I use it?
1. Clone this repository to the target system
2. Run the script with `sudo`
3. Once done, check the results over at /opt/ where a log file will have been created

## What does this script check?
- Rootkit traces
- Compromised or modified binary packages
- Currently running systemd units
- currently running process tree
- Currently running processes of which the binary was deleted
- Currently running processes with listening ports
- `authorized_keys` file locations on the system
- Cron files modified the last 10 days
- Existing `systemd` scheduled tasks
- Startup files modified the last 10 days
- Emptied `history` files in the entire system
- `log4j`-vulnerable java libraries present in the system (depends on FoxIT's [log4j-finder python script](https://github.com/fox-it/log4j-finder.git))

## What are future plans on IoC detection development?
- Adding support for `RHEL`/`centos` based systems
- Adding support for containerized environments without `systemd`
