#!/usr/bin/env bash

# Add ardupilot_gazebo plugin
export GZ_SIM_SYSTEM_PLUGIN_PATH=$GZ_SIM_SYSTEM_PLUGIN_PATH:\
$HOME/ardupilot_gazebo/build

# Add ardupilot_gazebo models and worlds
export GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH:\
$HOME/ardupilot_gazebo/models:\
$HOME/ardupilot_gazebo/worlds:\
$HOME/SITL_Models/Gazebo/models:\
$HOME/SITL_Models/Gazebo/worlds:\
$HOME/gz_ws/src/asv_wave_sim/gz-waves-models/models:\
$HOME/gz_ws/src/asv_wave_sim/gz-waves-models/world_models:\
$HOME/gz_ws/src/asv_wave_sim/gz-waves-models/worlds:\
$HOME/ros2_ws/src/ros_sgp_tools/models:\
$HOME/ros2_ws/src/ros_sgp_tools/worlds

# ensure the system plugins are found
export GZ_SIM_SYSTEM_PLUGIN_PATH=$GZ_SIM_SYSTEM_PLUGIN_PATH:\
$HOME/gz_ws/install/lib

# ensure the gui plugin is found
export GZ_GUI_PLUGIN_PATH=$GZ_GUI_PLUGIN_PATH:\
$HOME/gz_ws/src/asv_wave_sim/gz-waves/src/gui/plugins/waves_control/build

# Add Mavproxy and sim_vehicle.py paths
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/ardupilot/Tools/autotest
export PATH=/usr/lib/ccache:$PATH

# Source ROS2
source /ros_entrypoint.sh