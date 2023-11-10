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

# Ask the user for the sudo password and run the commands with sudo
run_with_sudo

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

# Function to handle the installation of Node.js
install_node() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Node.js (node@18)? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Node.js (node@18)...${NC}"
        if brew reinstall node@18; then
            echo -e "${GREEN}Node.js (node@18) installation successful.${NC}"

            # Add Node.js (node@18) to the PATH and set environment variables
            echo 'export PATH="/opt/homebrew/opt/node@18/bin:$PATH"' >> ~/.zshrc
            export LDFLAGS="-L/opt/homebrew/opt/node@18/lib"
            export CPPFLAGS="-I/opt/homebrew/opt/node@18/include"
        else
            echo -e "${RED}Failed to install Node.js (node@18). Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Node.js (node@18) installation...${NC}"
    fi
}

# Check if Homebrew is installed
if command -v brew &>/dev/null; then
    echo -e "${GREEN}Homebrew is already installed.${NC}"
else
    install_homebrew
fi

# Check if mongodb/brew is tapped and update it
if brew tap | grep -q 'mongodb/brew'; then
    echo -e "${GREEN}mongodb/brew tap is already added.${NC}"
else
    local tap_choice
    echo -e -n "${YELLOW}Do you want to tap 'mongodb/brew'? (yes/no)${NC} "
    read -r -n 3 tap_choice
    if [ "$tap_choice" = "yes" ] || [ "$tap_choice" = "y" ]; then
        brew tap mongodb/brew
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}mongodb/brew tap added.${NC}"
            echo -e "${GREEN}Updating mongodb/brew...${NC}"
            brew update
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}mongodb/brew update successful.${NC}"
            else
                echo -e "${RED}Failed to update mongodb/brew. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to tap mongodb/brew. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping mongodb/brew tap and update...${NC}"
    fi
fi

# Define the list of software to install
software_list=(
    "python@3.11"
    "htop"
    "doctl"
    "ca-certificates"
    "node@18"
    "mongodb-community@7.0"
    "mongosh"
    "gcc"
    "wget"
    "git"
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
if [ ${#install_choices[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing selected software...${NC}"
    for software in "${install_choices[@]}"; do
        echo -e "${GREEN}Installing $software...${NC}"
        if brew install "$software"; then
            echo -e "${GREEN}$software installation successful.${NC}"
        else
            echo -e "${RED}Failed to install $software. Exiting.${NC}"
            exit 1
        fi
    done
else
    echo -e "${YELLOW}No software selected for installation.${NC}"
fi

# Function to download and install Cloudflare WARP
install_cloudflare_warp() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Cloudflare WARP? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Downloading Cloudflare WARP...${NC}"
        curl -O https://autosetup-devarshi.vercel.app/mac/softwares/Cloudflare_WARP.zip
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Cloudflare WARP downloaded successfully.${NC}"
            echo -e "${GREEN}Unzipping Cloudflare WARP...${NC}"
            unzip Cloudflare_WARP.zip
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Cloudflare WARP unzipped successfully.${NC}"
                echo -e "${YELLOW}Please enter your sudo password to install Cloudflare WARP.${NC}"
                sudo installer -pkg Cloudflare_WARP.pkg -target /
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Cloudflare WARP installed successfully.${NC}"
                    echo -e "${YELLOW}Cleaning up installation files...${NC}"
                    sudo rm -rf Cloudflare_WARP.zip Cloudflare_WARP.pkg
                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Cleanup completed.${NC}"
                    else
                        echo -e "${RED}Failed to delete installation files.${NC}"
                    fi
                else
                    echo -e "${RED}Failed to install Cloudflare WARP. Exiting.${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Failed to unzip Cloudflare WARP. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download Cloudflare WARP. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Cloudflare WARP installation...${NC}"
    fi
}

# Function to download and install Atlassian Sourcetree
install_atlassian_sourcetree() {
    local choice
    read -r -p "$(echo -e ${YELLOW}Do you want to install Atlassian Sourcetree? \(yes/no\)${NC}) " choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
        echo -e "${GREEN}Downloading Atlassian Sourcetree...${NC}"
        if curl -O https://autosetup-devarshi.vercel.app/mac/softwares/Atlassian_Sourcetree.zip; then
            echo -e "${GREEN}Atlassian Sourcetree downloaded successfully.${NC}"
            echo -e "${GREEN}Unzipping Atlassian Sourcetree...${NC}"
            if unzip Atlassian_Sourcetree.zip; then
                echo -e "${GREEN}Atlassian Sourcetree unzipped successfully.${NC}"
                echo -e "${GREEN}Installing Atlassian Sourcetree...${NC}"
                # Moving Sourcetree.app to Applications
                if mv "Sourcetree.app" "/Applications/"; then
                    echo -e "${GREEN}Atlassian Sourcetree installed successfully.${NC}"
                    echo -e "${YELLOW}Cleaning up installation files...${NC}"
                    if rm -rf Atlassian_Sourcetree.zip; then
                        echo -e "${GREEN}Cleanup completed.${NC}"
                        echo -e "${GREEN}Deleting Sourcetree.app folder from the current directory...${NC}"
                        if rm -rf "Sourcetree.app"; then
                            echo -e "${GREEN}Sourcetree.app folder deleted.${NC}"
                        else
                            echo -e "${RED}Failed to delete Sourcetree.app folder.${NC}"
                        fi
                    else
                        echo -e "${RED}Failed to delete installation files.${NC}"
                    fi
                else
                    echo -e "${RED}Failed to install Atlassian Sourcetree. Exiting.${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Failed to unzip Atlassian Sourcetree. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download Atlassian Sourcetree. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Atlassian Sourcetree installation...${NC}"
    fi
}

# Install Cloudflare WARP
install_cloudflare_warp

# Install Atlassian Sourcetree
install_atlassian_sourcetree

echo -e "${GREEN}Installation complete.${NC}"
