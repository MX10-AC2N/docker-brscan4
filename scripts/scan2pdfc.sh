#! /bin/bash
#set +o noclobber
#
#   $1 = scanner device
#   $2 = friendly name
#

resolution=150  # 100|150|200|300|400|600|1200|2400|4800|9600
papersize="letter"   # letter, legal, a4
mode="24bit Color[Fast]"  # Black & White|Gray[Error Diffusion]|True Gray|24bit Color|24bit Color[Fast]

if [[ $1 == "" ]]; then
    device="brother4:net1;dev0"
else
    device=$1
fi
[[ $2 == "" ]] && INTR="true"

case $papersize in 
    "letter") w=215.9; h=279.4 ;;
    "a4") w=210; h=297 ;;
    "legal") w=215.9; h=355.6 ;;
esac

sleep  0.01

filename=/scans/$(date +%F | sed s/-//g)$(date +%T | sed s/://g)
mkdir -p $filename

[[ $INTR == "true" ]] && echo "Acquiring image(s) ..."

scanadf --device-name "$device" --resolution "$resolution" --mode "$mode" -x $w -y $h -o"$filename"/image_%04d > /dev/null 2>&1

[[ $INTR == "true" ]] && echo "Converting to PDF ..."

for pnmfile in $filename/*; do
   pnmtops -dpi=$resolution -equalpixels "$pnmfile"  > "$pnmfile".ps 2> /dev/null
done

gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$filename"/tmp.pdf $(ls "$filename"/*.ps) 

[[ $INTR == "true" ]] && echo "OCRing PDF ..."

ocrmypdf --rotate-pages --deskew "$filename"/tmp.pdf "$filename".pdf

[[ $INTR == "true" ]] && echo "Cleaning up ..."

rm -rf $filename

[[ $INTR == "true" ]] && echo "Done."
