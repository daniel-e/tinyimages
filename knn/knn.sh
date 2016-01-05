#!/bin/bash

set -e

export DSTDIR=$1

if [ -z $TINYIMAGES ]; then
	echo "You have to set the TINYIMAGES environment variable."
	exit 1
fi

export DST=scores

function computeknn {
	f=$1
	echo "$f" "->" "$DSTDIR/$DST/$f"
	./knn.py --db $TINYIMAGES -v $DSTDIR/images_small/$f | sort -g -S 2G | head -n 10000 > $DSTDIR/$DST/$f
}

export -f computeknn

rm -rf $DSTDIR/$DST
mkdir -p $DSTDIR/$DST
ls $DSTDIR/images_small/ | xargs -P4 -n1 -I {} bash -c 'computeknn {}'
