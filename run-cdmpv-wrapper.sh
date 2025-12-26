#!/usr/bin/env bash
# run-cdmpv-wrapper.sh
# Wrapper used by systemd user unit. Sets environment that systemd may not provide,
# drops into cdmpv directory and exec's the main script. Keeps logging.

set -euo pipefail
IFS=$'\n\t'

# Ensure PATH is deterministic for systemd user units
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Ensure display/X env are set for GUI access (override if needed)
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

# Optional: allow overriding MPV/FFMPEG location via env
# cd into project directory and execute
cd "${HOME}/cdmpv" || {
  echo "Failed to cd into ${HOME}/cdmpv" >&2
  exit 1
}

# Provide a stable log header for each wrapper invocation (also appended by the script)
LOG="${HOME}/.local/state/cdmpv/live-desktop-mpv.log"
mkdir -p "$(dirname "$LOG")"
{
  echo "==== run-cdmpv-wrapper starting $(date -Is) (user=$(id -un), uid=$(id -u)) ===="
  echo "ENV: DISPLAY=${DISPLAY} XAUTHORITY=${XAUTHORITY} XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR} PATH=${PATH}"
} >>"$LOG" 2>&1

# Exec the live script (keeps pid in same cgroup as systemd service)
exec /bin/bash "${HOME}/cdmpv/live-desktop-mpv.sh" "$@"
