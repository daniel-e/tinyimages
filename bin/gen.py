#!/usr/bin/env python

from imageprocessing import flatten_rgb_image
from parallel import process

import cv2, random, argparse, sys
import numpy as np

WIDTH = 64
HEIGHT = 64

parser = argparse.ArgumentParser()
parser.add_argument("-n", type = int, required = True) # number of instances for each class
parser.add_argument("-o", required = True) # output file
parser.add_argument("-l", required = True) # labels
parser.add_argument("--seed", type = int, default = 1)
args = parser.parse_args()

random.seed(args.seed)

def newimg():
	# some noise
	x = np.random.rand(HEIGHT, WIDTH, 3) * 150 + 105
	return np.uint8(x).copy()

def color():
	# BGR
	c = [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0), (255, 0, 255), (0, 255, 255)]
	return random.choice(c)

def thick():
	return random.randint(1, 3)


def circle(img):
	cv2.circle(img, (WIDTH / 2, HEIGHT / 2), 26, color(), thickness = thick())
	return img

def line1(img):
	cv2.line(img, (4, 4), (WIDTH - 4, HEIGHT - 4), color(), thickness = thick())
	return img

def line2(img):
	cv2.line(img, (4, HEIGHT - 4), (WIDTH - 4, 4), color(), thickness = thick())
	return img

def rect(img):
	cv2.rectangle(img, (6, 6), (WIDTH - 6, HEIGHT - 6), color(), thickness = thick())
	return img

def triangle(img):
	c = color()
	t = thick()
	cv2.line(img, (WIDTH / 2, 6), (6, HEIGHT - 6), c, t)
	cv2.line(img, (6, HEIGHT - 6), (WIDTH - 6, HEIGHT - 6), c, t)
	cv2.line(img, (WIDTH - 6, HEIGHT - 6), (WIDTH / 2, 6), c, t)
	return img


def docreate(job):
	l, f = job
	img = cv2.resize(f(newimg()), (32, 32))
	return (l, "".join([chr(j) for j in flatten_rgb_image(img)]))

functions = [triangle, line1, line2, rect, circle]
f = open(args.o, "w")
fl = open(args.l, "w")

jobs = [(l, fcn) for l, fcn in enumerate(functions)] * args.n
for l, r in process(jobs, docreate):
	f.write(r)
	print >> fl, l
	#cv2.imshow('test', img)
	#cv2.waitKey()

