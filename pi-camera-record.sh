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

# having preset as veryfast will increase the CPU usage but reduces the file size, it will be less than 10MB for 2 minute, 
# having preset as ultrafast will reduce the CPU usage but increases the file size will be around 30MB for 2 minute.

 ffmpeg -rtsp_transport tcp -use_wallclock_as_timestamps 1 -fflags +genpts -i "$CAMERA_RTSP" \
    -c:v libx264 -preset veryfast -crf 30 \
    -c:a aac -b:a 96k \
    -f segment \
    -segment_time $CHUNK_DURATION \
    -reset_timestamps 1 \
    -strftime 1 \
    "$OUTPUT_DIR/camera_%Y%m%d_%H%M%S.mp4"

# ffmpeg -rtsp_transport tcp -use_wallclock_as_timestamps 1 -fflags +genpts \
#   -i "$CAMERA_RTSP" \
#   -map 0:v -map 0:a \
#   -c:v libx264 -preset ultrafast -crf 30 \
#   -c:a aac -b:a 96k \
#   -f tee "[select=v:a:f=segment:segment_time=$CHUNK_DURATION:reset_timestamps=1:strftime=1]$OUTPUT_DIR/camera_%Y%m%d_%H%M%S.mp4|[f=flv]rtmp://localhost/live/cam1"


# ffmpeg -rtsp_transport tcp -i "$CAMERA_RTSP" \
#     -use_wallclock_as_timestamps 1 -fflags +genpts -avoid_negative_ts make_zero \
#     -af "asetpts=N/SR/TB" \
#     -map 0:v:0 -map 0:a:0 \
#     -c:v libx264 -preset veryfast -tune zerolatency -pix_fmt yuv420p -profile:v baseline \
#     -c:a aac -ar 44100 -ac 2 -b:a 128k \
#     -f segment \
#     -segment_time $CHUNK_DURATION \
#     -reset_timestamps 1 \
#     -strftime 1 \
#     "$OUTPUT_DIR/camera_%Y%m%d_%H%M%S.mp4" \
#     -map 0:v:0 -map 0:a:0 \
#     -c:v copy \
#     -c:a aac -ar 44100 -ac 1 -b:a 64k \
#     -f flv -flvflags no_duration_filesize+no_sequence_end "rtmp://localhost/live/cam1"