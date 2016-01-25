#!/usr/bin/env python

import argparse, cv2, sys
from imageprocessing import sobel, read_rgb_image

import scipy

p = argparse.ArgumentParser()
p.add_argument('-i', required = True)
p.add_argument('-o', required = True)
args = p.parse_args()

k = read_rgb_image(args.i)
sys.exit(0)

img = cv2.imread(args.i)  # BGR image
b = img[:, :, 0]
g = img[:, :, 1]
r = img[:, :, 2]
res = sobel(r, g, b)
cv2.imwrite(args.o, res)
