#!/bin/bash
umask 007

LOG_FILE="/var/log/pi_stream_logger/service.log"
exec >> "$LOG_FILE" 2>&1

CAMERA_RTSP="rtsp://192.168.1.2:554/ch0_0.h264"

ffmpeg -rtsp_transport tcp \
-i "$CAMERA_RTSP" \
-map 0:v:0 -c:v copy \
-map 0:a:0 -c:a copy \
-f rtsp \
rtsp://127.0.0.1:8554/cam1
