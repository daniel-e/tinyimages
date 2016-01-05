#!/usr/bin/env python

import sys, cv2, argparse, os, random
import numpy as np

def mosaic(f, pos, cols):
	n = 32
	rows = int(len(pos) / cols) + (0 if len(pos) % cols == 0 else 1)
	m = np.uint8(np.zeros((rows * n, cols * n, 3)))

	for k, i in enumerate(pos):
		row = int(k / cols)
		col = k % cols
		f.seek(i * n * n * 3)
		d = np.reshape(np.fromstring(f.read(n * n * 3), np.uint8), (n, n, 3), order = 'F')
		m[row*n:row*n+n, col*n:col*n+n, :] = d
	return m

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("--db", required = True)
parser.add_argument("-o", required = True)
parser.add_argument("-n", type = int, default = 100)
parser.add_argument("-c", type = int, default = 10)
parser.add_argument("--seed", type = int, default = -1)
parser.add_argument("idx", type = int, nargs = '*')
args = parser.parse_args()

# number of images
n = os.path.getsize(args.db) / (32 * 32 * 3)

# if no index is given select indexes at random
idx = []
if len(args.idx) > 0:
	idx = args.idx
else:
	# select a random set of n images
	if args.seed != -1:
		random.seed(args.seed)
	idx = random.sample(xrange(n), args.n)

m = mosaic(open(args.db), idx, args.c)

# swap color channels because OpenCV uses BGR instead of RGB
r = m[:, :, 0]
b = m[:, :, 2]
m[:, :, 0], m[:, :, 2] = b.copy(), r.copy()

# write image to file
cv2.imwrite(args.o, m)
