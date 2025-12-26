#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

LOG="${HOME}/.local/state/cdmpv/live-desktop-mpv.log"
mkdir -p "$(dirname "$LOG")"

FPS=${FPS:-30}
HOST_DISPLAY=${HOST_DISPLAY:-:0}

{
  echo
  echo "==== live-desktop-mpv starting $(date -Is) ===="
} >>"$LOG"

RES=$(xdpyinfo | awk '/dimensions:/ {print $2; exit}')
WIDTH=${RES%x*}
HEIGHT=${RES#*x}

echo "Resolution: ${WIDTH}x${HEIGHT}" >>"$LOG"

FFMPEG_CMD=(
  ffmpeg
  -hide_banner
  -loglevel error
  -nostdin
  -fflags nobuffer
  -f x11grab
  -video_size "${WIDTH}x${HEIGHT}"
  -framerate "${FPS}"
  -i "${HOST_DISPLAY}"
  -pix_fmt yuv420p
  -f nut
  -
)

MPV_CMD=(
  mpv
  --no-audio
  --force-window=yes
  --keep-open=yes
  --untimed
  --cache=no
  --demuxer-lavf-format=nut
  -
)

set -o pipefail

echo "Launching pipeline…" >>"$LOG"

"${FFMPEG_CMD[@]}" | "${MPV_CMD[@]}" >>"$LOG" 2>&1

RC=$?

echo "Pipeline exited with code $RC" >>"$LOG"
exit "$RC"
