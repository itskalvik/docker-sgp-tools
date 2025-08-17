ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO-ros-base
WORKDIR /root/

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
    build-essential \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir -U pip setuptools==70.0.0

# Build ROS2 workspace with sgptools
COPY ros2_ws /root/ros2_ws
RUN cd /root/ros2_ws/ \
    && python3 -m pip install --no-cache-dir -r src/mavros_control/requirements.txt \
    && python3 -m pip install --no-cache-dir -r src/ros_sgp_tools/requirements.txt \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && apt-get update \
    && rosdep install --from-paths src --ignore-src -y --rosdistro $ROS_DISTRO \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && colcon build --symlink-install --cmake-args -DCMAKE_VERBOSE_MAKEFILE=ON \
    && ros2 run mavros install_geographiclib_datasets.sh \
    && echo "source /ros_entrypoint.sh" >> ~/.bashrc \
    && echo "source /root/ros2_ws/install/setup.sh " >> ~/.bashrc \
    && echo "PYTHONWARNINGS='ignore'; export PYTHONWARNINGS" >> ~/.bashrc

# Install ping-python from source (Newer commits don't seem to work with the ping1d)
RUN cd /root/ \
    && git clone https://github.com/bluerobotics/ping-python.git -b deployment \
    && cd ping-python \
    && git checkout 3d41ddd \
    && python3 setup.py install --user

# Build ROS2 workspace with the ping sonar package
RUN mkdir -p /root/ping_ws/src/ \
    && cd /root/ping_ws/ \
    && git clone https://github.com/itskalvik/bluerobotics_sonar.git --depth 1 /root/ping_ws/src \
    && apt-get update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && echo "source /root/ping_ws/install/setup.sh " >> ~/.bashrc

# Setup environment variables to configure ros_sgp_tools
ENV DATA_FOLDER=/root/ros2_ws/src/ros_sgp_tools/launch/data/ \
    FCU_URL=/dev/ttyACM0:57600 \
    ROS_LOG_DIR=/root/ros2_ws/src/ros_sgp_tools/launch/data/logs/ \
    RCUTILS_COLORIZED_OUTPUT=1

# Setup ttyd for web terminal interface
ADD files/install-ttyd.sh /install-ttyd.sh
RUN bash /install-ttyd.sh && rm /install-ttyd.sh

# Copy configuration files
COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/index.html /usr/share/ttyd/index.html

# Copy start script and other files
RUN mkdir -p /site
COPY files/register_service /site/register_service
COPY files/start.sh /start.sh

# Copy robot configuration files
COPY robot-docker/config.yaml /root/ros2_ws/src/ros_sgp_tools/launch/data/config.yaml

# Add docker configuration
LABEL version="0.0.2"
LABEL permissions='{\
  "NetworkMode": "host",\
  "HostConfig": {\
    "Binds": [\
      "/dev:/dev:rw",\
      "/usr/blueos/extensions/sgptools/:/root/ros2_ws/src/ros_sgp_tools/launch/data/:rw"\
    ],\
    "Privileged": true,\
    "NetworkMode": "host",\
    "CpuQuota": 200000,\
    "CpuPeriod": 100000,\
  },\
  "Env": [\
    "DATA_FOLDER=/root/ros2_ws/src/ros_sgp_tools/launch/data/", \
    "FCU_URL=tcp://0.0.0.0:5777@", \
    "ROS_LOG_DIR=/root/ros2_ws/src/ros_sgp_tools/launch/data/logs/", \
    "RCUTILS_COLORIZED_OUTPUT=1" \
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
  "sonar",\
  "camera",\
  "foxglove",\
  "navigation",\
  "mapping",\
  "data-collection",\
  "communication",\
  "interaction",\
  "positioning"\
]'

RUN ln -s "/root/ros2_ws/src/ros_sgp_tools/launch/data/config.yaml" "/root/config.yaml"

# Keep bash alive even if there is an error
RUN echo "set +e" >> ~/.bashrc
ENTRYPOINT [ "/start.sh" ]