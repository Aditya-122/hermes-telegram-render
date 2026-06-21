 #!/usr/bin/env bash
    set -euo pipefail
    
    export PYTHONUNBUFFERED=1
    
    export HERMES_INSTALL_DIR=/opt/render/project/src/hermes-agent
    export HERMES_HOME="${HERMES_HOME:-/opt/render/project/src/.hermes-runtime}"
    
    export HERMES_MODEL_PROVIDER="${HERMES_MODEL_PROVIDER:-openai-api}"
    export HERMES_MODEL="${HERMES_MODEL:-gpt-5.4-mini}"
    
    HERMES_BIN="$HERMES_INSTALL_DIR/venv/bin/hermes"
    
    export PATH="$HERMES_INSTALL_DIR/venv/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
    export TELEGRAM_WEBHOOK_PORT="${PORT:-10000}"
    
    : "${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN}"
    : "${TELEGRAM_ALLOWED_USERS:?Missing TELEGRAM_ALLOWED_USERS}"
    : "${TELEGRAM_WEBHOOK_URL:?Missing TELEGRAM_WEBHOOK_URL}"
    : "${TELEGRAM_WEBHOOK_SECRET:?Missing TELEGRAM_WEBHOOK_SECRET}"
    
    if [ "$HERMES_MODEL_PROVIDER" = "openai-api" ]; then
      : "${OPENAI_API_KEY:?Missing OPENAI_API_KEY}"
    fi
    
    mkdir -p "$HERMES_HOME"
    
    if [ ! -f "$HERMES_HOME/config.yaml" ] && [ -d /opt/render/project/src/.hermes-build ]; then
      cp -R /opt/render/project/src/.hermes-build/. "$HERMES_HOME"/
    fi
    
    test -x "$HERMES_BIN" || {
      echo "Hermes missing at $HERMES_BIN"
      ls -la "$HERMES_INSTALL_DIR/venv/bin" || true
      exit 127
    }
    
    echo "Forcing Hermes model provider: $HERMES_MODEL_PROVIDER"
    echo "Forcing Hermes model: $HERMES_MODEL"
    
    "$HERMES_BIN" config set model.provider "$HERMES_MODEL_PROVIDER"
    "$HERMES_BIN" config set model.default "$HERMES_MODEL"
    
    echo "Current Hermes config:"
    "$HERMES_BIN" config || true
    
    echo "Starting Hermes Telegram webhook on 0.0.0.0:${TELEGRAM_WEBHOOK_PORT}"
    echo "Webhook URL: ${TELEGRAM_WEBHOOK_URL}"
    
    exec "$HERMES_BIN" gateway run
