CAMERA_RTSP="rtsp://192.168.1.2:554/ch0_0.h264"
ffplay -rtsp_transport tcp \
  -use_wallclock_as_timestamps 1 \
  -fflags +genpts \
  -fflags nobuffer \
  -flags low_delay \
  -strict experimental \
  -fflags discardcorrupt \
  "$CAMERA_RTSP"
