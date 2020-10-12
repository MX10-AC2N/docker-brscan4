FROM ubuntu:20.04
LABEL maintainer="Zaxim <1308071+Zaxim@users.noreply.github.com>"

# Set environment variables for your scanner
ENV SCANNER_NAME="DCPL2540DW"
ENV SCANNER_MODEL="DCP-L2540DW"
ENV SCANNER_IP_ADDRESS="192.168.2.13"
ENV TZ="America/New_York"

ENV LC_ALL="C.UTF-8" LANG="C.UTF-8" 
ENV DEBIAN_FRONTEND="noninteractive" 

# Debug mode
ENV INTR="true"

RUN apt-get -y update && apt-get install -y \ 
	sane \
	sane-utils \
	libusb-0.1 \
	&& apt-get -y clean && rm -rf /var/lib/apt/lists/*

COPY drivers /opt/brother/docker_skey/drivers
RUN dpkg -i /opt/brother/docker_skey/drivers/*.deb

COPY config /opt/brother/docker_skey/config
COPY scripts /opt/brother/docker_skey/scripts

RUN cfg=`ls /opt/brother/scanner/brscan-skey/brscan-skey-*.cfg`; ln -sfn /opt/brother/docker_skey/config/brscan-skey.cfg $cfg

CMD /opt/brother/docker_skey/scripts/start.sh
