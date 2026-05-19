#!/usr/bin/env bash

# Remote bringup helper for physical Puzzlebot hardware.
# Execute this script on your local machine to connect to the Jetson and start
# the hardware bringup on the remote robot.
#
# This is the preferred method when your PC does not have the Jetson hardware
# packages installed locally. It connects to the Jetson at 10.42.0.1 using the
# Puzzlebot72 SSH key.
#
# Usage:
#   ./start_real_robot_hardware.sh [SSH_KEY_PATH]
#
# Examples:
#   ./start_real_robot_hardware.sh
#   ./start_real_robot_hardware.sh /path/to/Puzzlebot72
#   ./start_real_robot_hardware.sh ~/.ssh/id_rsa

REMOTE_USER="puzzlebot"
REMOTE_HOST="10.42.0.1"

# Use provided SSH key path or default to ~/.ssh/Puzzlebot72
if [[ -n "$1" ]]; then
  SSH_KEY_PATH="$1"
else
  SSH_KEY_PATH="${HOME}/.ssh/Puzzlebot72"
fi

REMOTE="${REMOTE_USER}@${REMOTE_HOST}"

if [[ ! -f "${SSH_KEY_PATH}" ]]; then
  echo "ERROR: SSH key not found at ${SSH_KEY_PATH}."
  echo ""
  echo "Please provide the path to your Puzzlebot72 SSH private key."
  echo ""
  echo "Usage:"
  echo "  ./start_real_robot_hardware.sh /path/to/Puzzlebot72"
  echo ""
  echo "Or place the key at ~/.ssh/Puzzlebot72 and run:"
  echo "  ./start_real_robot_hardware.sh"
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
