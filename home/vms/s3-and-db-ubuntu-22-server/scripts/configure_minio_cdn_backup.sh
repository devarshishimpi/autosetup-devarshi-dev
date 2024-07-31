#!/bin/bash

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to configure MinIO sync script and service
configure_minio() {
    # Prompt user for inputs
    echo -e "${GREEN}Please enter the following details:${NC}"

    read -p "MinIO Bucket Name: " MINIO_BUCKET
    read -p "MinIO Access Key: " MINIO_ACCESS_KEY
    read -p "MinIO Secret Key: " MINIO_SECRET_KEY
    read -p "AWS S3 Bucket: " AWS_BUCKET
    read -p "AWS Region: " AWS_REGION
    read -p "AWS Access Key: " AWS_ACCESS_KEY
    read -p "AWS Secret Key: " AWS_SECRET_KEY

    echo -e "${YELLOW}Creating bash script for sync...${NC}"
    sudo bash -c "cat <<EOL > /usr/local/bin/minio_aws_sync.sh
#!/bin/bash

# MinIO S3 details
MINIO_ENDPOINT=\"http://localhost:9000\"
MINIO_BUCKET=\"$MINIO_BUCKET\"
MINIO_ACCESS_KEY=\"$MINIO_ACCESS_KEY\"
MINIO_SECRET_KEY=\"$MINIO_SECRET_KEY\"

# AWS S3 details
AWS_BUCKET=\"$AWS_BUCKET\"
AWS_REGION=\"$AWS_REGION\"
AWS_ACCESS_KEY=\"$AWS_ACCESS_KEY\"
AWS_SECRET_KEY=\"$AWS_SECRET_KEY\"

# AWS CLI path
AWS_CLI=\"/usr/local/bin/aws\"

# Log file
LOG_FILE=\"/var/log/minio_aws_sync.log\"

# Function to log messages
log_message() {
    echo \"\$(date '+%Y-%m-%d %H:%M:%S') - \$1\" >> \"\$LOG_FILE\"
    echo \"\$(date '+%Y-%m-%d %H:%M:%S') - \$1\"
}

# Function to perform the sync
sync_s3() {
    log_message \"Starting sync process...\"

    # Configure AWS CLI with MinIO credentials
    export AWS_ACCESS_KEY_ID=\$MINIO_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=\$MINIO_SECRET_KEY

    log_message \"Syncing from MinIO to local...\"
    \$AWS_CLI s3 sync s3://\$MINIO_BUCKET /tmp/minio_backup --endpoint-url \http://localhost:9000
    if [ \$? -ne 0 ]; then
        log_message \"Error: Failed to sync from MinIO to local\"
        return 1
    fi

    # Configure AWS CLI with AWS credentials
    export AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY
    export AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_KEY

    log_message \"Syncing from local to AWS S3...\"
    \$AWS_CLI s3 sync /tmp/minio_backup s3://\$AWS_BUCKET --region \$AWS_REGION
    if [ \$? -ne 0 ]; then
        log_message \"Error: Failed to sync from local to AWS S3\"
        return 1
    fi

    log_message \"Cleaning up...\"
    rm -rf /tmp/minio_backup

    log_message \"Sync process completed successfully.\"
    return 0
}

# Main loop
while true; do
    if sync_s3; then
        log_message \"Sync completed successfully. Sleeping for 24 hours.\"
    else
        log_message \"Sync failed. Retrying in 1 hour.\"
        sleep 3600  # Sleep for 1 hour before retrying
        continue
    fi
    sleep 86400  # Sleep for 24 hours
done
EOL"

    echo -e "${YELLOW}Setting execute permissions for the script...${NC}"
    sudo chmod +x /usr/local/bin/minio_aws_sync.sh

    echo -e "${YELLOW}Creating systemd service file...${NC}"
    sudo bash -c "cat <<EOF > /etc/systemd/system/minio-aws-sync.service
[Unit]
Description=MinIO to AWS S3 Sync Service
After=network.target

[Service]
ExecStart=/usr/local/bin/minio_aws_sync.sh
User=root
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

    echo -e "${YELLOW}Reloading systemd daemon...${NC}"
    sudo systemctl daemon-reload

    echo -e "${YELLOW}Starting MinIO to AWS sync service...${NC}"
    sudo systemctl start minio-aws-sync.service

    echo -e "${YELLOW}Enabling MinIO to AWS sync service to start on boot...${NC}"
    sudo systemctl enable minio-aws-sync.service

    echo -e "${GREEN}MinIO to AWS sync service has been configured successfully.${NC}"
}

configure_minio
