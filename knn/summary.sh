#!/bin/bash

DST=$1

if [ -z $TINYIMAGES ]; then
	echo "You have to set the TINYIMAGES environment variable."
	exit 1
fi

rm -f $DST/summary.pdf
rm -rf $DST/summary_images

mkdir $DST/summary_images

c=0
for i in `ls images/`; do
	rm -f /tmp/img.jpg
	rm -f /tmp/p1.pdf 
	rm -f /tmp/p2.pdf

	echo $i
	o=`printf "%05d" $c`
	cat $DST/scores/$i | head -n 100 | awk '{print $2}' | xargs ./mosaic.py --db $TINYIMAGES -o $DST/summary_images/$o.1.jpg
	cp images/$i $DST/summary_images/$o.0.jpg
	c=$((c+1))
done

convert $DST/summary_images/*.jpg $DST/summary.pdf
