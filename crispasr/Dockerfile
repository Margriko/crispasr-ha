# CrispASR publishes the server binary and its runtime dependencies in this image.
# This app adds the Home Assistant options-to-environment bridge only.
FROM ghcr.io/crispstrobe/crispasr:main

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends jq netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /usr/local/bin/crispasr-ha
RUN chmod 0755 /usr/local/bin/crispasr-ha

USER crispasr

EXPOSE 10300/tcp

# A Wyoming `describe` request verifies that the model-loaded server accepts the
# protocol consumed by Home Assistant, rather than only checking an open socket.
HEALTHCHECK --interval=30s --timeout=10s --start-period=5m --retries=3 \
    CMD sh -c 'printf "{\\\"type\\\":\\\"describe\\\"}\\n" | nc -w 5 127.0.0.1 10300 | grep -q "\\\"type\\\":\\\"info\\\""'

ENTRYPOINT ["/usr/local/bin/crispasr-ha"]
