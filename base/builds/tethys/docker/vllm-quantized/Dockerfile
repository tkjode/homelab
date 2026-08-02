# Use the official vLLM OpenAI compatible server image as the base
FROM vllm/vllm-openai:v0.26.0

# Update gguf library to version 0.14.0
# Uninstall any existing version first to ensure a clean install
RUN pip uninstall -y gguf && \
    pip install --no-cache-dir gguf==0.19.0 && \
    pip install vllm-gguf-plugin