#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Install Node.js and npm
install_nodejs() {
    echo -e "${YELLOW}curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh

    echo -e "${YELLOW}sudo -E bash nodesource_setup.sh${NC}"
    sudo -E bash nodesource_setup.sh

    echo -e "${YELLOW}sudo apt-get install -y nodejs${NC}"
    sudo apt-get install -y nodejs

    echo -e "${YELLOW}node -v${NC}"
    node -v

    echo -e "${YELLOW}npm -v${NC}"
    npm -v
}

install_nodejs
