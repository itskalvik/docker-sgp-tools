<div style="text-align:left">
<p><a href="http://itskalvik.com/sgp-tools">
<img width="472" src=".assets/SGP-Tools.png">
</a></p>
</div>

# docker-sgp-tools
The [docker-sgp-tools](https://github.com/itskalvik/docker-sgp-tools) package provides the following docker compose scripts:

* ```robot-compose.yml```: A minimal docker container used to run [SGP-Tools](http://itskalvik.com/sgp-tools) [ROS2 package](https://github.com/itskalvik/ros_sgp_tools) on ArduPilot-based robots and as an extension on [BlueOS](https://www.itskalvik.com/sgp-tools/blueos.html).
* ```sim-compose.yml```: A GUI-based docker container with ROS2, Gazebo, ArduPilot SITL, and [SGP-Tools](http://itskalvik.com/sgp-tools) used for simulating ArduPilot vehicles and testing SGP-Tools IPP code. 

![Image title](.assets/docker_ros2_ardupilot.png)

### Prerequisites

* [docker](https://docs.docker.com/engine/install/)
* [docker compose](https://docs.docker.com/compose/install/)
* [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)

## Getting Started 
### Starting the Containers

Run the following commands to start the SITL docker container:

```bash
git clone --recurse-submodules https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker compose -f sim-compose.yml pull
docker compose -f sim-compose.yml up -d
docker compose -f sim-compose.yml exec sgptools bash
```

Use ```robot-compose.yml``` to run the minimal docker container. 

### Running SGP-Tools Online/Adaptive IPP with Gazebo/ArduRover Simulator

![Image title](.assets/demo.png)

Note: The Gazebo-based simulator requires an Nvidia GPU for reliable performance.  

Use ```docker compose -f sim-compose.yml exec sgptools bash``` to get a new terminal. Run the following commands in separate terminals in the docker container:

- Launch Gazebo with the [Blue Robotics BlueBoat ASV](https://bluerobotics.com/store/boat/blueboat/blueboat/):
    ```
    gz sim -v4 -r blueboat_waves.sdf
    ```

- Launch [ArduPilot SITL](https://ardupilot.org/dev/docs/sitl-simulator-software-in-the-loop.html):
    ```
    sim_vehicle.py -v Rover -f rover-skid --model JSON --console --map -N -L RATBeach
    ```
    Note: 
    - Ensure the MAV Console shows `AHRS` and `GPS` in green before running the next command
    - Ensure the MAV Map shows the vehicle before running the next command
    - Restart sim_vechile.py if you get the following message: ```paramftp: bad count```

- Launch the [SGP-Tools](http://itskalvik.com/sgp-tools) Online/Adaptive IPP method:
    ```
    ros2 launch ros_sgp_tools asv.launch.py
    ```

## Building the Docker Containers from Scratch

First, setup buildx to build the containers for both arm64 and amd64 platforms: 
```bash
docker buildx create --name multi-arch \
  --platform "linux/arm64,linux/amd64" \
  --driver "docker-container"
docker buildx use multi-arch
```

Next, clone the repo and build the container. 
```bash
git clone --recurse-submodules https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker compose -f sim-compose.yml build 
```

Use ```robot-compose.yml``` to build the minimal docker container.

## Other commands

- The docker compose down command stops and removes containers, networks, volumes, and images, making it suitable for completely clearing all resources deployed by an application.

    ```bash
    docker compose -f sim-compose.yml down
    ```

- The docker compose stop command just pauses running containers without removing them, which is ideal for temporary halts.

    ```bash
    docker compose -f sim-compose.yml stop
    ```

## References
Based on Dockerfiles from the following repos:

- https://github.com/Robotic-Decision-Making-Lab/blue
- https://github.com/ryomo/ros2-gazebo-docker
