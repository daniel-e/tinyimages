#!/bin/bash

DB2IMG=$1
NIMAGES=$2
TINYDB=$3
DSTDIR=$4

mkdir -p $DSTDIR

n=$(($NIMAGES - 1))
for i in $(seq 0 $n); do
	OUT=$DSTDIR/$i.png
	if [ $TINYDB -nt $OUT ] || [ $DB2IMG -nt $OUT ]; then
		echo $OUT
		$DB2IMG --db $TINYDB -i $i -o $OUT
	fi
done
