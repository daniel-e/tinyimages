#!/usr/bin/env python

import argparse
from imageprocessing import read_rgb_image, write_rgb_image, gray_as_rgb, sobel_scipy

p = argparse.ArgumentParser()
p.add_argument('-i', required = True)
p.add_argument('-o', required = True)
args = p.parse_args()

write_rgb_image(args.o, gray_as_rgb(sobel_scipy(read_rgb_image(args.i))))
