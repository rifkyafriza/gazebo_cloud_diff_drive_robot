# Differential Drive Robot Simulation

## About

This package provides a simple differential drive robot model designed for use in Gazebo Harmonic simulation with ROS 2 Jazzy Jalisco. 

## Requirements

To run this package, you'll need the following:

- [Linux Ubuntu 24.04](https://ubuntu.com/blog/tag/ubuntu-24-04-lts)
- [ROS2 Jazzy Jalisco](https://docs.ros.org/en/rolling/Releases/Release-Jazzy-Jalisco.html)
- [Gazebo Harmonic](https://gazebosim.org/docs/harmonic/getstarted/) 


#### Install Required ROS 2 Packages

Make sure to install the following ROS 2 Jazzy Jalisco packages:

```bash
sudo apt install -y                         \
    ros-jazzy-ros-gz                        \
    ros-jazzy-ros-gz-bridge                 \
    ros-jazzy-joint-state-publisher         \
    ros-jazzy-xacro                         \
    ros-jazzy-teleop-twist-keyboard         \
    ros-jazzy-teleop-twist-joy              \
    ros-jazzy-rosbridge-server              \
    ros-jazzy-web-video-server
```

## Usage

### Clone the Repository

Clone this repository into your ``workspace/src`` folder. If you don't have a workspace set up, you can learn more about creating one in the [ROS 2 workspace tutorial](https://docs.ros.org/en/jazzy/Tutorials/Beginner-Client-Libraries/Creating-A-Workspace/Creating-A-Workspace.html).


```bash
cd <path_to_your_workspace>/src
git clone git@github.com:lucasmazz/gazebo_differential_drive_robot.git
cd ..
```

### Build the Package

Source the ROS 2 environment and build the package:

```bash
source /opt/ros/jazzy/setup.bash
colcon build
```

### Launch the Robot

After building the package, launch the ```robot.launch.py``` file from the ```gazebo_differential_drive_robot``` package:

```bash
source install/setup.bash
ros2 launch gazebo_differential_drive_robot robot.launch.py
```

To launch the robot in a specified world with a custom initial pose, run the `robot.launch.py` file and specify the world path and robot pose arguments.


- **world**: Path to the world file 
- **x**: Initial x-coordinate of the robot
- **y**: Initial y-coordinate of the robot
- **z**: Initial z-coordinate of the robot
- **R**: Initial roll orientation
- **P**: Initial pitch orientation
- **Y**: Initial yaw orientation

In the following example, the robot starts at position (x, y, z) = (1.0, 2.0, 0.5) with a yaw of 1.57 radians in the specified world:

```bash
ros2 launch gazebo_differential_drive_robot robot.launch.py world:=/path_to_world/world.sdf x:=1.0 y:=2.0 z:=0.5 R:=0.0 P:=0.0 Y:=1.57
```

**Testing with Obstacles**: A custom world with colorful geometric obstacles is included for testing the camera and LiDAR sensors. You can launch it using:
```bash
ros2 launch gazebo_differential_drive_robot robot.launch.py world:=src/gazebo_differential_drive_robot/worlds/obstacles.sdf
```

### Control the Robot

#### Using a Joystick

In a new terminal, source the environment and launch the ```teleop-launch.py``` file from the ```teleop_twist_joy``` package. Adjust the joy_config parameter to match your joystick controller (e.g., xbox).

```bash
source /opt/ros/jazzy/setup.bash
ros2 launch teleop_twist_joy teleop-launch.py joy_config:='xbox'
```

#### Using a Keyboard

If you don't have a joystick, you can control the robot using the ```teleop_twist_keyboard``` package. Run the following command:

```bash
source /opt/ros/jazzy/setup.bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

### Local Development Tools
If you want to view the robot's camera feed directly on your local machine without setting up the remote dashboard or web servers, you can use the included viewer script:
```bash
./scripts/view_camera.py
```
This requires OpenCV (`python3-opencv`) and CV Bridge.

## Running with Docker

If you don't already have docker installed, you can install it
using the [docker installation instructions](https://docs.docker.com/engine/install/) for your operating system.
Be sure to follow the post-install instructions.

### Create and run the container

For Windows there is a handy `run.ps1` script for setting up the display service and running the container:
```powershell
cd docker
.\run.ps1
```

Otherwise, run docker compose (you might have to set the display output to see the UI, I only tested on Windows):
```bash
cd docker
docker compose up -d
```

### Launch Gazebo and see the robot

Enter the container:
```powershell
docker exec -it gz_diff_drive_robot bash
```

Launch ROS2:
```bash
ros2 launch gazebo_differential_drive_robot robot.launch.py
```

### Control the robot

Open another terminal and enter the container:
```powershell
docker exec -it gz_diff_drive_robot bash
```

Run the following command:
```bash
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

## Advanced: Remote Telemetry & VPS Dashboard Integration

This repository has been modified to support seamless remote telemetry and control over the public internet using a VPS (Virtual Private Server) reverse tunnel and a remote Web Dashboard.

### Key Additions
1. **Camera Sensor Noise**: The `robot.xacro` file has been updated to include Gaussian noise (stddev 0.005). This breaks the "perfect" rendering of the Gazebo simulator, allowing web-based visual framerate trackers to function properly even when the robot is entirely stationary.
2. **Server-Side FPS Tracking**: A custom `fps_publisher.py` script has been added to measure the true publishing rate of the `/camera/image_raw` topic directly from the ROS2 network.
3. **VPS Reverse Tunnel Script**: `connect_vps.example.sh` demonstrates how to cleanly start `rosbridge_websocket` (port 9090) and `web_video_server` (port 8080), while opening a reverse SSH tunnel to a public VPS.

### Deploying the VPS Connection
To connect the robot to your remote dashboard, copy the example script:
```bash
cp scripts/connect_vps.example.sh scripts/connect_vps.sh
chmod +x scripts/connect_vps.sh
```
Edit `scripts/connect_vps.sh` and replace `YOUR_VPS_IP` and `YOUR_KEY.pem` with your actual server credentials. Note that `scripts/connect_vps.sh` is safely ignored by `.gitignore` to keep your credentials private.

Run the script to establish the connection:
```bash
./scripts/connect_vps.sh
```
