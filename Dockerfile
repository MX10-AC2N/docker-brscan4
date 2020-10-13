FROM ubuntu:20.04
LABEL maintainer="Zaxim <1308071+Zaxim@users.noreply.github.com>"

# Set environment variables for your scanner
ENV SCANNER_NAME="DCPL2540DW"
ENV SCANNER_MODEL="DCP-L2540DW"
ENV SCANNER_IP_ADDRESS="192.168.2.13"
ENV TZ="America/New_York"

# Set UID and GIDs for scanner user and file outputs
ENV PUID="1000"
ENV PGID="1000"

ENV LC_ALL="C.UTF-8" LANG="C.UTF-8" 
ENV DEBIAN_FRONTEND="noninteractive"

# Debug mode
ENV INTR="true"

RUN apt-get -y update && apt-get install -y \ 
	sane \
	sane-utils \
	libusb-0.1 \
	libtiff-tools \
	&& apt-get -y clean && rm -rf /var/lib/apt/lists/*

COPY drivers /opt/brother/docker_skey/drivers
RUN dpkg -i /opt/brother/docker_skey/drivers/brscan4*.deb
RUN dpkg -i /opt/brother/docker_skey/drivers/brscan-skey*.deb

COPY scripts /opt/brother/docker_skey/scripts

COPY config /opt/brother/docker_skey/config

RUN ln -sfn /opt/brother/docker_skey/config/brscan-skey.config /etc/opt/brother/scanner/brscan-skey/brscan-skey.config && \
	ln -sfn /opt/brother/docker_skey/config/brscan_mail.config /etc/opt/brother/scanner/brscan-skey/brscan_mail.config && \
	ln -sfn /opt/brother/docker_skey/config/brscantoemail.config /etc/opt/brother/scanner/brscan-skey/brscantoemail.config && \
	ln -sfn /opt/brother/docker_skey/config/brscantofile.config /etc/opt/brother/scanner/brscan-skey/brscantofile.config && \
	ln -sfn /opt/brother/docker_skey/config/brscantoimage.config /etc/opt/brother/scanner/brscan-skey/brscantoimage.config && \
	ln -sfn /opt/brother/docker_skey/config/brscantoocr.config /etc/opt/brother/scanner/brscan-skey/brscantoocr.config

RUN mkdir -p /scans

CMD /opt/brother/docker_skey/scripts/start.sh
