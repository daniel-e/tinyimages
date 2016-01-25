#!/usr/bin/env python

from tinydb import TinyDB
from imageprocessing import sobel, read_rgb_image, flatten_rgb_image
from parallel import process

import cv2, sys
import numpy as np

db = TinyDB(parse_args = False)
db.arg_parser().add_argument('--image', required = True)
db.arg_parser().add_argument('--filter', default = None)
args = db.parse_args()

d = 32

qi = flatten_rgb_image(read_rgb_image(args.image))

# ---------- filter -----------

def do_filter(arr, filt):
	if filt == None:
		return np.int32(arr)
	return np.uint32(flatten_rgb_image(sobel(unflatten_rgb_image(arr))))

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
