#! /bin/bash
#set +o noclobber
#
#   $1 = scanner device
#   $2 = friendly name
#

resolution=300  # 100|150|200|300|400|600|1200|2400|4800|9600
papersize="letter"   # letter, legal, a4
mode="24bit Color[Fast]"  # Black & White|Gray[Error Diffusion]|True Gray|24bit Color|24bit Color[Fast]

logging="> /var/log/" 2>&1

if [[ $INTR == "true" ]]; then
    logging="> /var/log/scanner.log 2>&1"
else
    logging=""
fi

# if [[ $1 == "" ]]; then
#     device="brother4:net1;dev0"
# else
#     device=$1
# fi

device="brother4:net1;dev0"

[[ $INTR == "true" ]] && echo "Device ID: $device" "$logging"

#[[ $2 == "" ]] && INTR="true"

case $papersize in 
    "letter") w=215.9; h=279.4 ;;
    "a4") w=210; h=297 ;;
    "legal") w=215.9; h=355.6 ;;
esac

sleep  0.1

filename=/scans/$(date +%F | sed s/-//g)$(date +%T | sed s/://g)
mkdir -p $filename

[[ $INTR == "true" ]] && echo "Acquiring image(s) ..." "$logging"

scanadf --device-name "$device" --resolution "$resolution" --mode "$mode" -x $w -y $h -o "$filename"/image_%04d "$logging"

[[ $INTR == "true" ]] && echo "Converting to PDF ..." "$logging"

for pnmfile in $filename/*; do
   pnmtops -dpi=$resolution -equalpixels "$pnmfile"  > "$pnmfile".ps 2> /dev/null
done

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -sOutputFile="$filename"/tmp.pdf $(ls "$filename"/*.ps) "$logging"

[[ $INTR == "true" ]] && echo "OCRing PDF ..." "$logging"

ocrmypdf --rotate-pages --deskew "$filename"/tmp.pdf "$filename".pdf "$logging"

[[ $INTR == "true" ]] && echo "Cleaning up ..." "$logging"

rm -rf $filename "$logging"

[[ $INTR == "true" ]] && echo "Done." "$logging"
