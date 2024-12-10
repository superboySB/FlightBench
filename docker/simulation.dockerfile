FROM nvidia/cudagl:11.3.0-devel-ubuntu20.04

# Please contact with me if you have problems
LABEL maintainer="Zipeng Dai <daizipeng@bit.edu.cn>"
ENV DEBIAN_FRONTEND=noninteractive
ARG PYTHON_VERSION=3.9
# TODO：网络不好的话可以走代理
# ENV http_proxy=http://127.0.0.1:8889
# ENV https_proxy=http://127.0.0.1:8889

# Setup basic packages
RUN echo 'Etc/UTC' > /etc/timezone && \
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata software-properties-common
RUN apt-get update && apt-get install -y --no-install-recommends\
    python3-pip \
    build-essential \
    python3 \
    python3-dev \
    git \
    git-lfs \
    curl \
    vim \
    tmux \
    gnupg2 \
    lsb-release \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    libglfw3-dev \
    libglm-dev \
    libx11-dev \
    libomp-dev \
    libegl1-mesa-dev \
    pkg-config \
    libzmqpp-dev \
    libopencv-dev \
    libeigen3-dev \
    wget \
    gedit \
    zip \
    unzip \
    cmake

# -----------------------------------------------------
# ROS and relevant infra
ENV ROS_DISTRO=noetic
ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN curl -sSL 'http://keyserver.ubuntu.com/pks/lookup?op=get&search=0xC1CF6E31E6BADE8868B172B4F42ED6FBAB17C654' | apt-key add -
RUN apt update
RUN apt-get install -y ros-noetic-desktop-full
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc
RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bash_profile

# -----------------------------------------------------
# PX4 and relevant infra
WORKDIR /workspace
RUN git clone https://github.com/PX4/PX4-Autopilot.git -b v1.15.2 --recursive
COPY docker/requirements.txt /workspace/PX4-Autopilot/requirements.txt
COPY docker/ubuntu.sh /workspace/PX4-Autopilot/ubuntu.sh 
RUN cd PX4-Autopilot/ && bash ubuntu.sh --no-nuttx && make clean
RUN pip3 install --upgrade numpy
RUN cd PX4-Autopilot/ && DONT_RUN=1 make px4_sitl_default gazebo-classic
WORKDIR /workspace
RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage && chmod +x ./QGroundControl.AppImage 
RUN apt-get install -y ros-${ROS_DISTRO}-mavros ros-${ROS_DISTRO}-mavros-extras ros-${ROS_DISTRO}-vision-msgs ros-${ROS_DISTRO}-octomap* \
    libgoogle-glog-dev protobuf-compiler ros-$ROS_DISTRO-joy python3-vcstool python3-empy python3-rosbag python3-venv && \
    wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh && \
    bash install_geographiclib_datasets.sh
RUN /bin/bash -c "source /opt/ros/noetic/setup.bash && mkdir -p /workspace/catkin_ws/src && cd /workspace/catkin_ws/ && catkin_make"
RUN echo "source /workspace/catkin_ws/devel/setup.bash" >> ~/.bashrc
RUN echo "source /workspace/PX4-Autopilot/Tools/simulation/gazebo-classic/setup_gazebo.bash /workspace/PX4-Autopilot/ /workspace/PX4-Autopilot/build/px4_sitl_default" >> ~/.bashrc
RUN echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:/workspace/PX4-Autopilot/" >> ~/.bashrc
RUN echo "export ROS_PACKAGE_PATH=\$ROS_PACKAGE_PATH:/workspace/PX4-Autopilot/Tools/simulation/gazebo-classic/sitl_gazebo-classic" >> ~/.bashrc

# ------------------------------------------------------
# FlightBench
WORKDIR /workspace
RUN mkdir flightbench_ws && cd flightbench_ws && mkdir src && cd src && git clone https://github.com/superboySB/FlightBench && \
    cd FlightBench && git submodule update --init --recursive
RUN echo "export FLIGHTMARE_PATH=/workspace/flightbench_ws/src/FlightBench" >> ~/.bashrc
WORKDIR /workspace/flightbench_ws/src/FlightBench 
RUN python3 -m venv flightpy && . flightpy/bin/activate && cd flightrl && pip install --upgrade pip && pip install -r requirements.txt
RUN cd flightlib && . flightpy/bin/activate && pip install .
RUN cd flightrl && . flightpy/bin/activate && pip install -e .
RUN pip3 install catkin-tool
WORKDIR /workspace/flightbench_ws/
RUN catkin config --init --mkdirs --extend /opt/ros/$ROS_DISTRO --merge-devel --cmake-args -DPYTHON_EXECUTABLE=/usr/bin/python3 -DCMAKE_BUILD_TYPE=Release
RUN catkin build

# -----------------------------------------------------
RUN rm -rf /var/lib/apt/lists/* && apt-get clean
ENV GLOG_minloglevel=2
ENV MAGNUM_LOG="quiet"
# TODO：如果走了代理、但是想镜像本地化到其它机器，记得清空代理（或者容器内unset）
# ENV http_proxy=
# ENV https_proxy=
# ENV no_proxy=
CMD ["/bin/bash"]
WORKDIR /workspace