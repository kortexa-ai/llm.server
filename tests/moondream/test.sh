#!/bin/bash

# Default values
DEFAULT_IMAGE="city_street.jpeg"
DEFAULT_OBJECT="face"

# Use command-line arguments or defaults
IMAGE_FILE="${1:-$DEFAULT_IMAGE}"
OBJECT_TYPE="${2:-$DEFAULT_OBJECT}"

# Check if the image file exists
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: Image file '$IMAGE_FILE' not found."
    exit 1
fi

# Run the curl command
curl --location 'https://moondream.ai.unturf.com/v1/detect' \
    --header 'Content-Type: application/json' \
    --data '{
        "image_url": "data:image/jpeg;base64,'$(base64 -w 0 -i "$IMAGE_FILE")'",
        "object": "'"$OBJECT_TYPE"'"
    }'