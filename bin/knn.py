#!/usr/bin/env python

from tinydb import TinyDB
from imageprocessing import sobel
from parallel import process

import cv2, sys
import numpy as np

db = TinyDB(parse_args = False)
db.arg_parser().add_argument('--image', required = True)
db.arg_parser().add_argument('--filter', default = None)
args = db.parse_args()

d = 32

i = np.uint8(np.reshape(cv2.imread(args.image), (d, d, 3), order = 'F'))
b = list(i[:, :, 0].flatten(order = 'F'))
g = list(i[:, :, 1].flatten(order = 'F'))
r = list(i[:, :, 2].flatten(order = 'F'))
qi = np.reshape(r + g + b, (1, d * d * 3), order = 'F')

# ---------- filter -----------

# img is a flat array: [r, r, r, ..., g, g, g, ..., b, b, b, ...]
def do_filter(img, filt):
	if filt == None:
		return np.int32(img)
	i = np.reshape(img, (d, d, 3), order = 'F')
	r = i[:, :, 0]
	g = i[:, :, 1]
	b = i[:, :, 2]
	f = sobel(r, g, b)
	print f
	return np.int32(sobel(r, g, b).flatten(order = 'F'))

if args.filter == None:
	qi = do_filter(qi, None)
elif args.filter == 'raw,sobel':
	qi = do_filter(qi, sobel)
else:
	print >> sys.stderr, "unknown filter"
	sys.exit(1)

# -----------------------------

def compute_distance(datachunks):
	return [np.linalg.norm(qi - do_filter(np.fromstring(c, np.uint8), args.filter)) for c in datachunks]

c = 0
for result in process(db.groups(400), compute_distance):
	for k in result:
		print k, c
		c += 1
