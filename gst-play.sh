PORT=5000

while getopts p: OPT; do
    case $OPT in
	p) PORT=$OPTARG ;;
	*) exit 1 ;;
    esac
done

gst-launch-1.0 \
    udpsrc port=$PORT \
    caps="application/x-rtp,media=video,encoding-name=H264,payload=96" ! \
    rtph264depay ! \
    h264parse ! \
    avdec_h264 ! \
    videoconvert ! \
    autovideosink
