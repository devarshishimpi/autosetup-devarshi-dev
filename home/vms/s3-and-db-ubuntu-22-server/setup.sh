#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to ask for sudo password and run a command with sudo
run_with_sudo() {
    echo -e "${YELLOW}Please enter your sudo password to continue. ${NC}"
    if sudo -v; then
        echo -e "${GREEN}Sudo access granted.${NC}"
    else
        echo -e "${RED}Failed to get sudo access. Exiting.${NC}"
        exit 1
    fi
}

# Function to Update the package list
update_packages() {
    local choice
    echo -e -n "${YELLOW}Do you want to update system packages? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Updating System Packages${NC}"
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/s3-and-db-ubuntu-22-server/scripts/update_packages.sh" -o "update_packages.sh"; then
            chmod +x "update_packages.sh"
            if ./update_packages.sh; then
                echo -e "${GREEN}System packages successfully updated.${NC}"
                rm -rf "update_packages.sh"
            else
                echo -e "${RED}Failed to update system packages.${NC}"
            fi
        else
            echo -e "${RED}Failed to download update_packages.sh${NC}"
        fi
    else
        echo -e "${RED}Skipping update system packages...${NC}"
    fi
}

# Function to Install AWS CLI
install_awscli() {
    local choice
    echo -e -n "${YELLOW}Do you want to install AWS CLI? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing AWS CLI${NC}"
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/s3-and-db-ubuntu-22-server/scripts/install_awscli.sh" -o "install_awscli.sh"; then
            chmod +x "install_awscli.sh"
            if ./install_awscli.sh; then
                echo -e "${GREEN}Installed AWS CLI.${NC}"
                rm -rf "install_awscli.sh"
            else
                echo -e "${RED}Failed to install AWS CLI.${NC}"
            fi
        else
            echo -e "${RED}Failed to download install_awscli.sh${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping AWS CLI installation...${NC}"
    fi
}


run_with_sudo

update_packages

install_awscli