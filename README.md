# docker-sgp-tools
This repo provides the following docker-compose scripts:
- ```robot-compose.yml```: A minimal docker container used to run SGP-Tools ROS2 package on robots.
- ```sitl-compose.yml```: A GUI-based docker container with ROS2, Gazebo, ArduPilot SITL, and SGP-Tools used for simulating ArduPilot vehicles and testing SGP-Tools IPP code. 

## Prerequisites

* [docker](https://docs.docker.com/engine/install/)
* [docker-compose](https://docs.docker.com/compose/install/)
* (Optional) [WSLg](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps)


### Starting the containers

Run the following to start a docker container:

```bash
git clone https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker-compose -f sitl-compose.yml pull
docker-compose -f sitl-compose.yml up -d
docker-compose -f sitl-compose.yml exec sgptools bash
```

### Build

### Building the SITL docker image

```bash
git clone https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker-compose -f sitl-compose.yml build --pull
docker-compose -f sitl-compose.yml up -d
docker-compose -f sitl-compose.yml exec sgptools bash
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
### Building the robot docker image

```bash
docker buildx create --name multi-arch \
  --platform "linux/arm64,linux/amd64" \
  --driver "docker-container"
docker buildx use multi-arch
git clone https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker-compose -f robot-compose.yml build --pull
docker-compose -f robot-compose.yml up -d
docker-compose -f robot-compose.yml exec sgptools bash
```

## Other commands

```bash
docker-compose -f sitl-compose.yml stop
```

```bash
docker-compose -f sitl-compose.yml down
```

```bash
docker-compose -f sitl-compose.yml exec --user root sgptools bash
```


