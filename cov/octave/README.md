Compute the covariance matrix of the first 5000 images of the tiny images dataset.

../../bin/db2txt.py --db $TINYIMAGES -v -n 5000 | gzip > 5000.txt.gz
octave -q viz.m
