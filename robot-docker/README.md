# BlueOS SGP-Tools
A BlueOS Extension for Autonomous Approximate Bathymetric Surveys

## What Does It Do?
Autonomous Surface Vehicles (ASVs), such as the [BlueRobotics BlueBoat](https://bluerobotics.com/store/boat/blueboat/blueboat/), are well-suited for bathymetric surveys. However, it is often the case that an exhaustive survey mapping the depth at every location in an area is infeasible or unnecessary. In such cases, we can leverage variations in the underwater terrain to determine a few critical locations for data collection, which would result in a good approximation of the area's bathymetry.

The [SGP-Tools python library](https://www.itskalvik.com/sgp-tools) provides path planners to address the above problem, known as the informative path planning problem. The BlueOS SGP-Tools extension uses this library to determine ideal locations for the ASV to collect data and controls the ASV to autonomously visit the selected locations.

The following shows the path planner adaptively planning paths for four robots tasked with surveying a given area:
<div style="text-align:left">
<p><a href="http://itskalvik.com/sgp-tools">
<img width="472" src="../.assets/AIPP-4R.gif">
</a></p>
</div>

## Usage
1. First, we need to define the survey area. The extension can read this data from [QGC plan files](https://docs.qgroundcontrol.com/Stable_V4.3/en/qgc-user-guide/plan_view/plan_geofence.html). The survey area must be defined using a polygon-shaped geofence drawn in QGC. The plan file also needs to include a robot launch position, which will be used as the first waypoint.

2. Once you have the plan file, ensure that it is named ```mission.plan``` and copy it to the Raspberry Pi's home directory, ```/home/pi/```. The file will then be available in the extension's Docker container.

3. Finally, use the terminal provided by the SGP-Tools extension in BlueOS to start the mission with the following commands:
    ```
    cd /home/ros2_ws/
    colcon build --symlink-install
    ros2 launch ros_sgp_tools single_robot.launch.py
    ```

    * Please refer to the file ```/home/ros2_ws/src/ros_sgp_tools/launch/single_robot.launch.py``` in the extension's Docker container to change the number of waypoints.

    * The extension also includes [Foxglove](https://foxglove.dev/product), a web-based data visualization platform similar to [RVIZ](https://docs.ros.org/en/humble/Tutorials/Intermediate/RViz/RViz-User-Guide/RViz-User-Guide.html). You can enable it from the launch file ```single_robot.launch.py``` and access it from the [web app](https://app.foxglove.dev/). Use the ```open connection``` feature and change the address from ```localhost``` to the ip address of the ASV. 

6. After the mission, you can extract the log file from the flight controller and plot it using [UAV Log Viewer](https://plot.ardupilot.org/#/).

## Hardware Configuration:
- This extension works only on 64-bit operating systems. You can install the latest version of [BlueOS](https://github.com/bluerobotics/BlueOS) on [64-bit Raspberry Pi OS Lite](https://www.raspberrypi.com/software/operating-systems/) by running the following command on the Pi (ensure the username is set to ```pi```):
    ```
    sudo su -c 'curl -fsSL https://raw.githubusercontent.com/bluerobotics/blueos-docker/master/install/install.sh | bash'
    ```

- Currently, only the [BlueRobotics Ping Sonar](https://bluerobotics.com/store/sonars/echosounders/ping-sonar-r2-rp/) sensor data is supported.

- The [BlueRobotics Ping Sonar](https://bluerobotics.com/store/sonars/echosounders/ping-sonar-r2-rp/) must be directly connected to the flight controller. Please refer to the instruction [here](https://ardupilot.org/copter/docs/common-bluerobotics-ping.html).

- The extension requires over 4GB of memory/swap. Please ensure that the swap size is large enough to accommodate the extension. The extension will copy a shell script (```config_swap.sh```) to the ```/home/pi/``` folder on the Raspberry Pi. You can use this script to increase the swap size before starting the path planner.

## Disclaimer ⚠️
This extension, when executed properly, will take control of the ASV and could potentially collide the vehicle with obstacles in the environment. Please use it with caution.