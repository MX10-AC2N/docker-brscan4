FROM debian:stretch
MAINTAINER Zaxim <zaxim@me.com>

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y sane sane-utils libusb-0.1 ghostscript netpbm ocrmypdf && apt-get -y clean

COPY drivers /opt/brother/docker_skey/drivers
RUN dpkg -i /opt/brother/docker_skey/drivers/*.deb

COPY config /opt/brother/docker_skey/config
COPY scripts /opt/brother/docker_skey/scripts

RUN cfg=`ls /opt/brother/scanner/brscan-skey/brscan-skey-*.cfg`; ln -sfn /opt/brother/docker_skey/config/brscan-skey.cfg $cfg

ENV SCANNER_NAME="DCP-L2540DW"
ENV SCANNER_MODEL="DCP-L2540DW"
ENV SCANNER_IP_ADDRESS="192.168.2.13"

#VOLUME /scans
CMD /opt/brother/docker_skey/scripts/start.sh
