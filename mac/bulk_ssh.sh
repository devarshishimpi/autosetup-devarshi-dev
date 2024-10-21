#!/bin/bash

# Use to bulk ssh VMs in separate tabs in Terminal

# List of VM IPs
ips=("192.168.0.1" "192.168.0.2" "192.168.0.3" "192.168.0.4")

# SSH username
user="azureuser"

# Open the first tab and SSH into the first VM
osascript \
  -e 'tell application "Terminal"' \
  -e 'activate' \
  -e "do script \"ssh $user@${ips[0]}\"" \
  -e 'end tell'

# Open the remaining tabs for the other VMs
for ((i = 1; i < ${#ips[@]}; i++)); do
  osascript \
  -e 'tell application "Terminal" to activate' \
  -e 'tell application "System Events" to keystroke "t" using {command down}' \
  -e "tell application \"Terminal\" to do script \"ssh $user@${ips[i]}\" in front window"
done
