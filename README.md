## Docker container for Brother Scanner Scan Key Support

Forked from plutino/docker-brscan4. *Thanks for seting up the framework*

This container sets up linux based network scanning using brscan-skey and brscan4 for the Brother DCP-L2540DW multi-function printer/scanner. Scans are dropped in the `scans` directory. ~~If you use the OCR option, it uses the amazing ocrmypdf tool.~~ *Removed ocrmypdf because I use a watch folder and standalone [ocrmypdf docker image](https://hub.docker.com/r/jbarlow83/ocrmypdf/)*

The latest brothers drivers  are found in the `drivers` directory (Allowed by their license).

Scan scripts can be found and edited in the `scripts` directory.

You can map the scan button options on the printer by editing the `config/brscan-skey.cfg` file.

To customize the docker for your own setup, edit the ENV variables in the `Dockerfile` to be the name and model for your device and the static IP assigned to your Brother device.

*Note: I was not able to get this working in docker bridge mode. It listens on UDP port 54925, and then connects to the scanner on TCP port 54921. However, the scanner would not send the data after the initial connection. It does work in macvlan mode as long as the scanner and the docker container are on the same subnet.*

build: 

    docker build -t zaxim/brscan4 .

create container interactive:

    docker run -it -v /tmp:/scans -p 54925:54925/udp --network macvlan zaxim/docker-brscan4 /bin/bash

create container service:

    docker run -d -v /tmp:/scans -p 54925:54925/udp --network macvlan zaxim/docker-brscan4 /bin/bash

