# This Dockerfile creates the Docker image of ParaView (v5.1.2).

# FROM CentOS
FROM centos:latest

# MAINTAINER is ishidakauya
MAINTAINER ishidakazuya

# ADD the shellscript for install
ADD install.sh /root

# Install ParaView and dependencies
RUN yum -y update \
&& yum -y install mpich mpich-devel gcc gcc-c++ make git python-devel mesa* boost boost-devel openssh openssh-server openssh-client \ 
&& yum -y groupinstall "X Window System" \
&& git clone https://github.com/FFmpeg/FFmpeg /root/FFmpeg \
&& cd /root/FFmpeg \
&& ./configure --disable-x86asm --enable-shared \
&& make -j8 \
&& make install \
&& cd /root \ 
&& curl -O https://cmake.org/files/v3.6/cmake-3.6.2.tar.gz \
&& tar -xvf cmake-3.6.2.tar.gz \
&& cd /root/cmake-3.6.2 \
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
&& rm -rf /root/build \
&& rm -rf /root/ParaView_src \
&& rm -rf /root/cmake-3.6.2 \
&& rm -rf /root/cmake-3.6.2.tar.gz \
&& rm -rf /root/FFmpeg \
&& yum -y remove gcc gcc-c++ git make \
&& yum clean all \
&& mkdir /usr/local/ParaView_5.1.2 \
&& mv /root/include /usr/local/ParaView_5.1.2 \
&& mv /root/bin /usr/local/ParaView_5.1.2 \
&& mv /root/lib /usr/local/ParaView_5.1.2 \
&& mv /root/share /usr/local/ParaView_5.1.2 \
&& mkdir /var/run/sshd \
&& mkdir /root/.ssh \
&& echo StrictHostKeyChecking=no > /root/.ssh/config \
&& sed -i -e s/\#PermitRootLogin\ yes/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
&& sed -i -e s/\#RSAAuthentication\ yes/RSAAuthentication\ yes/ /etc/ssh/sshd_config \
&& sed -i -e s/\#PubkeyAuthentication\ yes/PubkeyAuthentication\ yes/ /etc/ssh/sshd_config \
&& sed -i -e s/PasswordAuthentication\ yes/\PasswordAuthentication\ no/ /etc/ssh/sshd_config \
&& sed -i -e s@HostKey\ /etc/ssh/ssh_host_dsa_key@\#HostKey\ /etc/ssh/ssh_host_dsa_key@ /etc/ssh/sshd_config \
&& sed -i -e s@HostKey\ /etc/ssh/ssh_host_ecdsa_key@\#HostKey\ /etc/ssh/ssh_host_ecdsa_key@ /etc/ssh/sshd_config \
&& sed -i -e s@HostKey\ /etc/ssh/ssh_host_ed25519_key@\#HostKey\ /etc/ssh/ssh_host_ed25519_key@ /etc/ssh/sshd_config \
&& ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key \
&& ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa \
&& mv /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
&& chmod 600 /root/.ssh/authorized_keys \
&& chmod 600 /root/.ssh/config \
&& chmod 700 /root/.ssh

# Set PATH
ENV PATH=$PATH:/usr/lib64/mpich/bin:/usr/local/ParaView_5.1.2/bin

# EXPOSE Port 11111
EXPOSE 11111

# CMD is /bin/bash
CMD /bin/bash

