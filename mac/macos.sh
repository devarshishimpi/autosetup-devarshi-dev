#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to prompt user for installation
prompt_install() {
    local software_name="$1"
    local choice
    echo -e -n "${YELLOW}Do you want to install $software_name? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        return 0
    else
        return 1
    fi
}

# Function to handle Homebrew installation
install_homebrew() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Homebrew? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Homebrew...${NC}"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${RED}Skipping Homebrew installation...${NC}"
    fi
}

# Check if Homebrew is installed
if command -v brew &>/dev/null; then
    echo -e "${GREEN}Homebrew is already installed.${NC}"
else
    install_homebrew
fi

# Define the list of software to install
software_list=(
    "python@3.11"
    "htop"
    "doctl"
    "ca-certificates"
    "node@18"
    "mongodb/brew"
    "mongodb-community@7.0"
    "mongosh"
    "gcc"
    "wget"
)

# Collect user choices for software installation
install_choices=()
for software in "${software_list[@]}"; do
    if prompt_install "$software"; then
        install_choices+=("$software")
    else
        echo -e "${RED}Skipping installation of $software...${NC}"
    fi
done

# Perform the selected installations
echo -e "${GREEN}Installing selected software...${NC}"
for software in "${install_choices[@]}"; do
    echo -e "${GREEN}Installing $software...${NC}"
    if [ "$software" = "mongodb/brew" ]; then
        brew tap mongodb/brew
    else
        brew install "$software"
    fi
done

echo -e "${GREEN}Installation complete.${NC}"
