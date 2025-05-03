#!/bin/bash

# if llama-server command is not found, print a message and exit
if ! command -v llama-server &> /dev/null; then
    echo "llama-server could not be found"
    exit 1
fi

llama-server -hf Qwen/Qwen3-32B-GGUF:Q8_0 --host 0.0.0.0 --port 8012 -c 32768
# llama-server -hf Qwen/Qwen3-32B-GGUF:Q8_0 --host 0.0.0.0 --port 8012 -c 131072 --rope-scaling yarn --rope-scale 4 --yarn-orig-ctx 32768

# llama-server -hf unsloth/gemma-3-27b-it-GGUF:Q8_0 --seed 3407 --prio 2 --temp 1.0 --repeat-penalty 1.0 --min-p 0.01 --top-k 64 --top-p 0.95 --host 0.0.0.0 --port 8012 --threads 16 --n-gpu-layers 99 -fa -ctk q8_0 -ctv q8_0 --ctx-size 65536

# llama-cli -hf unsloth/DeepSeek-R1-GGUF:UD-IQ1_S -ctk q4_0 --threads 16 --prio 2 --temp 0.6 --seed 3407 -ngl 0 -no-cnv -c 4096 --prompt "<｜User｜>Create a Flappy Bird game in Python.<｜Assistant｜>"

# llama-server -hf unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q3_K_M --host 0.0.0.0 --port 8012 -ngl 99 -fa -ub 1024 --threads 16 --ctx-size 65536 -ctk q4_0 -ctv q4_0
# llama-server -hf unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q3_K_M --host 0.0.0.0 --port 8012 -ngl 99 -fa -ub 1024 --threads 16 --ctx-size 0 -ctk q4_0 -ctv q4_0 --cache-reuse 256

# llama-server -hf unsloth/DeepSeek-R1-GGUF:Q2_K_L --host 0.0.0.0 --port 8012 --threads 16 --ctx-size 0 -ctk q4_0 -ctv q4_0 -fa

# llama-server -hf unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF:Q8_0 --host 0.0.0.0 --port 8012 -fa -ub 1024 --threads 16 --ctx-size 0 -ctk q4_0 -ctv q4_0

# unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q3_K_M
# unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q4_K_M
# unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q5_K_M
# unsloth/DeepSeek-R1-Distill-Qwen-32B-GGUF:Q6_K

# unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF:Q8_0

# unsloth/DeepSeek-R1-GGUF:Q2_K_L