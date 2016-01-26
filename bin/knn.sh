#!/bin/bash

SCRIPTNAME=$0
BINKNN=$1
BINMOSAIC=$2
TINYIMAGES=$3
IMAGES=$4
OUTDIR=$5
FILTER=$6
SCOREDIR=$OUTDIR/scores/
SMALL=$OUTDIR/small_images/

mkdir -p $SCOREDIR
mkdir -p $SMALL

export SCRIPTNAME
export BINKNN
export TINYIMAGES
export SCOREDIR
export IMAGES
export SMALL
export FILTER

function computeknn {
	IMG=$1
	BIGIMG=$IMAGES/$IMG
	SMALLIMG=$SMALL/$IMG
	FILTERED=$SMALL/filtered.$IMG.png

	if [ $BIGIMG -nt $SMALLIMG ] || [ $BINKNN -nt $SMALLIMG ] || [ $SCRIPTNAME -nt $SMALLIMG ]; then
		convert -resize '32x32!' $BIGIMG $SMALLIMG
		filter=""
		if [ ! -z $FILTER ]; then
			filter="--filter raw,sobel"
		fi
		echo $SMALLIMG $arg
		#echo $BINKNN --db $TINYIMAGES -v $filter --image $SMALLIMG
		$BINKNN --db $TINYIMAGES -v $filter --image $SMALLIMG --filterout $FILTERED | sort -g -S 1G | head -n 10000 > $SCOREDIR/$IMG.score
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
	echo "Creating summary ..."
	# remove directory so that old images are removed
	rm -rf $OUTDIR/summary_images/
	mkdir -p $OUTDIR/summary_images/
	c=0
	for i in `ls $SCOREDIR/`; do
		SCOREFILE=$SCOREDIR/$i
		IMGFILE=$IMAGES/$(echo $i | sed -e s/.score//g)
		FILTEREDFILE=$OUTDIR/small_images/filtered.$(echo $i | sed -e s/.score//g).png

		echo $SCOREFILE
		o=`printf "%05d" $c`
		c=$((c+1))

		# create the image of the results
		cat $SCOREFILE | head -n 100 | awk '{print $2}' | xargs $BINMOSAIC --db $TINYIMAGES -o $OUTDIR/summary_images/$o.result.png
		# query image
		cp $IMGFILE $OUTDIR/summary_images/$o.query.png
		
		if [ -e $FILTEREDFILE ]; then
			cp $FILTEREDFILE $OUTDIR/summary_images/$o.query.filtered.png
		fi
	done
	convert $OUTDIR/summary_images/*.png $OUTDIR/summary.pdf
	echo "done"
fi

