FROM ubuntu:18.04
MAINTAINER Zaxim <zaxim@me.com>

# C.UTF-8 needed to make ocrmypdf work
ENV SCANNER_NAME="DCPL2540DW" SCANNER_MODEL="DCP-L2540DW" SCANNER_IP_ADDRESS="192.168.2.13" LC_ALL="C.UTF-8" LANG="C.UTF-8"

RUN apt-get -y update && apt-get -y upgrade && apt-get install -y sane sane-utils libusb-0.1 ghostscript netpbm ocrmypdf python3-pip && apt-get -y clean && rm -rf /var/lib/apt/lists/*

RUN pip3 install ocrmypdf --upgrade && rm -rf /root/.cache

RUN ln -sfn /usr/local/bin/ocrmypdf /usr/bin/ocrmypdf

COPY drivers /opt/brother/docker_skey/drivers
RUN dpkg -i /opt/brother/docker_skey/drivers/*.deb

COPY config /opt/brother/docker_skey/config
COPY scripts /opt/brother/docker_skey/scripts

RUN cfg=`ls /opt/brother/scanner/brscan-skey/brscan-skey-*.cfg`; ln -sfn /opt/brother/docker_skey/config/brscan-skey.cfg $cfg

CMD /opt/brother/docker_skey/scripts/start.sh
