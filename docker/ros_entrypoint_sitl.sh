#!/usr/bin/env bash

# Add ardupilot_gazebo plugin
export GZ_SIM_SYSTEM_PLUGIN_PATH=$GZ_SIM_SYSTEM_PLUGIN_PATH:\
$HOME/ardupilot_gazebo/build

# Add ardupilot_gazebo models and worlds
export GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH:\
$HOME/ardupilot_gazebo/models:\
$HOME/ardupilot_gazebo/worlds:\
$HOME/SITL_Models/Gazebo/models:\
$HOME/SITL_Models/Gazebo/worlds

# Add Mavproxy path
export PATH=$PATH:$HOME/.local/bin

# Source ROS2
source /ros_entrypoint.sh