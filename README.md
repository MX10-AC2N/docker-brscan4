## Docker container for Brother scanner scan key support



build: 

    docker build -t zaxim/brscan4 .

create container interactive:

    docker run -it -v /tmp:/scans -p 54925:54925/udp -p 54921:54921 zaxim/brscan4 /bin/bash

