cmake_minimum_required(VERSION 3.8)
project(puzzlebot_real_robot)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# find dependencies
find_package(ament_cmake REQUIRED)
# uncomment the following section in order to fill in
# further dependencies manually.
# find_package(<dependency> REQUIRED)

install(
  DIRECTORY launch config maps 
  DESTINATION share/puzzlebot_real_robot
)

install(
  PROGRAMS
    scripts/puzzlebot_localization.py
    scripts/puzzlebot_joint_state_publisher.py
  DESTINATION lib/${PROJECT_NAME}
)

ament_package()
