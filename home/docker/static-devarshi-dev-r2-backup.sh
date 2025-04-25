#!/usr/bin/env bash
set -euo pipefail

while true; do
  DATE=$(date +%Y-%m-%d)

  if [ -d "/sync/static-devarshi-dev" ] && [ "$(ls -A /sync/static-devarshi-dev 2>/dev/null)" ]; then
    echo "Starting Cloudflare R2 backup to folder ${DATE} at $(date)"

    for attempt in 1 2 3; do
      if aws s3 cp /sync/static-devarshi-dev \
           s3://static-devarshi-dev-backup/${DATE}/ \
           --recursive \
           --endpoint-url https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com \
           --checksum-algorithm CRC32; then

        echo "Backup to ${DATE} succeeded at $(date)"
        mkdir -p /sync/static-devarshi-dev/.backup-history
        echo "Backup completed at $(date)" > /sync/static-devarshi-dev/.backup-history/backup-${DATE}.txt

        find /sync/static-devarshi-dev \
          -mindepth 1 \
          -not -path "/sync/static-devarshi-dev/.backup-history*" \
          -exec rm -rf {} \; 2>/dev/null || true
        echo "Local backup cleared at $(date)"
        break
      else
        echo "Attempt ${attempt} failed at $(date); retrying in 10s…"
        sleep 10
      fi
    done

    if [ "${attempt:-0}" -eq 3 ]; then
      echo "Backup to ${DATE} failed after 3 attempts; preserving local data."
    fi

  else
    echo "No files to backup at $(date); waiting…"
  fi

  sleep 86400  # run once every 24h
done
