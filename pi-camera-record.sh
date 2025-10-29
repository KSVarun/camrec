#!/bin/bash
umask 007

LOG_FILE="/var/log/pi_camrec_logger/service.log"
exec >> "$LOG_FILE" 2>&1
# ===============================
# CONFIGURATION
# ===============================
CAMERA_RTSP="rtsp://192.168.1.2:554/ch0_0.h264"
OUTPUT_DIR="/home/idks/develop/bash/camera_recordings"   # Change if needed
CHUNK_DURATION=120 # 5 minutes = 300 seconds

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# ===============================
# RECORDING LOOP
# ===============================

echo "Recording to $OUTPUT_DIR in 5-minute chunks..."

ffmpeg -rtsp_transport tcp -i "$CAMERA_RTSP" \
    -c:v copy -c:a aac -b:a 128k \
    -f segment \
    -segment_time $CHUNK_DURATION \
    -reset_timestamps 1 \
    -strftime 1 \
    "$OUTPUT_DIR/camera_%Y%m%d_%H%M%S.mp4"
