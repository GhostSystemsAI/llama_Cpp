FROM ghcr.io/ggml-org/llama.cpp:server-cuda
# Blank the baked-in ENTRYPOINT so RunPod's dockerArgs runs as CMD (bash -c "...").
# The upstream image has ENTRYPOINT ["/app/llama-server"] which swallows our startup
# script as arguments to llama-server -> immediate arg-parse error -> crash-loop.
ENTRYPOINT []
# Bake the HF CLI so `hf download` resolves at pod boot WITHOUT the ~5-15min apt+pip the
# startup script otherwise runs (which is guarded by `if ! command -v hf` in fleet.py, so a
# baked CLI turns that boot step into a no-op).
#
# The upstream server-cuda image ships BARE python3 — no pip, no hf CLI (verified 2026-07-01).
# So `pip` does not exist: the previous `RUN pip install ...` line failed every build since
# 2026-07-01 with `pip: not found` (exit 127) and no image was ever produced. Fix mirrors the
# proven runtime bootstrap (fleet.py:743): apt-install python3-pip, then `python3 -m pip`.
# hf_transfer is intentionally OMITTED — deprecated in huggingface_hub>=1.21 (Xet high-perf via
# HF_XET_HIGH_PERFORMANCE is used instead), and it has no prebuilt wheel here so it would need a
# Rust toolchain to compile.
RUN apt-get update && apt-get install -y --no-install-recommends python3-pip && \
    python3 -m pip install --break-system-packages -q -U huggingface_hub && \
    rm -rf /var/lib/apt/lists/* && python3 -m pip cache purge
