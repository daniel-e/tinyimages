#!/usr/bin/env python

import argparse
from imageprocessing import read_rgb_image, write_rgb_image, gray_as_rgb, sobel_scipy, rgb_as_gray, sobel

p = argparse.ArgumentParser()
p.add_argument('-i', required = True)
p.add_argument('-o', required = True)
p.add_argument('-f', required = True)
args = p.parse_args()

i = read_rgb_image(args.i)
o = None

if args.f == 'sobel':
	o = gray_as_rgb(sobel(i))
elif args.f == 'gray':
	o = gray_as_rgb(rgb_as_gray(i))
else:
	raise Exception('unknown filter')

write_rgb_image(args.o, o)
