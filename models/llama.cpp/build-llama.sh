#!/bin/bash

# if ~/src/llama.cpp doesn't exit, print a message, and exit
if [ ! -d "~/src/llama.cpp" ]; then
    echo "~/src/llama.cpp doesn't exist"
    exit 1
fi

# sudo apt install libcurl4-openssl-dev ccache

cd ~/src/llama.cpp
# Nvidida CUDA
# cmake -B build -DGGML_CUDA=ON -DLLAMA_CURL=ON
# Pi CPU
# cmake -B build -DLLAMA_CURL=ON
# OSX Metal
cmake -B build -DGGML_METAL=ON -DLLAMA_CURL=ON
cmake --build build --config Release -j 8

# Ubuntu
ln -s /home/$USER/src/llama.cpp/build/bin/llama-cli llama-cli
ln -s /home/$USER/src/llama.cpp/build/bin/llama-server llama-server
# OSX
# ln -s /Users/$USER/src/llama.cpp/build/bin/llama-cli llama-cli
# ln -s /Users/$USER/src/llama.cpp/build/bin/llama-server llama-server