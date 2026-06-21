bash
    #!/usr/bin/env bash
    set -euo pipefail
    
    export PYTHONUNBUFFERED=1
    
    export HERMES_INSTALL_DIR=/opt/render/project/src/hermes-agent
    export HERMES_HOME="${HERMES_HOME:-/opt/render/project/src/.hermes-runtime}"
    
    HERMES_BIN="$HERMES_INSTALL_DIR/venv/bin/hermes"
    
    export PATH="$HERMES_INSTALL_DIR/venv/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
    export TELEGRAM_WEBHOOK_PORT="${PORT:-10000}"
    
    : "${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN}"
    : "${TELEGRAM_ALLOWED_USERS:?Missing TELEGRAM_ALLOWED_USERS}"
    : "${TELEGRAM_WEBHOOK_URL:?Missing TELEGRAM_WEBHOOK_URL}"
    : "${TELEGRAM_WEBHOOK_SECRET:?Missing TELEGRAM_WEBHOOK_SECRET}"
    
    mkdir -p "$HERMES_HOME"
    
    if [ ! -f "$HERMES_HOME/config.yaml" ] && [ -d /opt/render/project/src/.hermes-build ]; then
      cp -R /opt/render/project/src/.hermes-build/. "$HERMES_HOME"/
    fi
    
    test -x "$HERMES_BIN" || {
      echo "Hermes missing at $HERMES_BIN"
      ls -la "$HERMES_INSTALL_DIR/venv/bin" || true
      exit 127
    }
    
    if [ -n "${HERMES_MODEL_PROVIDER:-}" ]; then
      "$HERMES_BIN" config set model.provider "$HERMES_MODEL_PROVIDER"
    fi
    
    if [ -n "${HERMES_MODEL:-}" ]; then
      "$HERMES_BIN" config set model.default "$HERMES_MODEL"
    fi
    
    echo "Starting Hermes Telegram webhook on 0.0.0.0:${TELEGRAM_WEBHOOK_PORT}"
    echo "Webhook URL: ${TELEGRAM_WEBHOOK_URL}"
    
    exec "$HERMES_BIN" gateway run
