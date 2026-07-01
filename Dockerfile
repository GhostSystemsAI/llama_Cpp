FROM ghcr.io/ggml-org/llama.cpp:server-cuda
# Blank the baked-in ENTRYPOINT so RunPod's dockerArgs runs as CMD (bash -c "...").
# The upstream image has ENTRYPOINT ["/app/llama-server"] which swallows our startup
# script as arguments to llama-server -> immediate arg-parse error -> crash-loop.
ENTRYPOINT []
# Pre-bake hf_transfer + huggingface_hub so pod startup skips the runtime pip install.
# Without this the startup script runs a silent pip install (5-15 min, no output)
# before the first [gguf-boot] line appears, making pods look stuck.
RUN pip install --break-system-packages -q huggingface_hub hf_transfer && \
    pip cache purge
