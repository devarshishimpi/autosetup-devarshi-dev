#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Install global npm packages
install_global_packages() {
    echo -e "${YELLOW}sudo npm install -g serve${NC}"
    sudo npm install -g serve

    echo -e "${YELLOW}serve -v${NC}"
    serve -v
}

install_global_packages
