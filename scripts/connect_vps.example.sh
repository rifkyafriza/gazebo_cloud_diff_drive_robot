#!/bin/bash

echo "Cleaning up any old stuck processes..."
fuser -k -9 8080/tcp || true
fuser -k -9 9090/tcp || true
pkill -9 -f fps_publisher || true
sleep 1

echo "Starting rosbridge server..."
ros2 run rosbridge_server rosbridge_websocket &
ROSBRIDGE_PID=$!

echo "Starting web_video_server..."
ros2 run web_video_server web_video_server &
WEBVIDEO_PID=$!

echo "Starting server-side FPS calculator..."
# Adjust this path if your workspace is different
/home/hp/ros2_ws/src/gazebo_differential_drive_robot/scripts/fps_publisher.py &
FPS_PID=$!

echo "Opening SSH reverse tunnel to VPS..."
# REPLACE YOUR_VPS_IP, YOUR_USERNAME, and path to your key below:
ssh -N -R 9090:localhost:9090 -R 8080:localhost:8080 YOUR_USERNAME@YOUR_VPS_IP -i ~/.ssh/YOUR_KEY.pem -o StrictHostKeyChecking=no

# On script exit, kill the background servers
trap "kill $ROSBRIDGE_PID $WEBVIDEO_PID $FPS_PID" EXIT
wait
