#!/usr/bin/env bash
    set -euo pipefail
    
    export HERMES_HOME=/opt/render/project/src/.hermes-build
    export HERMES_INSTALL_DIR=/opt/render/project/src/hermes-agent
    
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup --skip-browser --dir "$HERMES_INSTALL_DIR"
    
    "$HERMES_INSTALL_DIR/venv/bin/hermes" --version
