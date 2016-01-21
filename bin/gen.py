#!/usr/bin/env python

import cv2, random, argparse, sys
import numpy as np

WIDTH = 64
HEIGHT = 64
random.seed(1)

parser = argparse.ArgumentParser()
parser.add_argument("-n", type = int, required = True) # number of instances for each class
parser.add_argument("-o", required = True) # output file
parser.add_argument("-l", required = True) # labels
args = parser.parse_args()

def newimg():
	# some noise
	c = [random.randint(150, 255) for i in range(WIDTH * HEIGHT * 3)]
	r = np.reshape(np.array(c, np.uint8), (HEIGHT, WIDTH, 3), np.uint8).copy()
	return r

def color():
	# BGR
	c = [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 0), (255, 0, 255), (255, 255, 0)]
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

functions = [circle, line1, line2, rect, triangle]
f = open(args.o, "w")
fl = open(args.l, "w")
for i in xrange(args.n):
	for l, fcn in enumerate(functions):
		img = newimg()
		img = fcn(img)
		img = cv2.resize(img, (32, 32))
		b = img[:, :, 0]
		g = img[:, :, 1]
		r = img[:, :, 2]
		img[:, :, 0], img[:, :, 2] = r.copy(), b.copy()
		data = [chr(j) for j in np.reshape(img, (1, 32 * 32 * 3), order = 'F').flatten()]
		f.write("".join(data))
		print >> fl, l
		#cv2.imshow('test', img)
		#cv2.waitKey()

