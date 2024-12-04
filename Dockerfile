FROM ubuntu:20.04
# Set FLEDGE version, distribution, and platform
ENV FLEDGE_VERSION=2.6.0
ENV FLEDGE_DISTRIBUTION=ubuntu2004
ENV FLEDGE_PLATFORM=x86_64

#
# FROM balenalib/raspberrypi3-debian:20210705 as build
# ENV FLEDGE_VERSION=1.9.1
# ENV FLEDGE_DISTRIBUTION=buster
# ENV FLEDGE_PLATFORM=armv7l

# Avoid interactive questions when installing Kerberos
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    git \
    gnupg2 \
    iputils-ping \
    inetutils-telnet \
    nano \
    neovim \
    rsyslog \
    sed \
    software-properties-common \
    tmux \
    wget && \
    wget -q -O - http://archives.fledge-iot.org/KEY.gpg | apt-key add - && \
    add-apt-repository "deb http://archives.fledge-iot.org/latest/ubuntu2004/x86_64/ / " && \
    wget --no-check-certificate https://fledge-iot.s3.amazonaws.com/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge.tgz && \
    tar -xzvf fledge.tgz && \
    #
    # The postinstall script of the .deb package enables and starts the fledge service. Since services are not supported in docker
    # containers, we must modify the postinstall script to remove these lines so that the package will install without errors.
    # We will manually unpack the file, use sed to remove the offending lines, and then run 'apt install -yf' to install the 
    # package and the dependancies. Once the package is successfully installed, all of the service and plugin package
    # will install normally.
    #
    # Unpack .deb package    
    dpkg --unpack ./fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge_${FLEDGE_VERSION}_${FLEDGE_PLATFORM}.deb && \
    # Remove lines that enable and start the service. They call enable_FLEDGE_service() and start_FLEDGE_service()
    # Save to /fledge.postinst. We'll run that after we install the dependencies.
    sed '/^.*_fledge_service$/d' /var/lib/dpkg/info/fledge.postinst > /fledge.postinst && \
    # Rename the original file so that it doesn't get run in next step.
    mv /var/lib/dpkg/info/fledge.postinst /var/lib/dpkg/info/fledge.postinst.save && \
    # Configure the package and isntall dependencies.
    apt install -yf && \
    # Manually run the post install script - creates certificates, installs python dependencies etc.
    mkdir -p /usr/local/fledge/data/extras/fogbench && \
    chmod +x /fledge.postinst && \
    /fledge.postinst && \
    # Cleanup fledge installation packages
    rm -f /*.tgz && \ 
    # You may choose to leave the installation packages in the directory in case you need to troubleshoot
    rm -rf -r /fledge && \
    # General cleanup after using apt
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/

WORKDIR /usr/local/fledge
RUN for f in /usr/local/fledge/python/*.txt ; do pip3 install -r "$f" ; done

ENV FLEDGE_ROOT=/usr/local/fledge

VOLUME /usr/local/fledge

# Install code-server 
ENV PATH=/root/.local/bin:$PATH
ENV PASSWORD=FLEDGE
RUN curl -fsSL https://code-server.dev/install.sh > install.sh && \
    sh install.sh --method=standalone && \
    rm -f install.sh && \
    code-server --install-extension ms-python.python && \
    #code-server --install-extension ms-vscode.cpptools && \
    code-server --install-extension twxs.cmake && \
    code-server --install-extension alexcvzz.vscode-sqlite && \
    # Install pylint for code-server
    pip3 install pylint
# copy .pylintrc configuration
COPY /root /root 

# Fledge API port for FLEDGE API http and https and Code Server
# 8081 for FLEDGE webapi and 1995 for FLEDGE webapi over https
# 8080 for code server
# 6683 for HTTP south plugin and 6684 for HTTP south over https
# 4840 for OPC UA north
EXPOSE 8081 1995 8080 6683 6684 4840

#!/bin/bash

RUN echo "# Unprivileged Docker containers do not have access to the kernel log. This prevents an error when starting rsyslogd." > /usr/local/fledge/fledge.sh && \
    echo "sed -i '/imklog/s/^/#/' /etc/rsyslog.conf" >> /usr/local/fledge/fledge.sh && \
    echo "service rsyslog start" >> /usr/local/fledge/fledge.sh && \
    echo "/usr/local/fledge/bin/fledge start" >> /usr/local/fledge/fledge.sh && \
    echo "code-server --bind-addr 0.0.0.0:8080" >> /usr/local/fledge/fledge.sh && \
    echo "tail -f /var/log/syslog" >> /usr/local/fledge/fledge.sh

# start rsyslog, FLEDGE, and tail syslog
CMD ["bash","/usr/local/fledge/fledge.sh"]

LABEL maintainer="rob@raesemann.com" \
      author="Rob Raesemann" \
      target="x64" \
      version="${FLEDGE_VERSION}" \
      description="Fledge IOT Framework development image with troubleshooting tools running in Docker - Installed from .deb packages"