FROM ubuntu:18.04

#install dependences for:
# * downloading Vivado (wget)
# * xsim (gcc build-essential to also get make)
# * MIG tool (libglib2.0-0 libsm6 libxi6 libxrender1 libxrandr2 libfreetype6 libfontconfig)
# * CI (git)
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  libglib2.0-0 \
  libsm6 \
  libxi6 \
  libxrender1 \
  libxrandr2 \
  libfreetype6 \
  libfontconfig \
  lsb-release

# turn off recommends on container OS
# install required dependencies
RUN echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > \
    /etc/apt/apt.conf.d/01norecommend && \
    apt-get update && \
    apt-get -y install \
        bzip2 \
        libc6-i386 \
        git \
        libfontconfig1 \
        libglib2.0-0 \
        sudo \
        nano \
        locales \
        libxext6 \
        libxrender1 \
        libxtst6 \
        libgtk2.0-0 \
        build-essential \
        unzip \
        ruby \
        ruby-dev \
        pkg-config \
        libprotobuf-dev \
        protobuf-compiler \
        python-protobuf \
        python-pip && \
        pip install intelhex && \
        echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
        locale-gen && \
        gem install fpm && \
        apt-get clean

# copy in config file
COPY install_config.txt /tmp/
ADD Xilinx_Vivado_2019.2_1106_2127.tar.gz /tmp/

RUN /tmp/Xilinx_Vivado_2019.2_1106_2127/xsetup --agree 3rdPartyEULA,WebTalkTerms,XilinxEULA --batch Install -c /tmp/install_config.txt
RUN rm -rf /tmp/*

RUN adduser --disabled-password --gecos '' vivado
USER vivado
WORKDIR /home/vivado

#add vivado tools to path
RUN echo "source /tools/Xilinx/Vivado/2019.2/settings64.sh" >> /home/vivado/.bashrc

#copy in the license file
RUN mkdir /home/vivado/.Xilinx

# add U96 board files
ADD /board_files.tar.gz /tools/Xilinx/Vivado/2019.2/data/boards/board_files/

