#!/usr/bin/env bash
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export DISPLAY=:0
export XAUTHORITY=/home/user/.Xauthority
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

cd /home/user/cdmpv
exec /bin/bash /home/user/cdmpv/live-desktop-mpv.sh
