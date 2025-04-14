#!/bin/bash
set -e  # Exit on any error

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICE_NAME="kortexa-ai-llm"
SERVICE_FILE="$SERVICE_NAME.service"

echo "Installing $SERVICE_NAME systemd service..."

# Copy service file to systemd directory
sudo cp "$SCRIPT_DIR/$SERVICE_FILE" "/etc/systemd/system/"

# Reload systemd daemon to recognize new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Enable and start the service
echo "Enabling and starting $SERVICE_NAME service..."
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Service installation complete. Status:"
sudo systemctl status "$SERVICE_NAME"
