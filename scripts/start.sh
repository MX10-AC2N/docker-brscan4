#! /bin/bash
/usr/bin/brsaneconfig4 -a name=$SCANNER_NAME model=$SCANNER_MODEL ip=$SCANNER_IP_ADDRESS > /var/log/scanner.log 2>&1
/usr/bin/brscan-skey -f > /var/log/scanner.log 2>&1
