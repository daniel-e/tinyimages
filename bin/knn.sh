#!/bin/bash

SCRIPTNAME=$0
BINKNN=$1
BINMOSAIC=$2
TINYIMAGES=$3
IMAGES=$4
OUTDIR=$5
SCOREDIR=$OUTDIR/scores/
SMALL=$OUTDIR/small_images/
MOSAICBIN=bin/mosaic.py

mkdir -p $SCOREDIR
mkdir -p $SMALL

export SCRIPTNAME
export BINKNN
export TINYIMAGES
export SCOREDIR
export IMAGES
export SMALL

function computeknn {
	IMG=$1
	BIGIMG=$IMAGES/$IMG
	SMALLIMG=$SMALL/$IMG
	
	if [ $BIGIMG -nt $SMALLIMG ] || [ $BINKNN -nt $SMALLIMG ] || [ $SCRIPTNAME -nt $SMALLIMG ]; then
		echo $SMALLIMG
		convert -resize '32x32!' $BIGIMG $SMALLIMG
		$BINKNN --db $TINYIMAGES -v --image $SMALLIMG | sort -g -S 1G | head -n 10000 > $SCOREDIR/$IMG.score
		touch $SCOREDIR/.last-update
	fi
}

export -f computeknn

ls $IMAGES/ | xargs -P4 -n1 -I {} bash -c 'computeknn {}'

# remove score files for which no image does exist
for i in `ls $SCOREDIR/`; do
	SCOREFILE=$i
	IMGFILE=$IMAGES/$(echo $i | sed -e 's/.score//g')
	if [ ! -e $IMGFILE ]; then
		echo "rm $SCOREDIR/$SCOREFILE"
		rm $SCOREDIR/$SCOREFILE
	fi
done

# create a summary as a pdf
if [ $SCOREDIR/.last-update -nt $OUTDIR/summary.pdf ]; then
	echo "Creating summary..."
	# remove directory so that old images are removed
	rm -rf $OUTDIR/summary_images/
	mkdir -p $OUTDIR/summary_images/
	c=0
	for i in `ls $SCOREDIR/`; do
		SCOREFILE=$SCOREDIR/$i
		IMGFILE=$IMAGES/$(echo $i | sed -e s/.score//g)
		echo $SCOREFILE $IMGFILE
		o=`printf "%05d" $c`
		cat $SCOREFILE | head -n 100 | awk '{print $2}' | xargs $BINMOSAIC --db $TINYIMAGES -o $OUTDIR/summary_images/$o.result.jpg
		cp $IMGFILE $OUTDIR/summary_images/$o.query.jpg
		c=$((c+1))
	done
	convert $OUTDIR/summary_images/*.jpg $OUTDIR/summary.pdf
fi

