ARG ROS_DISTRO=humble
FROM  osrf/ros:$ROS_DISTRO-desktop

ENV DEBIAN_FRONTEND=noninteractive

# Configure a new non-root user
ARG USERNAME=admin
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -a -G dialout $USERNAME

# Switch to the non-root user for the rest of the installation
USER $USERNAME
ENV USER=$USERNAME
WORKDIR /home/$USERNAME

# Install apt general packages
RUN sudo apt-get -q update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get -q install --no-install-recommends -y \
    git \
    sudo \
    python3-pip \
    python3-dev \
    lsb-release \
    wget \
    gnupg \
    nano \
    software-properties-common \
    libhdf5-dev \
    libgeographic-dev \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir -U pip setuptools==70.0.0 packaging==22.0

# Install Gazebo Garden: https://gazebosim.org/docs/garden/install_ubuntu
ARG GZ_VERSION=garden
ENV GZ_VERSION=$GZ_VERSION
RUN sudo wget https://packages.osrfoundation.org/gazebo.gpg -O /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null \
    && sudo apt-get -q update \
    && sudo apt-get -y --quiet --no-install-recommends install \
    gz-$GZ_VERSION \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# Install MAVROS and ArduPilot dependencies 
RUN sudo apt-get -q update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get -q install --no-install-recommends -y \
    ros-$ROS_DISTRO-mavros-* \
    python3-dev \
    python3-opencv \
    python3-wxgtk4.0 \
    python3-matplotlib \
    python3-lxml \
    python3-pygame \
    rapidjson-dev \
    libopencv-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-libav \
    gstreamer1.0-gl \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && wget https://raw.githubusercontent.com/mavlink/mavros/ros2/mavros/scripts/install_geographiclib_datasets.sh \
    && chmod +x install_geographiclib_datasets.sh \
    && sudo bash ./install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# Setup ArduPilot SITL
ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1
RUN git clone https://github.com/ArduPilot/ardupilot.git --recurse-submodules --depth 1 -b Rover-4.5 \
    && cd /home/$USERNAME/ardupilot \
    && Tools/environment_install/install-prereqs-ubuntu.sh -y \
    && cd /home/$USERNAME/ardupilot \
    && modules/waf/waf-light configure --board sitl \
    && modules/waf/waf-light build --target bin/ardurover

# Setup ardupilot_gazebo plugin
RUN cd /home/$USERNAME/ \
    && git clone https://github.com/ArduPilot/ardupilot_gazebo.git --depth 1 \
    && cd ardupilot_gazebo \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j4

# Install NVIDIA software
RUN sudo apt-get update \
    && sudo apt-get -q -y upgrade \
    && sudo apt-get install -y -qq --no-install-recommends \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libxext6 \
    libx11-6 \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# Env vars for the nvidia-container-runtime.
ENV NVIDIA_VISIBLE_DEVICES=all NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute QT_X11_NO_MITSHM=1

# Build Wave Sim
RUN sudo apt-get -q update \
    && sudo apt-get install -y -qq --no-install-recommends libcgal-dev libfftw3-dev \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && mkdir -p /home/$USERNAME/gz_ws/src \
    && cd /home/$USERNAME/gz_ws/src \
    && git clone https://github.com/srmainwaring/asv_wave_sim.git --depth 1 \
    && git clone https://github.com/gazebosim/ros_gz.git -b $ROS_DISTRO --depth 1 \
    && cd /home/$USERNAME/gz_ws/ \
    && rosdep update \
    && sudo rosdep install -r --from-paths src/ros_gz -i -y --rosdistro $ROS_DISTRO \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install --merge-install --cmake-args \
                    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
                    -DBUILD_TESTING=ON \
                    -DCMAKE_CXX_STANDARD=17 \
    && echo "source /home/${USERNAME}/gz_ws/install/setup.sh " >> /home/$USERNAME/.bashrc \
    && cd /home/$USERNAME/gz_ws/src/asv_wave_sim/gz-waves/src/gui/plugins/waves_control \
    && mkdir build && cd build && cmake .. && make
    
# Build ROS2 workspace with sgptools
ENV DATA_FOLDER=/home/$USERNAME/ros2_ws/src/ros_sgp_tools/launch/data/
COPY --chown=$USER_UID:$USER_GID ros2_ws /home/$USERNAME/ros2_ws
RUN cd /home/$USERNAME/ros2_ws/src \
    && python3 -m pip install --no-cache-dir -U pip setuptools==70.0.0 packaging==22.0 \
    && python3 -m pip install --no-cache-dir -r mavros_control/requirements.txt \
    && python3 -m pip install --no-cache-dir -r ros_sgp_tools/requirements.txt \
    && cd /home/$USERNAME/ros2_ws \
    && sudo apt-get -q update \
    && sudo rosdep install -r --from-paths src -i -y --rosdistro $ROS_DISTRO \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && echo "source /ros_entrypoint_sitl.sh" >> /home/$USERNAME/.bashrc \
    && echo "source /home/${USERNAME}/ros2_ws/install/setup.sh " >> /home/$USERNAME/.bashrc

COPY sim-docker/ros_entrypoint_sitl.sh /ros_entrypoint_sitl.sh
RUN ln -s "/home/${USERNAME}/ros2_ws/src/ros_sgp_tools/launch/data/config.yaml" "/home/${USERNAME}/config.yaml"
ENV RCUTILS_COLORIZED_OUTPUT=1

# Keep bash alive even if there is an error
RUN echo "set +e" >> ~/.bashrc
ENTRYPOINT ["/ros_entrypoint_sitl.sh"]
CMD ["sleep", "infinity"]