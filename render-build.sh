  #!/usr/bin/env bash
    set -euo pipefail
    
    export HERMES_HOME=/opt/render/project/src/.hermes-build
    export HERMES_INSTALL_DIR=/opt/render/project/src/hermes-agent
    
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup --skip-browser --dir "$HERMES_INSTALL_DIR"
    
    UV="$HERMES_HOME/bin/uv"
    PY="$HERMES_INSTALL_DIR/venv/bin/python"
    HERMES="$HERMES_INSTALL_DIR/venv/bin/hermes"
    
    test -x "$UV" || { echo "uv missing at $UV"; exit 1; }
    test -x "$PY" || { echo "python missing at $PY"; exit 1; }
    
    cd "$HERMES_INSTALL_DIR"
    "$UV" pip install --python "$PY" -e '.[messaging]'
    
    "$PY" - <<'PY'
    import telegram
    from telegram.ext import Application
    print("Telegram dependency OK:", telegram.version)
    PY
    
    "$HERMES" --version
