ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO-ros-base

WORKDIR /home/

# Install dependent packages with apt-get and pip
RUN rm /var/lib/dpkg/info/libc-bin.* \
    && apt-get clean \
    && apt-get update \
    && apt-get -y install libc-bin \
    && apt-get -y install \
    libhdf5-dev \
    git \
    nano \
    python3-pip \
    python3-dev \
    python3-lxml \
    python3-pygame \
    python3-opencv \
    python3-wxgtk4.0 \
    python3-matplotlib \
    libgeographic-dev \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-mavros* \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir setuptools==58.2.0 PyYAML mavproxy

# Build ROS2 workspace with sgptools
COPY ros2_ws /home/ros2_ws
RUN cd /home/ros2_ws/ \
    && python3 -m pip install --no-cache-dir -r src/ros_sgp_tools/requirements.txt \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && ros2 run mavros install_geographiclib_datasets.sh \
    && echo "source /ros_entrypoint.sh" >> ~/.bashrc \
    && echo "source /home/ros2_ws/install/setup.sh " >> ~/.bashrc

CMD ["sleep", "infinity"]