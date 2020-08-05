#
# FLEDGE on IOx
# 
FROM ubuntu:18.04

# Avoid interactive questions when installing Kerberos
ENV DEBIAN_FRONTEND=noninteractive

# Install packages required for Fledge
RUN apt update && apt -y install --no-install-recommends wget rsyslog && \
    wget --no-check-certificate https://fledge-iot.s3.amazonaws.com/1.8.0/ubuntu1804/x86_64/fledge-1.8.0_x86_64_ubuntu1804.tgz && \
    tar -xzvf fledge-1.8.0_x86_64_ubuntu1804.tgz && \
    # Install any dependenies for the .deb file
    apt -y install `dpkg -I ./fledge/1.8.0/ubuntu1804/x86_64/fledge-1.8.0-x86_64.deb | awk '/Depends:/{print$2}' | sed 's/,/ /g'` && \
    dpkg-deb -R ./fledge/1.8.0/ubuntu1804/x86_64/fledge-1.8.0-x86_64.deb fledge-1.8.0-x86_64 && \
    cp -r fledge-1.8.0-x86_64/usr /. && \ 
    mv /usr/local/fledge/data.new /usr/local/fledge/data && \
    # Install plugins
    # Comment out any packages that you don't need to make the image smaller
    mkdir /package_temp && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-rule-simple-expression-1.8.0-x86_64.deb /package_temp/fledge-rule-simple-expression-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-service-notification-1.8.0-x86_64.deb /package_temp/fledge-service-notification-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-notify-python35-1.8.0-x86_64.deb /package_temp/fledge-notify-python35-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-notify-email-1.8.0-x86_64.deb /package_temp/fledge-notify-email-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-rule-outofbound-1.8.0-x86_64.deb /package_temp/fledge-rule-outofbound-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-rule-average-1.8.0-x86_64.deb /package_temp/fledge-rule-average-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-filter-python35-1.8.0-x86_64.deb /package_temp/fledge-filter-python35-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-filter-expression-1.8.0-x86_64.deb /package_temp/fledge-filter-expression-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-filter-delta-1.8.0-x86_64.deb /package_temp/fledge-filter-delta-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-benchmark-1.8.0-x86_64.deb /package_temp/fledge-south-benchmark-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-dnp3-1.8.0-x86_64.deb /package_temp/fledge-south-dnp3-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-expression-1.8.0-x86_64.deb /package_temp/fledge-south-expression-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-modbustcp-1.8.0-x86_64.deb /package_temp/fledge-south-modbustcp-1.8.0-x86_64/  && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-mqtt-sparkplug-1.8.0-x86_64.deb /package_temp/fledge-south-mqtt-sparkplug-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-opcua-1.8.0-x86_64.deb /package_temp/fledge-south-opcua-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-random-1.8.0-x86_64.deb /package_temp/fledge-south-random-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-randomwalk-1.8.0-x86_64.deb /package_temp/fledge-south-randomwalk-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-sinusoid-1.8.0-x86_64.deb /package_temp/fledge-south-sinusoid-1.8.0-x86_64/  && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-south-systeminfo-1.8.0-x86_64.deb /package_temp/fledge-south-systeminfo-1.8.0-x86_64/  && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-north-kafka-1.8.0-x86_64.deb /package_temp/fledge-north-kafka-1.8.0-x86_64/  && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-north-http-north-1.8.0-x86_64.deb /package_temp/fledge-north-http-north-1.8.0-x86_64/ && \
    dpkg-deb -R /fledge/1.8.0/ubuntu1804/x86_64/fledge-north-httpc-1.8.0-x86_64.deb /package_temp/fledge-north-httpc-1.8.0-x86_64/ && \
    # Copy plugins into place
    cp -r /package_temp/fledge-rule-simple-expression-1.8.0-x86_64/usr /. && \
    cp -r /package_temp/fledge-service-notification-1.8.0-x86_64/usr /. && \
    cp -r /package_temp/fledge-notify-python35-1.8.0-x86_64/usr /. && \
    cp -r /package_temp/fledge-notify-email-1.8.0-x86_64/usr /. && \
    cp -r /package_temp/fledge-rule-outofbound-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-rule-average-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-filter-python35-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-filter-expression-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-filter-delta-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-benchmark-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-dnp3-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-expression-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-north-http-north-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-north-httpc-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-north-kafka-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-modbustcp-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-mqtt-sparkplug-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-opcua-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-random-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-randomwalk-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-sinusoid-1.8.0-x86_64/usr /. && \ 
    cp -r /package_temp/fledge-south-systeminfo-1.8.0-x86_64/usr /.  && \ 
    rm ./*.tgz && \ 
    rm -r ./package_temp && \ 
    rm -r ./fledge && \ 
    apt clean && \
    rm -rf /var/lib/apt/lists/* /foglamp* /usr/include/boost

WORKDIR /usr/local/fledge
COPY fledge.sh fledge.sh
RUN  ./scripts/certificates fledge 365 && \
    chown -R root:root /usr/local/fledge && \
    chown -R ${SUDO_USER}:${SUDO_USER} /usr/local/fledge/data && \
    pip3 install wheel && \
    pip3 install -r /usr/local/fledge/python/requirements.txt
    
ENV FOGLAMP_ROOT=/usr/local/fledge

VOLUME /usr/local/fledge/data

# FogLAMP API port
EXPOSE 8081 1995 502 23

# start rsyslog, FogLAMP, and tail syslog
CMD ["bash","/usr/local/fledge/fledge.sh"]

LABEL maintainer="rob@raesemann.com" \
      author="Rob Raesemann" \
      target="Docker" \
      version="1.8.0" \
      description="Fledge IOT Framework running in Docker - Installed from .deb packages"