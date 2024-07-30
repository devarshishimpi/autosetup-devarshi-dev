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
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/scripts/update_packages.sh" -o "update_packages.sh"; then
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
        echo -e "${YELLOW}Skipping update system packages...${NC}"
    fi
}

# Function to Install Node.js
install_nodejs() {
    local choice
    echo -e -n "${YELLOW}Do you want to install Node.js? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing Node.js${NC}"
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/scripts/install_nodejs.sh" -o "install_nodejs.sh"; then
            chmod +x "install_nodejs.sh"
            if ./install_nodejs.sh; then
                echo -e "${GREEN}Node.js successfully installed.${NC}"
                rm -rf "install_nodejs.sh"
            else
                echo -e "${RED}Failed to install Node.js.${NC}"
            fi
        else
            echo -e "${RED}Failed to download install_nodejs.sh${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping Node.js installation...${NC}"
    fi
}

# Function to Install the "serve" NPM Package Globally
install_npmserve() {
    if command -v node > /dev/null 2>&1 && command -v npm > /dev/null 2>&1; then
        echo -e "${GREEN}Node.js and npm are already installed.${NC}"
    else
        echo -e "${RED}Node.js and npm are not installed. Please install them first.${NC}"
        return
    fi

    local choice
    echo -e -n "${YELLOW}Do you want to install the 'serve' npm package globally? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing 'serve' npm package globally${NC}"
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/scripts/install_npmserve.sh" -o "install_npmserve.sh"; then
            chmod +x "install_npmserve.sh"
            if ./install_npmserve.sh; then
                echo -e "${GREEN}'serve' npm package successfully installed.${NC}"
                rm -rf "install_npmserve.sh"
            else
                echo -e "${RED}Failed to install 'serve' npm package.${NC}"
            fi
        else
            echo -e "${RED}Failed to download install_npmserve.sh${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping 'serve' npm package installation...${NC}"
    fi
}

# Function to Install AWS CLI
install_awscli() {
    local choice
    echo -e -n "${YELLOW}Do you want to install AWS CLI? (yes/no)${NC} "
    read -r -n 3 choice
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Installing AWS CLI${NC}"
        if curl -sSf "https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/scripts/install_awscli.sh" -o "install_awscli.sh"; then
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

# Function to Configure the "serve" for Static Files
configure_serve() {
    local choice
    echo -e -n "${YELLOW}Do you want to configure 'serve' to serve static files and start on boot? (yes/no)${NC} "
    read -r -n 3 choice

    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo -e "${GREEN}Configuring 'serve' to serve static files and start on boot${NC}"

        if curl -sSf "https://autosetup.devarshi.dev/home/vms/static-cdn-ubuntu-22-server/scripts/configure_serve.sh" -o "configure_serve.sh"; then
            chmod +x "configure_serve.sh"
            if ./configure_serve.sh; then
                echo -e "${GREEN}'serve' configured successfully.${NC}"
                rm -rf "configure_serve.sh"
            else
                echo -e "${RED}Failed to configure 'serve'.${NC}"
            fi
        else
            echo -e "${RED}Failed to download configure_serve.sh${NC}"
        fi
    else
        echo -e "${YELLOW}Skipping 'serve' configuration...${NC}"
    fi
}

# Configure to sync with MinIO S3 bucket
configure_s3sync() {

    echo -e "${YELLOW}Configuring MinIO S3 Sync Service...${NC}"

    read -p "Enter MinIO IP Address (Without PORT and protocol): " MINIO_IP
    read -p "Enter MinIO Access Key: " MINIO_ACCESS_KEY
    read -p "Enter MinIO Secret Key: " MINIO_SECRET_KEY

    echo -e "${YELLOW}Creating bash script file for systemd...${NC}"
    sudo bash -c "cat <<EOF > /usr/local/bin/s3-sync.sh
#!/bin/bash
while true; do
    aws s3 sync --endpoint-url http://${MINIO_IP}:9000 s3://static-devarshi-dev /home/devarshi/prod/static
    sleep 60  # Sync every 60 seconds
done
EOF"

    echo -e "${YELLOW}sudo chmod +x /usr/local/bin/s3-sync.sh${NC}"
    sudo chmod +x /usr/local/bin/s3-sync.sh

    echo -e "${YELLOW}Creating systemd service file...${NC}"
    sudo bash -c "cat <<EOF > /etc/systemd/system/s3-sync.service
[Unit]
Description=MinIO S3 to Local Directory Sync Service
After=network.target

[Service]
ExecStart=/usr/local/bin/s3-sync.sh
Restart=always
User=devarshi
Group=devarshi
Environment=\"AWS_ACCESS_KEY_ID=${MINIO_ACCESS_KEY}\"
Environment=\"AWS_SECRET_ACCESS_KEY=${MINIO_SECRET_KEY}\"
Environment=\"AWS_DEFAULT_REGION=ap-main1\"

[Install]
WantedBy=multi-user.target
EOF"

    echo -e "${YELLOW}sudo systemctl start s3-sync.service${NC}"
    sudo systemctl start s3-sync.service

    echo -e "${YELLOW}sudo systemctl enable s3-sync.service${NC}"
    sudo systemctl enable s3-sync.service

}


run_with_sudo

update_packages

install_nodejs

install_npmserve

install_awscli

configure_serve

configure_s3sync