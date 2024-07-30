#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configure to serve static files and start on boot
configure_serve() {
    echo -e "${YELLOW}serve -V${NC}"
    serve -V

    echo -e "${YELLOW}mkdir /home/devarshi/prod${NC}"
    mkdir -p /home/devarshi/prod

    echo -e "${YELLOW}mkdir /home/devarshi/prod/static${NC}"
    mkdir -p /home/devarshi/prod/static

    echo -e "${YELLOW}Creating systemd service file...${NC}"
    sudo bash -c "cat <<EOF > /etc/systemd/system/static-serve.service
[Unit]
Description=Serve Static Files
After=network.target

[Service]
ExecStart=/usr/bin/serve -p 8082 /home/devarshi/prod/static
WorkingDirectory=/home/devarshi/prod
Restart=always
User=devarshi
Group=devarshi

[Install]
WantedBy=multi-user.target
EOF"

    echo -e "${YELLOW}sudo systemctl daemon-reload${NC}"
    sudo systemctl daemon-reload

    echo -e "${YELLOW}sudo systemctl start static-serve.service${NC}"
    sudo systemctl start static-serve.service

    echo -e "${YELLOW}sudo systemctl enable static-serve.service${NC}"
    sudo systemctl enable static-serve.service
}

configure_serve
