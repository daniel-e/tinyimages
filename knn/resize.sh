#!/bin/bash

DST=$1

rm -rf $DST/images_small
mkdir -p $DST/images_small
for i in `ls images/*`; do
	fn=`echo $i | cut -d/ -f2`
	echo $i "->" $fn
	convert -resize '32x32!' $i $DST/images_small/$fn
done
