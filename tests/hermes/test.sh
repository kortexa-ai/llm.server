#!/bin/bash

# Default values
DEFAULT_MODEL="adamo1139/Hermes-3-Llama-3.1-8B-FP8-Dynamic"
DEFAULT_PROMPT="Hello, this is a test message. Can you respond?"

# Use command-line arguments or defaults
# MODEL="${1:-$DEFAULT_MODEL}"
MODEL=$DEFAULT_MODEL
PROMPT="${*:-$DEFAULT_PROMPT}"

# Run the curl command and capture the JSON response
RESPONSE=$(curl -X POST https://hermes2.ai.unturf.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "'"$MODEL"'",
        "messages": [
            {"role": "user", "content": "'"$PROMPT"'"}
        ]
    }' 2>/dev/null)

# Check if curl was successful
if [ $? -ne 0 ]; then
    echo "Error: API request failed."
    exit 1
fi

# Extract the content using jq
CONTENT=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')

# Check if jq parsed successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to parse JSON response."
    echo "Response: $RESPONSE"
    exit 1
fi

# Print the content
echo "Assistant Response: $CONTENT"