#!/usr/bin/env python

from tinydb import TinyDB
import cv2, random
import numpy as np

WIDTH = 32
HEIGHT = 32
CHANNELS = 3

# returns the images from the tiny images dataset at the given positions
def images(tdb, pos, w, h, c):
	return [np.fromstring(tdb.at(i), np.uint8).reshape((w, h, c), order = 'F') for i in pos]

def mosaic(images, cols, m = None, col = 0):
	if len(images) == 0:
		return m
	i = images[0]
	h = i.shape[0]
	w = i.shape[1]
	emptyrows = np.zeros((h, w * cols, i.shape[2]), np.uint8)
	if m == None:
		return mosaic(images, cols, emptyrows, col)
	elif col == cols:
		return mosaic(images, cols, np.append(m, emptyrows, axis = 0), 0)
	else:
		m[-h:, col*w:col*w+w, :] = i
		return mosaic(images[1:], cols, m, col + 1)

tdb = TinyDB(dimensions = WIDTH * HEIGHT * CHANNELS, parse_args = False)
p = tdb.arg_parser()
p.add_argument("-o", required = True)
p.add_argument("-n", type = int, default = 100)
p.add_argument("-c", type = int, default = 10)
p.add_argument("--seed", type = int, default = -1)
p.add_argument("idx", type = int, nargs = '*')
args = tdb.parse_args()

# number of images
n = tdb.rows()

# if no index is given select indexes at random
idx = []
if len(args.idx) > 0:
	idx = args.idx
else:
	# select a random set of n images
	if args.seed != -1:
		random.seed(args.seed)
	idx = random.sample(xrange(n), args.n)

m = mosaic(images(tdb, idx, WIDTH, HEIGHT, CHANNELS), args.c)

# swap color channels because OpenCV uses BGR instead of RGB
r = m[:, :, 0]
b = m[:, :, 2]
m[:, :, 0], m[:, :, 2] = b.copy(), r.copy()

# write image to file
cv2.imwrite(args.o, m)
