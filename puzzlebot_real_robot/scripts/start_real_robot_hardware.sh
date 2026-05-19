#!/usr/bin/env bash

# Remote bringup helper for physical Puzzlebot hardware.
# Execute this script on your local machine to connect to the Jetson and start
# the hardware bringup on the remote robot.

REMOTE_USER="puzzlebot"
REMOTE_HOST="10.42.0.1"
SSH_KEY_PATH="${HOME}/.ssh/Puzzlebot72"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"

if [[ ! -f "${SSH_KEY_PATH}" ]]; then
  echo "ERROR: SSH key not found at ${SSH_KEY_PATH}."
  echo "Please place your Puzzlebot72 private key file there or update SSH_KEY_PATH in this script."
  exit 1
fi

echo "Connecting to ${REMOTE} using SSH key ${SSH_KEY_PATH}..."
ssh -i "${SSH_KEY_PATH}" ${REMOTE} <<'EOF'
source /opt/ros/humble/setup.bash
printf '\n=== Starting micro-ROS agent ===\n'
ros2 launch puzzlebot_ros micro_ros_agent.launch.py serial_port:=/dev/ttyUSB1 &
printf '\n=== Starting RPLidar driver ===\n'
ros2 launch rplidar_ros rplidar_a1_launch.py serial_port:=/dev/ttyUSB0 &
wait
EOF
