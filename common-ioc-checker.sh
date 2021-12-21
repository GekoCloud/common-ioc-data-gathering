#!/bin/bash
# Variable configuration
datetime=$(date +"%m-%d-%y_%H-%M")
targetlog=/opt/common-ioc-data-gathering-$datetime.log

# Run with necessary permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root with sudo"
  exit
fi

echo "Welcome! running the system checking script. All outputs and logs for this execution will be stored at $targetlog"

# Check system for rootkits
sudo echo "################################### Checking for rootkit traces: " >> $targetlog
echo "Installing chkrootkit rootkit checker"
sudo apt install -y chkrootkit 
echo "Checking system for rootkit traces"
sudo chkrootkit >> $targetlog
sudo echo "" >> $targetlog

# Check package integrity
sudo echo "################################### Checking for compromised or modified deb packages: " >> $targetlog
echo "Installing debsums debian package integrity checker"
sudo apt install -y debsums
echo "Checking debian package integrity"
sudo debsums -c >> $targetlog
sudo echo "" >> $targetlog

# Find active systemd services
echo "Listing and storing running systemd units"
sudo echo "################################### Currently running systemd units: " >> $targetlog
systemctl list-units --type=service --state=running >> $targetlog
sudo echo "" >> $targetlog

# Checking running processes
echo "Listing and storing running processes"
sudo echo "################################### Currently running process tree: " >> $targetlog
sudo ps auxwf >> $targetlog
sudo echo "" >> $targetlog

# Check for processes with deleted binaries
echo "Listing processes running a deleted binary"
sudo echo "################################### Check for running processes with a deleted binary. Here's a list: " >> $targetlog
sudo ls -alR /proc/*/exe 2>/dev/null | grep deleted >> $targetlog
sudo echo "" >> $targetlog

# Check currently listening ports and processes
echo "Listing and storing currently listening ports and processes"
sudo echo "################################### List running processes listening to ports. Here's a list: " >> $targetlog
sudo netstat -tulpn >> $targetlog
sudo echo "" >> $targetlog

# Find SSH authorized_keys file locations
echo "Getting location of authorized_keys ssh files"
sudo echo "################################### List locations for authorized_keys files to check. Here's a list: " >> $targetlog
find / -type f -name authorized_keys >> $targetlog 2>/dev/null
sudo echo "" >> $targetlog

# Find files under /etc/ssh modified in the last 10 days
echo "Getting the modified files under /etc/ssh on a list"
sudo echo "################################### List files that changed under /etc/ssh the last 10 days. Here's a list: " >> $targetlog
find /etc/ssh -mtime -10 >> $targetlog
sudo echo "" >> $targetlog

# Check crontab files modified in the last 10 days
echo "Getting the recently modified cron files on a list"
sudo echo "################################### List files that changed under /etc/cron.* the last 10 days. Here's a list: " >> $targetlog
find /etc/cron* -mtime -10 >> $targetlog
sudo echo "" >> $targetlog

# Check existing scheduled systemd jobs
echo "Checking existing scheduled systemd jobs"
sudo echo "################################### Check existing scheduled systemd jobs. Here's a list: " >> $targetlog
systemctl list-timers --all >> $targetlog
sudo echo "" >> $targetlog

# Check init.d files modified in the last 10 days
echo "Getting the recently modified /etc/init.d files on a list"
sudo echo "################################### List files that changed under /etc/init.d/* the last 10 days. Here's a list: " >> $targetlog
find /etc/init.d/* -mtime -10 >> $targetlog
sudo echo "" >> $targetlog

# Check initrc files modified in the last 10 days
echo "Getting the recently modified /etc/rc[0-9].d/ files on a list"
sudo echo "################################### List files that changed under /etc/rc[0-9].d/ the last 10 days. Here's a list: " >> $targetlog
find /etc/rc* -mtime -10 >> $targetlog
sudo echo "" >> $targetlog

# Find empty history files that could have been emptied
echo "Getting emptied history files"
sudo echo "################################### Checking for empty history files. Here's a list: " >> $targetlog
sudo ls -alR / 2>/dev/null | grep .*history | grep null >> $targetlog
sudo echo "" >> $targetlog

# Log4j binary scanning accross the system
echo "Downloading log4j system scanner"
sudo apt install python3
git clone https://github.com/fox-it/log4j-finder.git
cd log4j-finder
echo "Checking for log4j binaries. This one may take a while..."
sudo echo "################################### Check for log4j vulnerable binaries. Here's the list: " >> $targetlog
sudo python3 log4j-finder.py >> $targetlog
sudo echo "" >> $targetlog
