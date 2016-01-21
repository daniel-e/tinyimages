#!/usr/bin/env python

import cv2
import numpy as np

from tinydb import TinyDB

tdb = TinyDB(parse_args = None)
tdb.arg_parser().add_argument("-o", required = True)
tdb.arg_parser().add_argument("-i", type = int, required = True)
args = tdb.parse_args()

x = np.fromstring(tdb.at(args.i), np.uint8).reshape((32, 32, 3), order = 'F')
r = x[:, :, 0]
g = x[:, :, 1]
b = x[:, :, 2]
x[:, :, 0], x[:, :, 2] = b.copy(), r.copy()

cv2.imwrite(args.o, x)
