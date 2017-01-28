# This Dockerfile creates an image of ParaView_5.1.2 with OpenGL, MPICH, X Window System, Python and FFmpeg.

# FROM CentOS
FROM centos:latest

# MAINTAINER is ishidakauya
MAINTAINER ishidakazuya

# ADD the script for installation of ParaView 
ADD install.sh /root

# Install ParaView
RUN yum -y update \
&& yum -y install mpich mpich-devel gcc gcc-c++ make git python-devel numpy mesa* llvm llvm-devel boost boost-devel \ 
&& yum -y groupinstall "X Window System" \
&& yum clean all \
&& git clone https://github.com/FFmpeg/FFmpeg /FFmpeg \
&& cd /FFmpeg \
&& ./configure --disable-yasm --enable-shared \
&& make -j8 \
&& make install \
&& rm -rf /FFmpeg \
&& cd / \ 
&& curl -O https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz \
&& tar -xvf cmake-3.6.2.tar.gz \
&& rm -f cmake-3.6.2.tar.gz \
&& cd /cmake-3.6.2 \
&& ./configure \
&& gmake -j8 \
&& gmake install \
&& git clone https://github.com/Kitware/ParaView.git /root/ParaView_src \
&& mkdir /root/build \
&& mv /root/install.sh /root/build \
&& cd /root/ParaView_src \
&& git config submodule.VTK.url https://github.com/Kitware/VTK.git \
&& git checkout v5.1.2 \
&& git submodule init \
&& git submodule update \
&& cd /root/build \
&& bash install.sh \
&& rm -rf /root/ParaView_src \
&& rm -rf /root/build \
&& yum -y remove gcc gcc-c++ git make \
&& yum clean all 

# Set PATH
ENV PATH=$PATH:/usr/lib64/mpich/bin

# CMD is /bin/bash
CMD /bin/bash

