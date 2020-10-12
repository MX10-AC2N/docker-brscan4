#! /bin/bash
# scan2ocr
#
sleep 0.2

if [ -e ~/.brscan-skey/scantoocr.config ];then
   source ~/.brscan-skey/scantoocr.config
elif [ -e /etc/opt/brother/scanner/brscan-skey/scantoocr.config ];then
   source /etc/opt/brother/scanner/brscan-skey/scantoocr.config
fi

[[ $INTR == "true" ]] && set -x

SCANIMAGE="/opt/brother/scanner/brscan-skey/skey-scanimage"
OUTPUT=/tmp/brscan_"$(date +%Y-%m-%d-%H-%M-%S)".tif
OUTPUT_PDF=/scans/brscan_"$(date +%Y-%m-%d-%H-%M-%S)".pdf
OPT_OTHER="--mode 24bit Color[Fast]"



if [ "$resolution" != '' ];then
   OPT_RESO="--resolution $resolution" 
else
   OPT_RESO="--resolution 100" 
fi

if [ "$source" != '' ];then
   OPT_SRC="--source $source" 
else
   OPT_SRC="--source FB" 
fi

if [ "$size" != '' ];then
   OPT_SIZE="--size $size" 
else
   OPT_SIZE="--size A4" 
fi

if [ "$duplex" = 'ON' ];then
   OPT_DUP="--duplex"
   OPT_SRC="--source ADF_C" 
else
   OPT_DUP=""
fi
OPT_FILE="--outputfile  $OUTPUT"

OPT_DEV="--device-name $1"

OPT="$OPT_DEV $OPT_RESO $OPT_SRC $OPT_SIZE $OPT_DUP $OPT_OTHER $OPT_FILE"

if [ "$(echo "$1" | grep net)" != '' ];then
    sleep 1
fi

#echo  "$SCANIMAGE $OPT" 
$SCANIMAGE $OPT

if [ ! -e "$OUTPUT" ];then
   sleep 1
   $SCANIMAGE $OPT
fi

tiff2pdf -n -o "$OUTPUT_PDF" "$OUTPUT"

rm -f "$OUTPUT"
