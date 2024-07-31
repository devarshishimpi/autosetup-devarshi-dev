#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Configure to setup MinIO to run in background and start on boot
configure_minio() {
    echo -e "${YELLOW}mkdir /home/devarshi/prod${NC}"
    mkdir -p /home/devarshi/prod

    echo -e "${YELLOW}mkdir /home/devarshi/prod/minios3${NC}"
    mkdir -p /home/devarshi/prod/minios3

    echo -e "${YELLOW}Creating systemd service file...${NC}"
    sudo bash -c "cat <<EOF > /etc/systemd/system/minio.service
[Unit]
Description=MinIO
Documentation=https://docs.min.io
Wants=network-online.target
After=network-online.target

[Service]
User=devarshi
Group=devarshi
EnvironmentFile=/etc/default/minio
ExecStart=/usr/local/bin/minio server /home/devarshi/prod/minios3
Restart=always
RestartSec=10s
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF"

    echo -e "${YELLOW}sudo systemctl daemon-reload${NC}"
    sudo systemctl daemon-reload

    echo -e "${YELLOW}sudo systemctl start minio.service${NC}"
    sudo systemctl start minio.service

    echo -e "${YELLOW}sudo systemctl enable minio.service${NC}"
    sudo systemctl enable minio.service
}

configure_minio
