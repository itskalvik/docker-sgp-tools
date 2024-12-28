ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO-ros-base
WORKDIR /home/

# Install dependent packages with apt-get and pip
RUN rm /var/lib/dpkg/info/libc-bin.* \
    && apt-get clean \
    && apt-get update \
    && apt-get -y install libc-bin \
    && apt-get install -q -y --no-install-recommends \
    tmux nano nginx wget git \
    python3-pip python3-dev \
    libhdf5-dev \
    libgeographic-dev \
    ros-$ROS_DISTRO-foxglove-bridge \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-mavros* \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir -U pip setuptools==70.0.0

# Build ROS2 workspace with sgptools
COPY ros2_ws /home/ros2_ws
RUN cd /home/ros2_ws/ \
    && python3 -m pip install --no-cache-dir -r src/ros_sgp_tools/requirements.txt \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && ros2 run mavros install_geographiclib_datasets.sh \
    && echo "source /ros_entrypoint.sh" >> ~/.bashrc \
    && echo "source /home/ros2_ws/install/setup.sh " >> ~/.bashrc

# Build ROS2 workspace with the ping sonar package
RUN mkdir -p /home/ping_ws/src/ \
    && cd /home/ping_ws/src/ \
    && git clone https://github.com/itskalvik/ping_sonar_ros.git --recursive --depth 1 \
    && cd /home/ping_ws/src/ping_sonar_ros/ping_sonar_ros/ping-python && python3 setup.py install --user \
    && cd /home/ping_ws/ \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && echo "source /home/ping_ws/install/setup.sh " >> ~/.bashrc

# Setup environment variables to configure ros_sgp_tools
ENV DATA_FOLDER=/home/ros2_ws/src/ros_sgp_tools/launch/data/ \
    PING2_PORT=/dev/ttyUSB0 \
    NAMESPACE=robot_0 \
    DATA_TYPE=Ping2 \
    NUM_WAYPOINTS=20 \
    SAMPLING_RATE=2 \
    START_FOXGLOVE=False \
    ADAPTIVE_IPP=True \
    FAKE_DATA=False

# Setup ttyd for blueos web terminal interface
ADD files/install-ttyd.sh /install-ttyd.sh
RUN bash /install-ttyd.sh && rm /install-ttyd.sh
COPY files/tmux.conf /etc/tmux.conf

RUN mkdir -p /site
COPY files/register_service /site/register_service
COPY files/nginx.conf /etc/nginx/nginx.conf

ADD files/start.sh /start.sh
ADD files/config_swap.sh /config_swap.sh

# Add docker configuration
LABEL version="0.0.1"
LABEL permissions='{\
  "NetworkMode": "host",\
  "HostConfig": {\
    "Binds": [\
      "/dev:/dev:rw",\
      "/usr/blueos/extensions/sgptools/:/home/ros2_ws/src/ros_sgp_tools/launch/data/:rw"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host"\
  },\
  "Env": [\
    "PING2_PORT=/dev/ttyUSB0", \
    "NUM_WAYPOINTS=20", \
    "SAMPLING_RATE=2", \
    "START_FOXGLOVE=False", \
    "ADAPTIVE_IPP=True", \
    "NAMESPACE=robot_0", \
    "DATA_TYPE=Ping2", \
    "FAKE_DATA=False"
  ]\
}'
LABEL authors='[\
  {\
    "name": "Kalvik Jakkala",\
    "email": "itskalvik@gmail.com"\
  }\
]'
LABEL company='{\
  "about": "",\
  "name": "ItsKalvik",\
  "email": "itskalvik@gmail.com"\
}'
LABEL readme="https://raw.githubusercontent.com/itskalvik/docker-sgp-tools/refs/heads/main/robot-docker/README.md"
LABEL type="other"
LABEL tags='[\
  "ros2",\
  "robot",\
  "Informative Path Planning"\
]'

# Keep bash alive even if there is an error
RUN echo "set +e" >> ~/.bashrc
ENTRYPOINT [ "/start.sh" ]