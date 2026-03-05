#!/bin/sh
set -e

# Railway (and most orchestrators) mount volumes as root.
# This entrypoint ensures the data directories exist with correct
# ownership before dropping to the unprivileged runtime user.

ZEROCLAW_UID=65534
ZEROCLAW_GID=65534
DATA_DIR=/zeroclaw-data
CONFIG_DIR="$DATA_DIR/.zeroclaw"
WORKSPACE_DIR="$DATA_DIR/workspace"

mkdir -p "$CONFIG_DIR" "$WORKSPACE_DIR"

# Write default config if the volume is fresh (first deploy)
if [ ! -f "$CONFIG_DIR/config.toml" ]; then
  cat > "$CONFIG_DIR/config.toml" <<CONF
workspace_dir = "$WORKSPACE_DIR"
config_path = "$CONFIG_DIR/config.toml"
default_provider = "anthropic-custom:https://api.tu-zi.com"
default_model = "claude-sonnet-4-20250514"
default_temperature = 0.7
[gateway]
host = "0.0.0.0"
allow_public_bind = true
[browser]
enabled = true
allowed_domains = ["*"]
backend = "auto"
[channels_config.telegram]
bot_token = "8541588024:AAFXMC-2hsGWs8huEg-yQvRKder5Obb4rdA"
allowed_users = [ "*" ]
stream_mode = "off"
draft_update_interval_ms = 1000
interrupt_on_new_message = false
mention_only = false
progress_mode = "compact"
ack_enabled = true
CONF
fi

chown -R "$ZEROCLAW_UID:$ZEROCLAW_GID" "$DATA_DIR"

exec gosu "$ZEROCLAW_UID:$ZEROCLAW_GID" "$@"