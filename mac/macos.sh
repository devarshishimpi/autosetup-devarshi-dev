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
    echo -e -n "${YELLOW}Do you want to install Node.js (node@21)? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Node.js (node@21)...${NC}"
        if brew install node@21; then
            echo -e "${GREEN}Node.js (node@21) installation successful.${NC}"

            # Add Node.js (node@21) to the PATH and set environment variables
			echo -e "${YELLOW}Adding Node.js (node@21) to the PATH and set environment variables${NC}"
            echo 'export PATH="/opt/homebrew/opt/node@21/bin:$PATH"' >> ~/.zshrc
            export LDFLAGS="-L/opt/homebrew/opt/node@21/lib"
            export CPPFLAGS="-I/opt/homebrew/opt/node@21/include"
			echo -e "${GREEN}Successfully added Node.js (node@21) to the PATH and set environment variables${NC}"
        else
            echo -e "${RED}Failed to install Node.js (node@21). Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Node.js (node@21) installation...${NC}"
    fi
}

# Function to install mas (Mac App Store command-line interface)
install_mas() {
    local choice
    echo -e -n "${YELLOW}Do you want to install mas (Mac App Store command-line interface)? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing mas...${NC}"

        # Install mas using Homebrew
        if brew install mas; then
            echo -e "${GREEN}mas installation successful.${NC}"
        else
            echo -e "${RED}Failed to install mas. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}mas (Mac App Store command-line interface) is required for this script. Exiting.${NC}"
        exit 1
    fi
}

# Check if Homebrew is installed
if command -v brew &>/dev/null; then
    echo -e "${GREEN}Homebrew is already installed.${NC}"
else
    install_homebrew
fi

# Check if mas (Mac App Store command-line interface) is installed
if command -v mas &>/dev/null; then
    echo -e "${GREEN}mas is already installed.${NC}"
else
    install_mas
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

# Check if teamookla/speedtest is tapped and update it
if brew tap | grep -q 'teamookla/speedtest'; then
    echo -e "${GREEN}teamookla/speedtest tap is already added.${NC}"
else
    local speedtest_tap_choice
    echo -e -n "${YELLOW}Do you want to tap 'teamookla/speedtest'? (yes/no)${NC} "
    read -r -n 3 speedtest_tap_choice
    if [ "$speedtest_tap_choice" = "yes" ] || [ "$speedtest_tap_choice" = "y" ]; then
        brew tap teamookla/speedtest
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}teamookla/speedtest tap added.${NC}"
            echo -e "${GREEN}Updating teamookla/speedtest...${NC}"
            brew update
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}teamookla/speedtest update successful.${NC}"
            else
                echo -e "${RED}Failed to update teamookla/speedtest. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to tap teamookla/speedtest. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping teamookla/speedtest tap and update...${NC}"
    fi
fi

# Define the list of software to install
software_list=(
    "node@21"
    "speedtest"
    "python@3.11"
    "htop"
    "doctl"
    "ca-certificates"
    "mongodb-community@7.0"
    "mongosh"
    "gcc"
    "wget"
    "git"
    "mas"
)

install_choices=()
for software in "${software_list[@]}"; do
    if [ "$software" = "node@21" ]; then
        install_node
    else
        if prompt_install "$software"; then
            install_choices+=("$software")
        else
            echo -e "${RED}Skipping installation of $software...${NC}"
        fi
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

#prompt for brew cash softwares
echo -e "${YELLOW}Installing Brew Cask softwares.${NC}"

# Function to prompt user for gui installation
prompt_install_gui() {
    local software_name_gui="$1"
    local choice
    echo -e -n "${YELLOW}Do you want to install $software_name_gui? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        return 0
    else
        return 1
    fi
}

software_list_gui=(
    "tor-browser"
    "obs"
    "notion"
    "vlc"
    "cloudflare-warp"
    "openvpn-connect"
    "figma"
    "spotify"
    "zoom"
    "discord"
)

install_choices_gui=()
for software_gui in "${software_list_gui[@]}"; do
    if prompt_install_gui "$software_gui"; then
        install_choices_gui+=("$software_gui")
    else
        echo -e "${RED}Skipping installation of $software_gui...${NC}"
    fi
done

# Perform the selected gui installations
if [ ${#install_choices_gui[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing selected GUI software...${NC}"
    for software_gui in "${install_choices_gui[@]}"; do
        echo -e "${GREEN}Installing $software_gui...${NC}"
        if brew install --cask "$software_gui"; then
            echo -e "${GREEN}$software_gui installation successful.${NC}"
        else
            echo -e "${RED}Failed to install $software_gui. Exiting.${NC}"
            exit 1
        fi
    done
else
    echo -e "${YELLOW}No GUI software selected for installation.${NC}"
fi

# Function to install Slack from the Mac App Store
install_slack() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Slack from the Mac App Store? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Slack from the Mac App Store...${NC}"
        
        # Check if mas (Mac App Store command-line interface) is installed
        if command -v mas &>/dev/null; then
            # Install Slack (you may need to replace the ID with the correct one)
            mas install 803453959  # Slack's Mac App Store ID
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Slack installation successful.${NC}"
            else
                echo -e "${RED}Failed to install Slack. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}mas (Mac App Store command-line interface) is not installed. Please install it first.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Slack installation...${NC}"
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

# Function to download and install Free Download Manager
install_free_download_manager() {
    local choice
	echo -e -n "${YELLOW}Do you want to install Free Download Manager? (yes/no)${NC} "
	read -r choice
	if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
        echo -e "${GREEN}Downloading Free Download Manager...${NC}"
        curl -O https://autosetup-devarshi.vercel.app/mac/softwares/Free_Download_Manager.zip

        if [ -f "Free_Download_Manager.zip" ]; then
            echo -e "${GREEN}Downloaded Free Download Manager successfully.${NC}"

            unzip Free_Download_Manager.zip

            if [ -f "fdm.dmg" ]; then
                echo -e "${GREEN}Free Download Manager unzipped successfully.${NC}"

                sudo hdiutil attach fdm.dmg
                sudo cp -R /Volumes/FDM/Free\ Download\ Manager.app /Applications/
                sudo hdiutil detach /Volumes/FDM

                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}Free Download Manager installed successfully.${NC}"

                    echo -e "${YELLOW}Cleaning up installation files...${NC}"
                    rm -rf Free_Download_Manager.zip fdm.dmg __MACOSX

                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Cleanup completed.${NC}"
                    else
                        echo -e "${RED}Failed to delete installation files.${NC}"
                    fi
                else
                    echo -e "${RED}Failed to install Free Download Manager. Exiting.${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Failed to unzip Free Download Manager. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download Free Download Manager. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Free Download Manager installation...${NC}"
    fi
}

# Function to install an app from the Mac App Store
install_app() {
    local app_name="$1"
    local app_id="$2"

    echo -e -n "${YELLOW}Do you want to install $app_name from the Mac App Store? (yes/no)${NC} "
    read -r -n 3 choice

    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing $app_name from the Mac App Store...${NC}"

        # Check if mas (Mac App Store command-line interface) is installed
        if command -v mas &>/dev/null; then
            # Install the app
            mas install "$app_id"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}$app_name installation successful.${NC}"
            else
                echo -e "${RED}Failed to install $app_name. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}mas (Mac App Store command-line interface) is not installed. Please install it first.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping $app_name installation...${NC}"
    fi
}

# Install Slack
install_app "Slack" 803453959

# Install Microsoft PowerPoint
install_app "Microsoft PowerPoint" 462062816

# Install Microsoft Word
install_app "Microsoft Word" 462054704

# Install Microsoft Excel
install_app "Microsoft Excel" 462058435

# Install Microsoft OneDrive
install_app "Microsoft OneDrive" 823766827

# Install Microsoft Outlook
install_app "Microsoft Outlook" 985367838

# Install Keynote
install_app "Keynote" 409183694

# Install Numbers
install_app "Numbers" 409203825

# Install Pages
install_app "Pages" 409201541

# Install XCode
install_app "XCode" 497799835

# Install Apple Developer
install_app "Apple Developer" 640199958

# Install WhatsApp Desktop
install_app "WhatsApp Messenger" 310633997

# Install Telegram
install_app "Telegram" 747648890

# Install Hologram Desktop
install_app "Hologram Desktop" 1529001798

# Install Termius
install_app "Termius" 1176074088

# Install Usage
install_app "Usage" 1561788435

# Install Bitpay
install_app "Bitpay" 1440200291

# Install Atlassian Sourcetree
install_atlassian_sourcetree

# Install Free Download Manager
install_free_download_manager

#Clear local brew cache
echo -e "${YELLOW}Clearing local brew cache.${NC}"
brew cleanup
echo -e "${GREEN}Successfully cleared local brew cache.${NC}"

echo -e "${GREEN}Installation complete.${NC}"
