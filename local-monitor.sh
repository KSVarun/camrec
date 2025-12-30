gst-launch-1.0 \
  srtclientsrc uri="srt://127.0.0.1:8890?mode=caller&streamid=read:cam1" \
  ! tsdemux \
  ! h264parse config-interval=1 \
  ! avdec_h264 \
  ! videoconvert \
  ! waylandsink fullscreen=true
