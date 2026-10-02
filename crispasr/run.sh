#!/usr/bin/env bash
set -euo pipefail

readonly OPTIONS_FILE=/data/options.json
readonly WYOMING_PORT=10300
readonly HTTP_PORT=8080

log() {
    echo "[crispasr-ha] $*" >&2
}

fail() {
    log "ERROR: $*"
    exit 1
}

[[ -r "$OPTIONS_FILE" ]] || fail "Home Assistant options file is not readable: $OPTIONS_FILE"

model="$(jq -er '.model | strings | select(length > 0)' "$OPTIONS_FILE")" \
    || fail "The 'model' option must be a non-empty path."
backend="$(jq -er '.backend // "" | strings' "$OPTIONS_FILE")" \
    || fail "The 'backend' option must be a string."
language="$(jq -er '.language | strings | select(length > 0)' "$OPTIONS_FILE")" \
    || fail "The 'language' option must be a non-empty string."
threads="$(jq -er '.threads | numbers | select(floor == . and . >= 1)' "$OPTIONS_FILE")" \
    || fail "The 'threads' option must be a positive integer."

# The Supervisor mounts the host's share directory at /share because of the
# `share:ro` mapping in config.yaml. Models are intentionally not downloaded by
# this app: install the selected GGUF there before starting it.
[[ -r "$model" ]] || fail "Model is not readable: $model. Copy the GGUF model into /share and update the model option."

export CRISPASR_MODEL="$model"
export CRISPASR_LANGUAGE="$language"
export CRISPASR_PORT="$HTTP_PORT"
export CRISPASR_SERVER_HOST="127.0.0.1"
export CRISPASR_AUTO_DOWNLOAD=0
export CRISPASR_EXTRA_ARGS="--wyoming-port $WYOMING_PORT --threads $threads"

if [[ -n "$backend" ]]; then
    export CRISPASR_BACKEND="$backend"
fi

log "Starting CrispASR with model '$model', language '$language', and $threads thread(s)."
log "Starting Wyoming on tcp://0.0.0.0:$WYOMING_PORT."

# The upstream entrypoint validates the model and execs the CrispASR server.
# CRISPASR_EXTRA_ARGS appends --wyoming-port to that server command.
exec /app/.devops/run-server.sh
