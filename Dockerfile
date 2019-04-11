FROM python:3.7-slim-stretch
MAINTAINER Zaxim <zaxim@me.com>

# C.UTF-8 needed to make ocrmypdf work
ENV SCANNER_NAME="DCP-L2540DW" SCANNER_MODEL="DCP-L2540DW" SCANNER_IP_ADDRESS="192.168.2.13" LC_ALL="C.UTF-8" LANG="C.UTF-8"


RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/backports.list && apt-get -y update && apt-get -y upgrade && apt-get -t stretch-backports install -y sane sane-utils libusb-0.1 ghostscript netpbm ocrmypdf && apt-get -y clean && rm -rf /var/lib/apt/lists/* && pip3 install ocrmypdf

#Clean up old ocrmypdf
RUN rm /usr/bin/ocrmypdf && ln -s /usr/local/bin/ocrmypdf /usr/bin/ocrmypdf

COPY drivers /opt/brother/docker_skey/drivers
RUN dpkg -i /opt/brother/docker_skey/drivers/*.deb

COPY config /opt/brother/docker_skey/config
COPY scripts /opt/brother/docker_skey/scripts

RUN cfg=`ls /opt/brother/scanner/brscan-skey/brscan-skey-*.cfg`; ln -sfn /opt/brother/docker_skey/config/brscan-skey.cfg $cfg

CMD /opt/brother/docker_skey/scripts/start.sh
