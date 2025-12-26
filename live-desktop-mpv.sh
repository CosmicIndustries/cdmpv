#!/usr/bin/env bash
set -euo pipefail

### CONFIG ###
FRAMERATE=30
PRESET=ultrafast
DISPLAY=${DISPLAY:-:0}
PIPE=/tmp/cdmpv.pipe

### Clean up any previous broken pipe ###
rm -f "$PIPE"
mkfifo "$PIPE"

### Detect primary monitor ###
MONITOR=$(xrandr --listmonitors | awk '/\*/ {print $4; exit}')
[[ -n "$MONITOR" ]] || { echo "No active monitor detected"; exit 1; }

echo "Capturing monitor: $MONITOR"

### Get geometry safely ###
### Get exact geometry from xrandr line ###
GEOMETRY=$(xrandr | awk -v m="$MONITOR" '
$0 ~ ("^"m" ") {
  for (i=1;i<=NF;i++) {
    if ($i ~ /^[0-9]+x[0-9]+\+[0-9]+\+[0-9]+$/) {
      print $i;
      exit
    }
  }
}')


WIDTH=${GEOMETRY%%x*}
REST=${GEOMETRY#*x}
HEIGHT=${REST%%+*}
OFFS=${GEOMETRY#*+}

XOFF=${OFFS%%+*}
YOFF=${OFFS#*+}

echo "Geometry: ${WIDTH}x${HEIGHT}+${XOFF}+${YOFF}"

### Start ffmpeg ###
ffmpeg -y \
  -f x11grab \
  -framerate "$FRAMERATE" \
  -video_size "${WIDTH}x${HEIGHT}" \
  -i "${DISPLAY}+${XOFF},${YOFF}" \
  -c:v libx264 \
  -preset "$PRESET" \
  -tune zerolatency \
  -pix_fmt yuv420p \
  -f nut "$PIPE" &

FFPID=$!

### Wait for ffmpeg to initialize stream ###
sleep 0.4

### Start mpv ###
mpv --no-cache --profile=low-latency "$PIPE"

### Cleanup ###
kill "$FFPID" 2>/dev/null || true
rm -f "$PIPE"
