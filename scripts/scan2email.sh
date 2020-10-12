#! /bin/bash
# scantoemail
#
SENDMAIL="$(which sendmail   2> /dev/null)"
if [ "$SENDMAIL" = '' ];then
    SENDMAIL="/usr/sbin/sendmail"
fi
if [ ! -e $SENDMAIL ];then
    echo "\sendmail is not available."
fi
#-----------------------
debug_log=''
sendmail_disable='no'
sendmail_log='0'
#-----------------------

FILENAME=brscan_skey.tif



mkdir -p ~/brscan
sleep 0.2

if [ -e ~/.brscan-skey/scantoemail.config ];then
   source ~/.brscan-skey/scantoemail.config
elif [ -e /etc/opt/brother/scanner/brscan-skey/scantoemail.config ];then
   source /etc/opt/brother/scanner/brscan-skey/scantoemail.config
fi



SCANIMAGE="/opt/brother/scanner/brscan-skey/skey-scanimage"
OUTPUT=/scans/brscan_"$(date +%Y-%m-%d-%H-%M-%S)".tif
OPT_OTHER=""



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

FLABEL='^FROM'
TLABEL='^TO'
CLABEL='^CC'
BLABEL='^BCC'
MLABEL='^MESSAGE'
SLABEL='^SUBJECT'

CONF=~/.brscan-skey/'brscan_mail.config'
if [ ! -e $CONF ];then
  CONF=/etc//opt/brother/scanner/brscan-skey/'brscan_mail.config'
fi

if [ "$DEBUG" = '' ];then
    DEBUG="$(grep 'DEBUG=1' $CONF)"
fi
if [ "$DEBUG" != '' ];then
  if [ "$sendmail_disable" = 'no' ];then
    sendmail_disable='verbose'
  fi
fi

FADR=$(grep "${FLABEL}="  $CONF | sed s/"${FLABEL}="//g) 
TADR=$(grep "${TLABEL}="  $CONF | sed s/"${TLABEL}="//g) 
CADR=$(grep "${CLABEL}="  $CONF | sed s/"${CLABEL}="//g) 
BADR=$(grep "${BLABEL}="  $CONF | sed s/"${BLABEL}="//g) 
MSGT=$(grep "${MLABEL}="  $CONF | sed s/"${MLABEL}="//g) 

if [ "$MSGT" != '' ];then
    MESG=$MSGT
    if [ ! -e "$MESG" ];then
	MESG=~/.brscan-skey/"$MSGT"
	if [ ! -e "$MESG" ];then
	    MESG=/etc//opt/brother/scanner/brscan-skey/"$MSGT"
	fi
    fi
else
    MESG="''"
fi
SUBJECT="$(grep ${SLABEL}=  $CONF | sed s/${SLABEL}=//g)" 

if [ "$3" != '' ];then
    #TADR="$(echo "$3" | sed -e s/:.*$//)"
    TADR=${3//":.*$"//}
fi


if [ "$TADR" = '' ] || [ ${#TADR} -gt 256 ];then
    echo "E-mail Address Error:"
    echo "   E-mail address setting is not valid."
    echo "   E-mail address is not defined or the setting"
    echo "   might be larger than 256 characters."
    exit 0;
fi

if [ "$FADR" = '' ];then
    FADR=$(whoami | sed s/" .*$"//g)
fi
if [ "$FADR" = '' ];then
    FADR="''"
fi

if [ "$FILENAME" = '' ];then
    FILENAME="''"
fi

command_line="$SENDMAIL -t $TADR"

case "$sendmail_log" in
    "0") email_debug_option='';;
    "1") email_debug_option='--debug-mode L';command_line="cat";;
    "2") email_debug_option='--debug-mode M';command_line="cat";;
    "4") email_debug_option='--debug-mode H';command_line="cat";;
    "5") email_debug_option='--debug-mode l';command_line="cat";;
    "6") email_debug_option='--debug-mode m';command_line="cat";;
    "3") email_debug_option='--debug-mode h';command_line="cat";;
    *  ) email_debug_option='';;
esac

if [ $sendmail_disable = 'yes' ];then
    command_line="head  -6";
elif [ $sendmail_disable = 'verbose' ];then
    command_line="cat";
fi

if [ -e "/opt/brother/scanner/brscan-skey/brscan_scantoemail" ];then
      if [ "$debug_log" != '' ];then
	log=/tmp/brother_brscanskey_scantoemail.log
	echo -----------------------------
	echo /opt/brother/scanner/brscan-skey/brscan_scantoemail \
	    -t "$TADR" \
	    -r "$FADR" \
	    -c "$CADR" \
	    -b "$BADR" \
	    -f "$FILENAME" \
	    -M "$MESG" \
	    -S "$SUBJECT" \
	    "$OUTPUT"  \|  $command_line
	echo "to  : $TADR"
	echo "from: $FADR"
	echo "cc  : $CC"
	echo "bcc : $BCC"
	echo "subject: $SUBJECT"
	echo "name: $FILENAME"
	echo "img : $OUTPUT"
	echo -----------------------------
     fi
     /opt/brother/scanner/brscan-skey/brscan_scantoemail \
	-t "$TADR" \
	-r "$FADR" \
	-c "$CADR" \
	-b "$BADR" \
	-f "$FILENAME" \
	-M "$MESG" \
	-S "$SUBJECT" \
        $email_debug_option \
	"$OUTPUT"    |  $command_line

     if [ "$log" != '' ];then
	touch $log
	echo "-----------------------------" ;\
	echo "to  : $TADR"                  ;\
	echo "from: $FADR"                  ;\
	echo "cc  : $CC"                    ;\
	echo "bcc : $BCC"                   ;\
	echo "subject: $SUBJECT"            ;\
	echo "name: $FILENAME"              ;\
	echo "mesg: $MESG"                  ;\
	echo "img : $OUTPUT"                >> $log
     fi

else
    echo ERROR: /opt/brother/scanner/brscan-skey/brscan_scantoemail \
	-t "$TADR" \
	-r "$FADR" \
	-f "$FILENAME" \
	-M "$MESG" \
	"$OUTPUT"  \| "$command_line"
fi

sleep 2
rm -f "$OUTPUT"

