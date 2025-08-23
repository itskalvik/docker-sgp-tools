cmake_minimum_required(VERSION 3.10.2)

# Initialize the project
project(gz-waves1 VERSION 1.0.0)

# Find gz-cmake
find_package(gz-cmake3 REQUIRED)
set(GZ_CMAKE_VER ${gz-cmake3_VERSION_MAJOR})

# Configure the project
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

gz_configure_project()

# Include cmake
include(${PROJECT_SOURCE_DIR}/cmake/URL.conf.cmake)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# Set project-specific options

# Search for project-specific dependencies

# Find gnuplot-iostream - the header is used by the examples in test/plots
include(Add_gnuplot-iostream)

# Find gz-math
gz_find_package(gz-math7 REQUIRED COMPONENTS eigen3)
set(GZ_MATH_VER ${gz-math7_VERSION_MAJOR})

# Find gz-common
gz_find_package(gz-common5 REQUIRED COMPONENTS graphics events)
set(GZ_COMMON_VER ${gz-common5_VERSION_MAJOR})

# Find gz-plugin
gz_find_package(gz-plugin2 REQUIRED COMPONENTS loader register)
set(GZ_PLUGIN_VER ${gz-plugin2_VERSION_MAJOR})

# Gazebo Harmonic configuration
if("$ENV{GZ_VERSION}" STREQUAL "harmonic")

  # Find gz-msgs
  gz_find_package(gz-msgs10 REQUIRED)
  set(GZ_MSGS_VER ${gz-msgs10_VERSION_MAJOR})

  # Find gz-transport
  gz_find_package(gz-transport13 REQUIRED)
  set(GZ_TRANSPORT_VER ${gz-transport13_VERSION_MAJOR})

  # Find gz-rendering
  gz_find_package(gz-rendering8 REQUIRED)
  set(GZ_RENDERING_VER ${gz-rendering8_VERSION_MAJOR})

  # Find gz-sim
  gz_find_package(gz-sim8 REQUIRED)
  set(GZ_SIM_VER ${gz-sim8_VERSION_MAJOR})

  # Find SDFormat
  gz_find_package(sdformat14 REQUIRED)
  set(SDF_VER ${sdformat14_VERSION_MAJOR})

  message(STATUS "Compiling against Gazebo Harmonic")

else()  
  message(FATAL_ERROR "Unsupported GZ_VERSION: $ENV{GZ_VERSION}")
endif()

# Manually set OGRE2 paths
set(OGRE2_INCLUDE_DIRS "/opt/ros/jazzy/opt/gz_ogre_next_vendor/include/OGRE-Next")
set(OGRE2_LIBRARY_DIRS "/opt/ros/jazzy/opt/gz_ogre_next_vendor/lib")
include_directories(${OGRE2_INCLUDE_DIRS})
include_directories("${OGRE2_INCLUDE_DIRS}/Hlms/Common")
link_directories(${OGRE2_LIBRARY_DIRS})

# Manually create GzOGRE2 target
add_library(GzOGRE2::GzOGRE2 INTERFACE IMPORTED)
set_target_properties(GzOGRE2::GzOGRE2 PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${OGRE2_INCLUDE_DIRS}"
  INTERFACE_LINK_LIBRARIES "${OGRE2_LIBRARY_DIRS}/libOgreNextMain.so"
)

# Manually create other OGRE2 components targets
add_library(GzOGRE2::HlmsPbs INTERFACE IMPORTED)
set_target_properties(GzOGRE2::HlmsPbs PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${OGRE2_INCLUDE_DIRS}"
  INTERFACE_LINK_LIBRARIES "${OGRE2_LIBRARY_DIRS}/libOgreNextHlmsPbs.so"
)

add_library(GzOGRE2::HlmsUnlit INTERFACE IMPORTED)
set_target_properties(GzOGRE2::HlmsUnlit PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${OGRE2_INCLUDE_DIRS}"
  INTERFACE_LINK_LIBRARIES "${OGRE2_LIBRARY_DIRS}/libOgreNextHlmsUnlit.so"
)

add_library(GzOGRE2::Overlay INTERFACE IMPORTED)
set_target_properties(GzOGRE2::Overlay PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${OGRE2_INCLUDE_DIRS}"
  INTERFACE_LINK_LIBRARIES "${OGRE2_LIBRARY_DIRS}/libOgreNextOverlay.so"
)

add_library(GzOGRE2::PlanarReflections INTERFACE IMPORTED)
set_target_properties(GzOGRE2::PlanarReflections PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${OGRE2_INCLUDE_DIRS}"
  INTERFACE_LINK_LIBRARIES "${OGRE2_LIBRARY_DIRS}/libOgreNextPlanarReflections.so"
)

# Define compile-time default variables
if(MSVC)
  set(GZ_RENDERING_PLUGIN_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_BINDIR})
else()
  set(GZ_RENDERING_PLUGIN_PATH ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
endif()

# Find eigen3
find_package(Eigen3 REQUIRED)

# Find CGAL and its components
find_package(CGAL REQUIRED COMPONENTS Core)
if(NOT CGAL_FOUND)
  message(STATUS "This project requires the CGAL library, and will not be compiled.")
  return()  
endif()
include(${CGAL_USE_FILE})

# Find FFTW3
find_path(FFTW3-3_INCLUDE_DIR NAMES fftw3.h HINTS $ENV{FFTW3_DIR}/include PATHS /usr/local/include /usr/include)
find_library(FFTW3-3_LIBRARY NAMES fftw3 libfftw3 HINTS $ENV{FFTW3_DIR}/lib PATHS /usr/local/lib /usr/lib)
add_definitions(-DUSE_FFTW3)
set(FFT_INCLUDE_DIRS ${FFTW3-3_INCLUDE_DIR})
set(FFT_LIBRARIES ${FFTW3-3_LIBRARY})

# Find OpenCL and clFFT (uncomment if needed)
# find_package(OpenCL REQUIRED)
# find_package(clFFT REQUIRED)

# Location of "fake install folder" used in tests
set(FAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/fake/install")

# Configure the build
gz_configure_build(QUIT_IF_BUILD_ERRORS)

# add_subdirectory(examples)

# Create package information
gz_create_packages()

# Configure documentation
# TODO: add documentation api.md.in files

