#!/bin/bash
set -euo pipefail

INPUT="${1:-/workspace/media/input/input.mp4}"
OUT_BASE="${2:-/workspace/media/output}"
SEG_DUR="${3:-4}"

[ -f "$INPUT" ] || { echo "Fitxategia ez da aurkitu: $INPUT" >&2; exit 1; }

NAME="$(basename "${INPUT%.*}")"
HLS_DIR="$OUT_BASE/streams/hls/$NAME"
mkdir -p "$HLS_DIR"

# Ladder (altura / bitrate)
HEIGHTS=(1080 720 480 360 240)
VBR=(6000k 3000k 1500k 800k 400k)

echo "[HLS] Aldaera eta master fitxategia sortzen..."
MASTER="$HLS_DIR/master.m3u8"
echo "#EXTM3U" > "$MASTER"
echo "#EXT-X-VERSION:3" >> "$MASTER"

for i in "${!HEIGHTS[@]}"; do
  H="${HEIGHTS[$i]}"
  B="${VBR[$i]}"
  VAR_PL="${NAME}_${H}p.m3u8"

  ffmpeg -hide_banner -y -i "$INPUT" \
    -vf "scale=-2:${H}" \
    -c:v libx264 -preset veryfast -b:v "$B" \
    -c:a aac -b:a 128k \
    -hls_time "$SEG_DUR" -hls_playlist_type vod -hls_list_size 0 \
    -hls_segment_filename "$HLS_DIR/${NAME}_${H}p_%03d.ts" \
    "$HLS_DIR/$VAR_PL"

  BW=$(( ${B%k} * 1000 ))
  echo "#EXT-X-STREAM-INF:BANDWIDTH=$BW,RESOLUTION=$(printf "%dx%d" 1920 "$H")" >> "$MASTER"
  echo "$VAR_PL" >> "$MASTER"
done

echo "Amaituta: /streams/hls/$NAME/master.m3u8"