#!/bin/bash
source .venv/bin/activate
python -m vllm.entrypoints.openai.api_server \
    --model adamo1139/Hermes-3-Llama-3.1-8B-FP8-Dynamic \
    --host 0.0.0.0 \
    --port 18888 \
    --max-model-len 48000
