FROM ubuntu:20.04
# Set FLEDGE version, distribution, and platform
ENV FLEDGE_VERSION=1.9.1
ENV FLEDGE_DISTRIBUTION=ubuntu2004
ENV FLEDGE_PLATFORM=x86_64

#
# FROM balenalib/raspberrypi3-debian:20210705 as build
# ENV FLEDGE_VERSION=1.9.1
# ENV FLEDGE_DISTRIBUTION=buster
# ENV FLEDGE_PLATFORM=armv7l

# Avoid interactive questions when installing Kerberos
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt dist-upgrade -y && apt install --no-install-recommends --yes \
    git \
    iputils-ping \
    inetutils-telnet \
    nano \
    rsyslog \
    sed \
    wget && \
    wget --no-check-certificate https://fledge-iot.s3.amazonaws.com/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-${FLEDGE_VERSION}_${FLEDGE_PLATFORM}_${FLEDGE_DISTRIBUTION}.tgz && \
    tar -xzvf fledge-${FLEDGE_VERSION}_${FLEDGE_PLATFORM}_${FLEDGE_DISTRIBUTION}.tgz && \
    #
    # The postinstall script of the .deb package enables and starts the fledge service. Since services are not supported in docker
    # containers, we must modify the postinstall script to remove these lines so that the package will install without errors.
    # We will manually unpack the file, use sed to remove the offending lines, and then run 'apt install -yf' to install the 
    # package and the dependancies. Once the package is successfully installed, all of the service and plugin package
    # will install normally.
    #
    # Unpack .deb package    
    dpkg --unpack ./fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb && \
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
    # Install our fledge notification services and plugins
    # Comment out any that you do not want
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-service-notification-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-asset-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-change-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-delta-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-expression-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-fft-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-metadata-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-python35-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-rate-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-rms-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-scale-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-scale-set-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-filter-threshold-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y  && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-north-harperdb-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-north-http-north-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-north-httpc-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-north-kafka-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-north-opcua-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-alexa-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-asset-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-email-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-ifttt-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-python35-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-notify-slack-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-rule-average-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-rule-outofbound-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-rule-simple-expression-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-benchmark-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-csv-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-CSV-Async-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-dnp3-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-expression-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-modbus-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-modbustcp-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-http-south-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-mqtt-sparkplug-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-opcua-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-openweathermap-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-playback-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-random-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-randomwalk-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-sinusoid-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    apt install /fledge/${FLEDGE_VERSION}/${FLEDGE_DISTRIBUTION}/${FLEDGE_PLATFORM}/fledge-south-systeminfo-${FLEDGE_VERSION}-${FLEDGE_PLATFORM}.deb -y && \
    # Cleanup fledge installation packages
    rm -f /*.tgz && \ 
    # You may choose to leave the installation packages in the directory in case you need to troubleshoot
    rm -rf -r /fledge && \
    # General cleanup after using apt
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /var/lib/apt/lists/

WORKDIR /usr/local/fledge
COPY fledge.sh fledge.sh
COPY ./python /usr/local/fledge/python/
RUN for f in /usr/local/fledge/python/*.txt ; do pip3 install -r "$f" ; done

ENV FLEDGE_ROOT=/usr/local/fledge

VOLUME /usr/local/fledge

# Install code-server 
ENV PATH /root/.local/bin:$PATH
ENV PASSWORD=FLEDGE
RUN curl -fsSL https://code-server.dev/install.sh > install.sh && \
    sh install.sh --method=standalone && \
    rm -f install.sh && \
    code-server --install-extension ms-python.python && \
    code-server --install-extension ms-vscode.cpptools && \
    code-server --install-extension twxs.cmake && \
    code-server --install-extension alexcvzz.vscode-sqlite && \
    code-server --install-extension mechatroner.rainbow-csv && \
    # Install pylint for code-server
    pip3 install pylint
# copy .pylintrc configuration
COPY /root /root 

# Fledge API port for FELDGE API http and https and Code Server
EXPOSE 8081 1995 8080

# start rsyslog, FLEDGE, and tail syslog
CMD ["bash","/usr/local/fledge/fledge.sh"]

LABEL maintainer="rob@raesemann.com" \
      author="Rob Raesemann" \
      target="Docker" \
      version="${FLEDGE_VERSION}" \
      description="Fledge IOT Framework development image with troubleshooting tools running in Docker - Installed from .deb packages"