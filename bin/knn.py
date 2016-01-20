#!/usr/bin/env python

from tinydb import TinyDB
from parallel import process

import cv2
import numpy as np

db = TinyDB(parse_args = False)
db.arg_parser().add_argument('--image', required = True)
args = db.parse_args()

d = 32

i = np.uint8(np.reshape(cv2.imread(args.image), (d, d, 3), order = 'F'))
b = list(i[:, :, 0].flatten(order = 'F'))
g = list(i[:, :, 1].flatten(order = 'F'))
r = list(i[:, :, 2].flatten(order = 'F'))
qi = np.int32(np.reshape(r + g + b, (1, d * d * 3), order = 'F'))

def compute_distance(datachunks):
	return [np.linalg.norm(qi - np.fromstring(c, np.uint8)) for c in datachunks]

c = 0
for result in process(db.groups(400), compute_distance):
	for k in result:
		print k, c
		c += 1
