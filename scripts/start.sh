#/usr/sbin/useradd --system scan_user -u $PUID
chown -R $PUID:$PGID /scans
/usr/bin/brsaneconfig4 -a name=$SCANNER_NAME model=$SCANNER_MODEL ip=$SCANNER_IP_ADDRESS
#su scan_user -c "/usr/bin/brscan-skey -f"
/usr/bin/brscan-skey -f
