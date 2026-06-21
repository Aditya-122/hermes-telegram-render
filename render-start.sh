#!/usr/bin/env bash
    set -euo pipefail
    
    HERMES_BIN="/opt/render/project/src/hermes-agent/venv/bin/hermes"
    
    export PATH="/opt/render/project/src/hermes-agent/venv/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
    export TELEGRAM_WEBHOOK_PORT="${PORT:-10000}"
    
    mkdir -p "${HERMES_HOME:-$HOME/.hermes}"
    
    if [ ! -x "$HERMES_BIN" ]; then
      echo "Hermes missing at $HERMES_BIN"
      ls -la /opt/render/project/src/hermes-agent/venv/bin || true
      exit 127
    fi
    
    if [ -n "${HERMES_MODEL_PROVIDER:-}" ]; then
      "$HERMES_BIN" config set model.provider "$HERMES_MODEL_PROVIDER"
    fi
    
    if [ -n "${HERMES_MODEL:-}" ]; then
      "$HERMES_BIN" config set model.default "$HERMES_MODEL"
    fi
    
    exec "$HERMES_BIN" gateway run
