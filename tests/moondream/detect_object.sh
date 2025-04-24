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

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required to parse JSON. Install it with 'brew install jq' (macOS) or 'sudo apt-get install jq' (Linux)."
    exit 1
fi

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is required. Install it with 'brew install imagemagick' (macOS) or 'sudo apt-get install imagemagick' (Linux)."
    exit 1
fi

# Get the base name of the image file (without extension)
BASENAME=$(basename "$IMAGE_FILE" | cut -f 1 -d '.')

# Output image file
OUTPUT_IMAGE="${BASENAME}_framed.jpeg"

# Run the curl command and capture the JSON response
RESPONSE=$(curl --location 'https://moondream.ai.unturf.com/v1/detect' \
    --header 'Content-Type: application/json' \
    --data '{
        "image_url": "data:image/jpeg;base64,'$(base64 -w 0 -i "$IMAGE_FILE")'",
        "object": "'"$OBJECT_TYPE"'"
    }' 2>/dev/null)

# Check if curl command was successful
if [ $? -ne 0 ]; then
    echo "Error: API request failed."
    exit 1
fi

# Check if response contains valid JSON
if ! echo "$RESPONSE" | jq . >/dev/null 2>&1; then
    echo "Error: Invalid JSON response from API."
    echo "Response: $RESPONSE"
    exit 1
fi

# Get image dimensions using ImageMagick
DIMENSIONS=$(magick identify -format "%w %h" "$IMAGE_FILE")
if [ $? -ne 0 ]; then
    echo "Error: Failed to get image dimensions."
    exit 1
fi
read WIDTH HEIGHT <<< "$DIMENSIONS"

# Start building the ImageMagick draw command
DRAW_COMMANDS=""

# Parse JSON and convert normalized coordinates to pixel coordinates
OBJECTS=$(echo "$RESPONSE" | jq -r '.objects[] | "\(.x_min) \(.y_min) \(.x_max) \(.y_max)"')
if [ -z "$OBJECTS" ]; then
    echo "Warning: No objects detected in the image."
    # Copy the image without drawing
    magick "$IMAGE_FILE" "$OUTPUT_IMAGE"
else
    while read -r X_MIN Y_MIN X_MAX Y_MAX; do
        # Convert normalized coordinates to pixel coordinates
        PX_MIN=$(echo "$X_MIN * $WIDTH" | bc)
        PY_MIN=$(echo "$Y_MIN * $HEIGHT" | bc)
        PX_MAX=$(echo "$X_MAX * $WIDTH" | bc)
        PY_MAX=$(echo "$Y_MAX * $HEIGHT" | bc)

        # Round to integers (ImageMagick requires integer coordinates)
        PX_MIN=$(printf "%.0f" "$PX_MIN")
        PY_MIN=$(printf "%.0f" "$PY_MIN")
        PX_MAX=$(printf "%.0f" "$PX_MAX")
        PY_MAX=$(printf "%.0f" "$PY_MAX")

        # Append draw command for a green rectangle
        DRAW_COMMANDS="$DRAW_COMMANDS rectangle $PX_MIN,$PY_MIN $PX_MAX,$PY_MAX"
    done <<< "$OBJECTS"

    # Create a copy of the image and draw green rectangles
    magick "$IMAGE_FILE" -fill none -stroke green -strokewidth 2 -draw "$DRAW_COMMANDS" "$OUTPUT_IMAGE"
fi

# Check if the output image was created
if [ ! -f "$OUTPUT_IMAGE" ]; then
    echo "Error: Failed to create output image '$OUTPUT_IMAGE'."
    exit 1
fi

# Display the output image
if command -v imgcat &> /dev/null; then
    imgcat "$OUTPUT_IMAGE"
else
    open -a Preview "$OUTPUT_IMAGE"
fi
