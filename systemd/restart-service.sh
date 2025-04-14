#!/bin/bash
set -e  # Exit on any error

SERVICE_NAME="kortexa-ai-llm"

echo "Restarting $SERVICE_NAME service..."
sudo systemctl restart $SERVICE_NAME || { echo "$SERVICE_NAME restart failed"; exit 1; }

echo "Reloading Nginx..."
sudo systemctl reload nginx || { echo "Nginx reload failed"; exit 1; }

echo "Checking services status..."
echo "------- Nginx Status -------"
sudo systemctl status nginx | head -n 4
echo "------- $SERVICE_NAME Status -------"
sudo systemctl status $SERVICE_NAME | head -n 4

sudo journalctl -u $SERVICE_NAME -n 50

echo "Done!"
