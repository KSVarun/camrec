#!/bin/bash
umask 007

LOG_FILE="/var/log/pi_stream_logger/service.log"
exec >> "$LOG_FILE" 2>&1

CAMERA_RTSP="rtsp://192.168.1.2:554/ch0_0.h264"

ffmpeg -rtsp_transport tcp \
-i "$CAMERA_RTSP" \
-c:v copy \
-c:a libopus \
-ac 1 \
-ar 48000 \
-b:a 64k \
-f mpegts \
"srt://127.0.0.1:8890?mode=caller&latency=50&streamid=publish:cam1"

