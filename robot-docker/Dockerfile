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
ENV DATA_FOLDER=/home/ros2_ws/src/ros_sgp_tools/launch/data/
COPY ros2_ws /home/ros2_ws
RUN cd /home/ros2_ws/ \
    && python3 -m pip install --no-cache-dir -r src/ros_sgp_tools/requirements.txt \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && ros2 run mavros install_geographiclib_datasets.sh \
    && echo "source /ros_entrypoint.sh" >> ~/.bashrc \
    && echo "source /home/ros2_ws/install/setup.sh " >> ~/.bashrc

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
      "/home/pi/:/home/ros2_ws/src/ros_sgp_tools/launch/data/:rw"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host"\
  }\
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