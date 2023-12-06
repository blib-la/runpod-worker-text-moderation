# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Create a directory for the model
RUN mkdir /koalaai-text-moderation

WORKDIR /koalaai-text-moderation

# Get the Model from HuggingFace
RUN wget -O config.json https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/config.json
RUN wget -O model.safetensors https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/model.safetensors
RUN wget -O tokenizer_config.json https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/tokenizer_config.json
RUN wget -O vocab.json https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/vocab.json
RUN wget -O merges.txt https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/merges.txt
RUN wget -O tokenizer.json https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/tokenizer.json
RUN wget -O special_tokens_map.json https://huggingface.co/KoalaAI/Text-Moderation/resolve/main/special_tokens_map.json

# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json requirements.txt ./
RUN chmod +x /start.sh

# Install dependencies
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --no-cache-dir xformers==0.0.21 \
    && pip3 install -r requirements.txt

# Start the container
CMD /start.sh
