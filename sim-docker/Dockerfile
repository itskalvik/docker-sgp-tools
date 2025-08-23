ARG ROS_DISTRO=jazzy
FROM  osrf/ros:$ROS_DISTRO-desktop
ENV DEBIAN_FRONTEND=noninteractive

# Configure a new non-root user
# Update username in docker-compose as well
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create group and user (idempotent)
RUN groupadd -g "$GID" "$USERNAME" || true \
 && useradd -m -u "$UID" -g "$GID" -s /bin/bash "$USERNAME" || true \
 && usermod -aG sudo "$USERNAME"

# Enable passwordless sudo for the sudo group
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/99-nopasswd \
 && chmod 0440 /etc/sudoers.d/99-nopasswd

# Switch to the non-root user for the rest of the installation
USER $USERNAME
ENV USER=$USERNAME
WORKDIR /home/$USERNAME

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
    neovim \
    software-properties-common \
    libhdf5-dev \
    libgeographiclib-dev \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/*

# Install Gazebo: https://gazebosim.org/docs/harmonic/install_ubuntu
ARG GZ_VERSION=harmonic
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
    && sudo bash ./install_geographiclib_datasets.sh \
    && rm install_geographiclib_datasets.sh

# Setup ArduPilot SITL
ENV SKIP_AP_EXT_ENV=1 SKIP_AP_GRAPHIC_ENV=1 SKIP_AP_COV_ENV=1 SKIP_AP_GIT_CHECK=1
RUN git clone https://github.com/ArduPilot/ardupilot.git --recurse-submodules --depth 1 \
    && cd /home/$USERNAME/ardupilot \
    && Tools/environment_install/install-prereqs-ubuntu.sh -y \
    && modules/waf/waf-light configure --board sitl \
    && modules/waf/waf-light build --target bin/ardurover \
    && echo "source /home/${USERNAME}/venv-ardupilot/bin/activate" >> /home/$USERNAME/.bashrc

# Setup ardupilot_gazebo plugin
RUN cd /home/$USERNAME/ \
    && sudo apt update \
    && sudo apt install cppzmq-dev ros-$ROS_DISTRO-ros-gz -y \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && sudo rm -rf /var/lib/apt/lists/* \
    && git clone https://github.com/ArduPilot/ardupilot_gazebo.git --depth 1 \
    && cd ardupilot_gazebo \
    && mkdir build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    && make -j4

# Build Wave Sim and ros_gz packages
RUN sudo apt-get -q update \
    && sudo apt-get install -y -qq --no-install-recommends libcgal-dev libfftw3-dev \
    && sudo apt-get autoremove -y \
    && sudo apt-get clean -y \
    && mkdir -p /home/$USERNAME/gz_ws/src \
    && cd /home/$USERNAME/gz_ws/src \
    && git clone https://github.com/srmainwaring/asv_wave_sim.git --depth 1 \
    && cd /home/$USERNAME/gz_ws/ \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install --merge-install --cmake-args \
                    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
                    -DBUILD_TESTING=ON \
                    -DCMAKE_CXX_STANDARD=17 \
    && echo "source /home/${USERNAME}/gz_ws/install/setup.sh " >> /home/$USERNAME/.bashrc \
    && cd /home/$USERNAME/gz_ws/src/asv_wave_sim/gz-waves/src/gui/plugins/waves_control \
    && mkdir build && cd build && cmake .. && make

# Install ping-python from source (Newer commits don't seem to work with the ping1d)
RUN cd /home/$USERNAME/ \
    && git clone https://github.com/bluerobotics/ping-python.git -b deployment \
    && cd ping-python \
    && git checkout 3d41ddd \
    && python3 setup.py install --user

# Build ROS2 workspace with the ping sonar package
RUN mkdir -p /home/$USERNAME/ping_ws/src/ \
    && cd /home/$USERNAME/ping_ws/ \
    && git clone https://github.com/itskalvik/bluerobotics_sonar.git --depth 1 /home/$USERNAME/ping_ws/src \
    && rosdep update \
    && sudo rosdep install --from-paths src --ignore-src -r -y \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && echo "source /home/$USERNAME/ping_ws/install/setup.sh " >> ~/.bashrc

# Build ROS2 workspace with sgptools
ENV DATA_FOLDER=/home/$USERNAME/ros2_ws/src/ros_sgp_tools/launch/data/
COPY --chown=$USER_UID:$USER_GID ros2_ws/src/ /home/$USERNAME/ros2_ws/src/
RUN cd /home/$USERNAME/ros2_ws/src \
    && . /home/$USERNAME/venv-ardupilot/bin/activate \
    && python3 -m pip install --no-cache-dir -r mavros_control/requirements.txt \
    && python3 -m pip install --no-cache-dir -r ros_sgp_tools/requirements.txt \
    && cd /home/$USERNAME/ros2_ws \
    && rosdep update \
    && sudo rosdep install -r --from-paths src -i -y --rosdistro $ROS_DISTRO \
    && . "/opt/ros/${ROS_DISTRO}/setup.sh" \
    && colcon build --symlink-install \
    && echo "source /ros_entrypoint_sitl.sh" >> /home/$USERNAME/.bashrc \
    && echo "source /home/${USERNAME}/ros2_ws/install/setup.sh " >> /home/$USERNAME/.bashrc

COPY sim-docker/ros_entrypoint_sitl.sh /ros_entrypoint_sitl.sh
RUN ln -s "/home/${USERNAME}/ros2_ws/src/ros_sgp_tools/launch/data/config.yaml" "/home/${USERNAME}/config.yaml"

# Keep bash alive even if there is an error
RUN echo "set +e" >> ~/.bashrc
ENTRYPOINT ["/ros_entrypoint_sitl.sh"]
CMD ["sleep", "infinity"]