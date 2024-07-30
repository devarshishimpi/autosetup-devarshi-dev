#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Update the package list
update_packages() {
    echo -e "${YELLOW}SOURCES_LIST="/etc/apt/sources.list"${NC}"
    SOURCES_LIST="/etc/apt/sources.list"

    echo -e "${YELLOW}sudo rm -rf $SOURCES_LIST${NC}"
    sudo rm -rf $SOURCES_LIST

    echo -e "${YELLOW}sudo touch $SOURCES_LIST${NC}"
    sudo touch $SOURCES_LIST

    echo -e "${YELLOW}sudo apt update${NC}"
    sudo apt update

    echo -e "${YELLOW}sudo apt upgrade -y${NC}"
    sudo apt upgrade -y

    echo -e "${YELLOW}sudo apt install git curl wget zip unzip -y${NC}"
    sudo apt install git curl wget zip unzip -y
}

update_packages
