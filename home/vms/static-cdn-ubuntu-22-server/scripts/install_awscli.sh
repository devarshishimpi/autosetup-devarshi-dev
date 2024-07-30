#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Install AWS CLI
install_awscli() {
    echo -e "${YELLOW}apt install unzip -y${NC}"
    apt install unzip -y

    echo -e "${YELLOW}curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

    echo -e "${YELLOW}unzip awscliv2.zip${NC}"
    unzip awscliv2.zip

    echo -e "${YELLOW}sudo ./aws/install${NC}"
    sudo ./aws/install

    echo -e "${YELLOW}Cleaning up temporary files...${NC}"
    rm -rf awscliv2.zip
    rm -rf aws
}

install_awscli
