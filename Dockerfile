FROM ghcr.io/ggml-org/llama.cpp:server-cuda
# Blank the baked-in ENTRYPOINT so RunPod's dockerArgs runs as CMD (bash -c "...").
# The upstream image has ENTRYPOINT ["/app/llama-server"] which swallows our startup
# script as arguments to llama-server -> immediate arg-parse error -> crash-loop.
ENTRYPOINT []
