#!/usr/bin/env bash

# Remote bringup helper for physical Puzzlebot hardware.
# Execute this script on your local machine to connect to the Jetson and start
# the hardware bringup on the remote robot.
#
# This script connects to the Jetson at 10.42.0.1 and launches the hardware drivers.
# It supports both SSH key-based and password-based authentication.
#
# Usage:
#   ./start_real_robot_hardware.sh [SSH_KEY_PATH]
#
# Examples:
#   ./start_real_robot_hardware.sh              (uses key-based auth)
#   ./start_real_robot_hardware.sh /path/to/key (uses specific key)
#   ./start_real_robot_hardware.sh -p           (uses password-based auth)

REMOTE_USER="puzzlebot"
REMOTE_HOST="10.42.0.1"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"

# Check if password authentication mode is requested
if [[ "$1" == "-p" ]] || [[ "$1" == "--password" ]]; then
  echo "Connecting to ${REMOTE} using password authentication..."
  ssh ${REMOTE} <<'EOF'
source /opt/ros/humble/setup.bash
printf '\n=== Starting micro-ROS agent ===\n'
ros2 launch puzzlebot_ros micro_ros_agent.launch.py serial_port:=/dev/ttyUSB1 &
printf '\n=== Starting RPLidar driver ===\n'
ros2 launch rplidar_ros rplidar_a1_launch.py serial_port:=/dev/ttyUSB0 &
wait
EOF
  exit $?
fi

# Use provided SSH key path or default to ~/.ssh/Puzzlebot72
if [[ -n "$1" ]]; then
  SSH_KEY_PATH="$1"
else
  SSH_KEY_PATH="${HOME}/.ssh/Puzzlebot72"
fi

# If the default key path doesn't exist, suggest password auth
if [[ ! -f "${SSH_KEY_PATH}" ]]; then
  echo "SSH key not found at ${SSH_KEY_PATH}."
  echo ""
  echo "You have two options:"
  echo ""
  echo "1. Place the SSH key at ~/.ssh/Puzzlebot72"
  echo "   Then run: ./start_real_robot_hardware.sh"
  echo ""
  echo "2. Use password-based authentication:"
  echo "   ./start_real_robot_hardware.sh -p"
  echo ""
  echo "3. Specify a custom key path:"
  echo "   ./start_real_robot_hardware.sh /path/to/Puzzlebot72"
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
