# docker-sgp-tools
* A Docker container for ROS2, Gazebo, Ardupilot SITL, and SGP-Tools  package
* GUI is enabled if WSLg is installed


## Prerequisites

* docker, docker-compose
* (Optional) WSLg


## Getting started

```bash
git clone https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker-compose -f sitl-compose.yml build
docker-compose -f sitl-compose.yml up -d
docker-compose -f sitl-compose.yml exec sitl bash
```
### Running SGP-Tools Online IPP with Gazebo/ArduRover Simulator
Run the following commands in separate terminals in the docker image. 

- Launch Gazebo with the AION R1 UGV:
    ```
    gz sim -v4 -r r1_rover_runway.sdf
    ```

- Launch ArduRover SITL:
    ```
    sim_vehicle.py -v Rover -f rover-skid --model JSON --add-param-file=$HOME/SITL_Models/Gazebo/config/r1_rover.param --console --map -N -l 35.30409925924026,-80.73133789586592,0.,0.
    ```

- Launch SGP-Tools Online IPP method:
    ```
    ros2 launch ros_sgp_tools single_robot.launch.py
    ```

## Other commands

### docker-compose

```bash
docker-compose -f sitl-compose.yml stop
```

```bash
docker-compose -f sitl-compose.yml down
```

```bash
docker-compose -f sitl-compose.yml exec --user root sitl bash
```
