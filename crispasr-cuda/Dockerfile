# CrispASR publishes the GPU-enabled server binary and runtime dependencies in this image.
# This app adds the Home Assistant options-to-environment bridge.
FROM ghcr.io/crispstrobe/crispasr:main-cuda

USER root
ENV CRISPASR_GPU_BACKEND=cuda

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/crispasr-ha
RUN chmod 0755 /usr/local/bin/crispasr-ha

# Run as root so the Supervisor-provided options and GPU device nodes are readable.
EXPOSE 10300/tcp

HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
    CMD sh -c 'printf "{\\\"type\\\":\\\"describe\\\"}\\n" | nc -w 5 127.0.0.1 10300 | grep -q "\\\"type\\\":\\\"info\\\""'

ENTRYPOINT ["/usr/local/bin/crispasr-ha"]
