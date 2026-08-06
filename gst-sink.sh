HOST=192.168.1.5
PORT=5000

while getopts h:p: OPT; do
    case $OPT in
	h) HOST=$OPTARG ;;
	p) PORT=$OPTARG ;;
	*) exit 1 ;;
    esac
done

gst-launch-1.0 \
  libcamerasrc ! \
  video/x-raw,width=1536,height=864,framerate=30/1,format=NV12 ! \
  videoconvert ! \
  x264enc bitrate=2500 speed-preset=veryfast tune=zerolatency ! \
  h264parse ! \
  rtph264pay config-interval=1 pt=96 ! \
  udpsink host=$HOST port=$PORT
