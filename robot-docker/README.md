<div style="text-align:left">
<p><a href="https://github.com/itskalvik/docker-sgp-tools/tree/main">
<img width="75%" src="../.assets/blueos_sgptools.png">
</a></p>
</div>

A BlueOS extension that enables **fully autonomous and adaptive bathymetric surveys** on the BlueBoat and any ArduPilot-based ASV using SGP-Tools. Powered by the latest research in Informative Path Planning (IPP).

## 🌟 Features
* **Automatic Waypoint Generation:** Generates efficient survey routes from your QGroundControl geofence polygon.

* **Autonomous & Adaptive Missions:** Arms, runs, and disarms the ASV automatically, adapting routes in real time based on sensor data.

* **Supported Sensors:** Works with Ping1D, GPS, and more (fully configurable in config.yaml).

* **Persistent Data Logging:** Stores mission logs and collected data as HDF5 files for post-mission analysis and map reconstruction.

* **Onboard Visualization:** Easily publish mission results for real-time or offline viewing in [Foxglove](https://foxglove.dev/product) or Jupyter Notebook.

* **Easy Plan Upload:** Drag and drop QGroundControl plan files with geofence directly into `/usr/blueos/extensions/sgptools`.

* **Web Terminal Access:** Launch, debug, and analyze missions through the BlueOS browser UI.

* **Configurable & Extensible:** Quickly modify sensors, mission types, and planner options via YAML config—add new models with ease.

* **Integrated Simulator:** Test, develop, and validate survey missions in a realistic Gazebo & SITL environment using our dedicated [simulator docker container](https://github.com/itskalvik/docker-sgp-tools).

* **Minimal Setup:** Installs in seconds from the BlueOS App Store; no complex setup required.

* **Multi-Arch & Platform Support:** Runs on ARM64 (Raspberry Pi), AMD64, and any ArduPilot-compatible ASV with sufficient memory (4GB+).                           |

## 📋 Prerequisites
* 64-bit [BlueOS](https://github.com/bluerobotics/BlueOS/releases) running on Raspberry Pi 4 or similar (ARM64) or AMD64 platform
* At least **4GB RAM + swap** (see Swap Setup below)
* Compatible sensors (e.g., Ping1D sonar)

## 🧰 Installation
#### Install Directly from the BlueOS App Store
1. Open BlueOS in your browser (e.g., `http://blueos.local/`)
2. Go to **Extensions** tab
3. Find **SGP-Tools** in the App Store and click **Install**
4. The extension will auto-launch on boot

## ⚙️ Usage

### Upload Your Survey Area Plan
1. Use [QGroundControl](https://qgroundcontrol.com/) to draw your geofence and home position
2. Save as `mission.plan`
    <div style="text-align:left">
    <img width="472" src="../.assets/generate_plan.gif">
    </a></p>
    </div>

3. Upload to `/usr/blueos/extensions/sgptools/` in BlueOS (using `File Browser` in `Pirate Mode`)
    <div style="text-align:left">
    <img width="472" src="../.assets/upload_mission.gif">
    </a></p>
    </div>

### Configure (Optional)
* Advanced users can edit `/root/config.yaml` in the SGP-Tools web terminal to:
    * Select/modify sensor config
    * Change mission type (`AdaptiveIPP`, `IPP`, `Waypoint`)
    * Adjust optimization parameters

    See the [ros_sgp_tools](https://github.com/itskalvik/ros_sgp_tools) README for configuration details.

### Start Your Mission

1. Open the SGP-Tools web terminal from the BlueOS UI (left menu)
2. Start the planner:
    ```
    ros2 launch ros_sgp_tools asv.launch.py
    ```
    * The vehicle will arm, start the survey, and collect data automatically

    <div style="text-align:left">
    <img width="472" src="../.assets/start_mission.gif">
    </a></p>
    </div>

### Data Visualization
* After the mission, you can visualize collected data via:
    ```
    ros2 launch ros_sgp_tools visualize_data.launch.py
    ```
* Then open [Foxglove](https://app.foxglove.dev/) in your browser, and connect to your ASV’s IP to view the bathymetry data

* ⚠️ Do not run this during the mission, as it will disrupt the path planner

    <div style="text-align:left">
    <img width="472" src="../.assets/data_viz.gif">
    </a></p>
    </div>

## 💾 Persistent Storage

The extension maps:

* Host: `/usr/blueos/extensions/sgptools/`
* Container: `/root/ros2_ws/src/ros_sgp_tools/launch/data/`

This directory is persistent and stores:

* `mission.plan`
* `config.yaml`
* All mission logs: `IPP-mission-<timestamp>/`
* Swap configuration script: `config_swap.sh`

## 🧠 Swap Setup & Memory Requirements

* At least **4GB of RAM or swap** is required.
* The extension includes a swap configuration script:
`/usr/blueos/extensions/sgptools/config_swap.sh`
* **Increase swap (if needed):**
    * In BlueOS, open a terminal (Pirate Mode), then run:
    
    ```bash
    red-pill
    ```
    
    ```bash
    sudo bash /usr/blueos/extensions/sgptools/config_swap.sh
    ```

## 🧪 Simulation & Testing with the SGP-Tools Simulator
Want to experiment, develop, or validate missions before deploying to the water?

The [docker-sgp-tools](https://github.com/itskalvik/docker-sgp-tools) repository includes a **fully integrated Gazebo simulator container** with all the tools you need for realistic software-in-the-loop (SITL) testing.

### 🚀 Simulator Features
* **Gazebo Simulation:** Realistic 3D environment with the BlueBoat ASV model and waves.

* **ArduPilot SITL:** Software-in-the-loop autopilot runs your real survey missions.

* **SGP-Tools & ROS 2:** The full path planning stack, exactly as on your robot.

## 📝 Notes and Troubleshooting

* **Extension won’t launch / out of memory:**
    
    Run the swap setup, and ensure enough memory is available.

* **No mission data or logs:**
    
    Make sure the `Ping 1D` port is correctly listed in the `config.yaml`

* **Cannot connect via Foxglove:**

    Verify network settings, and that Foxglove bridge is running.

## 📚 More Info & Documentation

* [SGP-Tools project site](https://www.sgp-tools.com/)
* [ros_sgp_tools package](https://github.com/itskalvik/ros_sgp_tools)
* [SGP-Tools Docker images](https://github.com/itskalvik/docker-sgp-tools)
* [QGroundControl plan files](https://docs.qgroundcontrol.com/Stable_V4.3/en/qgc-user-guide/plan_view/plan_view.html)
* [BlueOS Docs](https://blueos.cloud/docs/latest/usage/overview/)

## ⚠️ Disclaimer 
This extension, when executed properly, will take control of the ASV and could potentially collide the vehicle with obstacles in the environment. Please use it with caution.