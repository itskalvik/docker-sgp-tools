# docker-sgp-tools
* A Docker container for ROS2, Gazebo, and Ardupilot SITL 
* GUI is enabled if WSLg is installed


## Prerequisites

* docker, docker-compose
* (Optional) WSLg


## Getting started

```bash
git clone https://github.com/itskalvik/docker-sgp-tools.git
cd docker-sgp-tools
docker-compose build
docker-compose up -d
docker-compose exec sitl bash
```

## Other commands

### docker-compose

```bash
docker-compose stop
```

```bash
docker-compose down
```

```bash
docker-compose exec --user root sitl bash
```
