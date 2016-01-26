#!/usr/bin/env python

from tinydb import TinyDB
from parallel import process
import imageprocessing as ip

import cv2, sys
import numpy as np

db = TinyDB(parse_args = False)
db.arg_parser().add_argument('--image', required = True)
db.arg_parser().add_argument('--filter', default = None)
db.arg_parser().add_argument('--filterout', default = None)
args = db.parse_args()

d = 32

qi = ip.flatten_rgb_image(ip.read_rgb_image(args.image))

# ---------- filter -----------

def do_filter(arr, filt):
	if filt == None:
		return arr
	elif filt == 'raw,sobel':
		i = ip.unflatten_rgb_image(arr, d, d)
		i = ip.sobel_scipy(i)
		i = ip.gray_as_rgb(i)
		return ip.flatten_rgb_image(i)
	raise Exception('unknown filter')

if args.filter == None:
	qi = np.int32(qi)
elif args.filter == 'raw,sobel':
	qi = np.int32(do_filter(qi, args.filter))
else:
	print >> sys.stderr, "unknown filter"
	sys.exit(1)

if args.filterout != None:
	ip.write_rgb_image(args.filterout, ip.unflatten_rgb_image(np.uint8(qi), d, d))

# -----------------------------

def compute_distance(datachunks):
	return [np.linalg.norm(qi - do_filter(np.fromstring(c, np.uint8), args.filter)) for c in datachunks]

c = 0
for result in process(db.groups(400), compute_distance):
	for k in result:
		print k, c
		c += 1
