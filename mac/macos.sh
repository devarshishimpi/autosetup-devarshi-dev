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
    echo -e -n "${YELLOW}Do you want to install Node.js (node)? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Node.js (node)...${NC}"
        if brew install node; then
            echo -e "${GREEN}Node.js (node) installation successful.${NC}"

            # Add Node.js (node) to the PATH and set environment variables
			echo -e "${YELLOW}Adding Node.js (node) to the PATH and set environment variables${NC}"
            echo 'export PATH="/opt/homebrew/opt/node/bin:$PATH"' >> ~/.zshrc
            export LDFLAGS="-L/opt/homebrew/opt/node/lib"
            export CPPFLAGS="-I/opt/homebrew/opt/node/include"
            sudo chown -R $(whoami) ~/.npm
            sudo chown -R $(whoami) /usr/local/lib/node_modules
			echo -e "${GREEN}Successfully added Node.js (node) to the PATH and set environment variables${NC}"
        else
            echo -e "${RED}Failed to install Node.js (node). Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Node.js (node) installation...${NC}"
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

# Function to install Homebrew
install_homebrew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/devarshishimpi/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
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

# Define the list of taps to install
tap_list=(
    "mongodb/brew"
    "teamookla/speedtest"
)

# Function to prompt for brew tap installation
prompt_install_tap() {
    local item="$1"
    while true; do
        read -p "Do you want to tap the following cask $item? (yes/no) " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Function to tap brew repositories
tap_brew_repos() {
    local tap
    for tap in "${tap_list[@]}"; do
        if prompt_install_tap "$tap"; then
            echo -e "${GREEN}Tapping $tap...${NC}"
            if brew tap "$tap"; then
                echo -e "${GREEN}$tap tap successful.${NC}"
            else
                echo -e "${RED}Failed to tap $tap. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Skipping tap of $tap...${NC}"
        fi
    done
}

# Prompt for and tap brew repositories
tap_brew_repos

# Define the list of software to install
software_list=(
    "node"
    "speedtest"
    "python@3.12"
    "htop"
    "doctl"
    "ca-certificates"
    "mongodb-community@7.0"
    "mongosh"
    "gcc"
    "wget"
    "git"
    "mas"
    "watchman"
    "go"
    "nmap"
    "xmrig"
    "ffmpeg"
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
    "mongodb-compass"
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
    "utm"
    "nomachine"
    "anydesk"
    "gather"
    "sourcetree"
    "free-download-manager"
    "zed"
    "codux"
    "redisinsight"
    "protonvpn"
    "cyberduck"
    "postman"
    "github"
    "microsoft-edge"
    "firefox"
    "google-chrome"
    "brave-browser"
    "visual-studio-code"
    "arc"
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
    echo -e "${YELLOW}No GUI software selected for installation using Brew Cask.${NC}"
fi

# prompt for npm global packages
echo -e "${YELLOW}Installing NPM Global Packages.${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed.${NC}" 
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed.${NC}"
    exit 1
fi

# Function to prompt user for npm package installation
prompt_install_npm() {
    local software_name_npm="$1"
    local choice
    echo -e -n "${YELLOW}Do you want to install $software_name_npm? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        return 0
    else
        return 1
    fi
}

software_list_npm=(
    "nodemon"
    "typescript"
    "wrangler"
    "yarn"
    "vite"
    "netlify-cli"
    "@tunnel/cli"
    "@vscode/vsce"
    "create-next-app"
    "prettier"
)

install_choices_npm=()
for software_npm in "${software_list_npm[@]}"; do
    if prompt_install_npm "$software_npm"; then
        install_choices_npm+=("$software_npm")
    else
        echo -e "${RED}Skipping installation of $software_npm...${NC}"
    fi
done

# Perform the selected npm package installations
if [ ${#install_choices_npm[@]} -gt 0 ]; then
    echo -e "${GREEN}Installing selected npm packages...${NC}"
    for software_npm in "${install_choices_npm[@]}"; do
        echo -e "${GREEN}Installing $software_npm...${NC}"
        if npm install -g "$software_npm"; then
            echo -e "${GREEN}$software_npm installation successful.${NC}"
        else
            echo -e "${RED}Failed to install $software_npm. Exiting.${NC}"
            exit 1
        fi
    done
else
    echo -e "${YELLOW}No npm packages selected for installation.${NC}"
fi

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

# Function to download and install Docker
install_docker() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Docker? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Downloading Docker...${NC}"
        
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partaa
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partab
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partac
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partad
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partae
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partaf
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partag
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partah
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partai
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partaj
        curl -O https://autosetup.devarshi.dev/mac/softwares/Docker/Docker.zip.partak

        if [ -f "Docker.zip.partaa" ] && [ -f "Docker.zip.partab" ] && [ -f "Docker.zip.partac" ] && [ -f "Docker.zip.partad" ] && [ -f "Docker.zip.partae" ] && [ -f "Docker.zip.partaf" ] && [ -f "Docker.zip.partag" ] && [ -f "Docker.zip.partah" ] && [ -f "Docker.zip.partai" ] && [ -f "Docker.zip.partaj" ] && [ -f "Docker.zip.partak" ]; then
            echo -e "${GREEN}Downloaded Docker parts successfully.${NC}"

            cat Docker.zip.part* > Docker.zip

            if [ -f "Docker.zip" ]; then
                echo -e "${GREEN}Combined Docker parts into a zip file.${NC}"

                unzip Docker.zip

                if [ -f "Docker.dmg" ]; then
                    echo -e "${GREEN}Docker unzipped successfully.${NC}"

                    echo -e "${YELLOW}Please enter your sudo password to install Docker.${NC}"
                    sudo hdiutil attach Docker.dmg
                    sudo cp -R /Volumes/Docker/Docker.app /Applications/
                    sudo hdiutil detach /Volumes/Docker

                    if [ $? -eq 0 ]; then
                        echo -e "${GREEN}Docker installed successfully.${NC}"

                        echo -e "${YELLOW}Cleaning up installation files...${NC}"
                        rm -rf Docker.zip Docker.dmg Docker.zip.part*

                        if [ $? -eq 0 ]; then
                            echo -e "${GREEN}Cleanup completed.${NC}"
                        else
                            echo -e "${RED}Failed to delete installation files.${NC}"
                        fi
                    else
                        echo -e "${RED}Failed to install Docker. Exiting.${NC}"
                        exit 1
                    fi
                else
                    echo -e "${RED}Failed to unzip Docker. Exiting.${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}Failed to combine Docker parts into a zip file. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}Failed to download Docker parts. Exiting.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Skipping Docker installation...${NC}"
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

# Install Davinci Resolve
install_app "Davinci Resolve" 571213070

# Install Bluebook
install_app "Bluebook" 1645016851

# Install Microsoft Remote Desktop
install_app "Microsoft Remote Desktop" 1295203466

# Install Docker
install_docker

#Clear local brew cache
echo -e "${YELLOW}Clearing local brew cache.${NC}"
brew cleanup
echo -e "${GREEN}Successfully cleared local brew cache.${NC}"

echo -e "${GREEN}Installation complete.${NC}"
