#!/bin/bash
set -e  # Exit on any error

SERVICE_NAME="kortexa-ai-llm"

echo "Stopping $SERVICE_NAME service..."
sudo systemctl stop "$SERVICE_NAME" || true  # Don't fail if already stopped

echo "Disabling $SERVICE_NAME service..."
sudo systemctl disable "$SERVICE_NAME" || true  # Don't fail if already disabled

echo "Removing service file..."
sudo rm -f "/etc/systemd/system/$SERVICE_NAME.service"

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Service uninstallation complete."
