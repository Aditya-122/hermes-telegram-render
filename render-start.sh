#!/usr/bin/env bash
set -euo pipefail

export PYTHONUNBUFFERED=1

export HERMES_INSTALL_DIR=/opt/render/project/src/hermes-agent
export HERMES_HOME="${HERMES_HOME:-/opt/render/project/src/.hermes-runtime}"

case "${HERMES_MODEL_PROVIDER:-}" in
  ""|"openai")
    export HERMES_MODEL_PROVIDER="openai-api"
    ;;
esac

export HERMES_MODEL="${HERMES_MODEL:-gpt-4o}"

HERMES_BIN="$HERMES_INSTALL_DIR/venv/bin/hermes"
PY="$HERMES_INSTALL_DIR/venv/bin/python"

export PATH="$HERMES_INSTALL_DIR/venv/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export TELEGRAM_WEBHOOK_PORT="${PORT:-10000}"

: "${TELEGRAM_BOT_TOKEN:?Missing TELEGRAM_BOT_TOKEN}"
: "${TELEGRAM_ALLOWED_USERS:?Missing TELEGRAM_ALLOWED_USERS}"
: "${TELEGRAM_WEBHOOK_URL:?Missing TELEGRAM_WEBHOOK_URL}"
: "${TELEGRAM_WEBHOOK_SECRET:?Missing TELEGRAM_WEBHOOK_SECRET}"

if [ "$HERMES_MODEL_PROVIDER" = "openai-api" ]; then
  : "${OPENAI_API_KEY:?Missing OPENAI_API_KEY}"
  unset OPENAI_BASE_URL
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

echo "Effective provider: $HERMES_MODEL_PROVIDER"
echo "Effective model: $HERMES_MODEL"

"$HERMES_BIN" config set model.provider "$HERMES_MODEL_PROVIDER"
"$HERMES_BIN" config set model.default "$HERMES_MODEL"

"$PY" - <<'PY'
import os
from pathlib import Path
import yaml

home = Path(os.environ["HERMES_HOME"])
cfg_path = home / "config.yaml"

cfg = {}
if cfg_path.exists():
    cfg = yaml.safe_load(cfg_path.read_text()) or {}

cfg.setdefault("model", {})
cfg["model"]["provider"] = os.environ.get("HERMES_MODEL_PROVIDER", "openai-api")
cfg["model"]["default"] = os.environ.get("HERMES_MODEL", "gpt-4o")

# Critical: remove stale OpenRouter/custom endpoint settings.
cfg["model"].pop("base_url", None)
cfg["model"].pop("api_key", None)

cfg_path.write_text(yaml.safe_dump(cfg, sort_keys=False))

print("Cleaned Hermes config:", cfg_path)
print("model.provider =", cfg["model"]["provider"])
print("model.default =", cfg["model"]["default"])
print("model.base_url =", cfg["model"].get("base_url"))
PY

echo "Current Hermes config:"
"$HERMES_BIN" config || true

echo "Starting Hermes Telegram webhook on 0.0.0.0:${TELEGRAM_WEBHOOK_PORT}"
echo "Webhook URL: ${TELEGRAM_WEBHOOK_URL}"

exec "$HERMES_BIN" gateway run
