#!/usr/bin/env bash

# Remote bringup helper for physical Puzzlebot hardware.
# Run this script from the laptop. It connects to the Jetson and starts:
#   1. micro-ROS agent
#   2. RPLiDAR driver
#
# Usage:
#   ./scripts/start_real_robot_hardware.sh
#   ./scripts/start_real_robot_hardware.sh -p
#   ./scripts/start_real_robot_hardware.sh /path/to/ssh_key

REMOTE_USER="puzzlebot"
REMOTE_HOST="10.42.0.1"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"

DEFAULT_SSH_KEY="${HOME}/.ssh/Puzzlebot72"

ROS_DISTRO_SETUP="/opt/ros/humble/setup.bash"
JETSON_WS_SETUP="/home/puzzlebot/ros2_ws/install/setup.bash"
JETSON_EXTRA_WS_SETUP="/home/puzzlebot/ros2_packages_ws/install/setup.bash"

ROS_DOMAIN_ID_VALUE="${ROS_DOMAIN_ID:-0}"

MICRO_ROS_PORT="/dev/ttyUSB1"
RPLIDAR_PORT="/dev/ttyUSB0"

cleanup_remote() {
  echo ""
  echo "=== Stopping remote hardware processes ==="
  ${SSH_BASE_CMD} "${REMOTE}" "
    pkill -f 'micro_ros_agent.launch.py' || true
    pkill -f 'MicroXRCEAgent' || true
    pkill -f 'rplidar_a1_launch.py' || true
    pkill -f 'rplidarNode' || true
  " 2>/dev/null || true
}

run_remote_bringup() {
  echo "Connecting to ${REMOTE}..."
  echo "Using Jetson workspace: ${JETSON_WS_SETUP}"
  echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID_VALUE}"
  echo ""

  ${SSH_BASE_CMD} "${REMOTE}" "
    set -e

    source ${ROS_DISTRO_SETUP}

    if [ -f ${JETSON_EXTRA_WS_SETUP} ]; then
      source ${JETSON_EXTRA_WS_SETUP}
    fi

    if [ -f ${JETSON_WS_SETUP} ]; then
      source ${JETSON_WS_SETUP}
    else
      echo 'ERROR: Jetson workspace setup file not found: ${JETSON_WS_SETUP}'
      echo 'Available setup files:'
      find /home/puzzlebot -path '*/install/setup.bash' -print
      exit 1
    fi

    export ROS_DOMAIN_ID=${ROS_DOMAIN_ID_VALUE}
    unset ROS_LOCALHOST_ONLY

    echo '=== Checking required packages ==='
    ros2 pkg prefix puzzlebot_ros
    ros2 pkg prefix rplidar_ros

    echo ''
    echo '=== Killing previous hardware processes, if any ==='
    pkill -f 'micro_ros_agent.launch.py' || true
    pkill -f 'MicroXRCEAgent' || true
    pkill -f 'rplidar_a1_launch.py' || true
    pkill -f 'rplidarNode' || true

    sleep 1

    echo ''
    echo '=== Starting micro-ROS agent ==='
    ros2 launch puzzlebot_ros micro_ros_agent.launch.py serial_port:=${MICRO_ROS_PORT} &
    MICRO_ROS_PID=\$!

    sleep 2

    echo ''
    echo '=== Starting RPLiDAR driver ==='
    ros2 launch rplidar_ros rplidar_a1_launch.py serial_port:=${RPLIDAR_PORT} &
    RPLIDAR_PID=\$!

    echo ''
    echo '=== Remote hardware bringup is running ==='
    echo 'micro-ROS PID:' \$MICRO_ROS_PID
    echo 'RPLiDAR PID:' \$RPLIDAR_PID
    echo 'Press Ctrl+C on the laptop terminal to stop both remote processes.'

    wait \$MICRO_ROS_PID \$RPLIDAR_PID
  "
}

if [[ "${1:-}" == "-p" ]] || [[ "${1:-}" == "--password" ]]; then
  SSH_BASE_CMD="ssh"
  trap cleanup_remote INT TERM EXIT
  run_remote_bringup
  exit $?
fi

if [[ -n "${1:-}" ]]; then
  SSH_KEY_PATH="$1"
else
  SSH_KEY_PATH="${DEFAULT_SSH_KEY}"
fi

if [[ ! -f "${SSH_KEY_PATH}" ]]; then
  echo "SSH key not found at ${SSH_KEY_PATH}."
  echo ""
  echo "Options:"
  echo ""
  echo "1. Create/copy the SSH key at:"
  echo "   ${DEFAULT_SSH_KEY}"
  echo ""
  echo "2. Use password-based authentication:"
  echo "   ./scripts/start_real_robot_hardware.sh -p"
  echo ""
  echo "3. Specify a custom key path:"
  echo "   ./scripts/start_real_robot_hardware.sh /path/to/key"
  exit 1
fi

SSH_BASE_CMD="ssh -i ${SSH_KEY_PATH}"
trap cleanup_remote INT TERM EXIT
run_remote_bringup