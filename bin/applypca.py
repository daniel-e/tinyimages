#!/usr/bin/env python

from tinydb import TinyDB
from parallel import process

import numpy as np
import scipy.io as sio


db = TinyDB(parse_args = False)
# add additional parameters
db.arg_parser().add_argument("-k", type = int, required = True)
db.arg_parser().add_argument("--rows", type = int, default = 20000)
db.arg_parser().add_argument("-o", required = True)
db.arg_parser().add_argument("--umatrix", required = True)
args = db.parse_args()

# load umatrix

def compute(data):
	

with open(args.o, "w") as f:
	for r in process(db.groups(args.rows), compute):
		f.write(r)

x = rand(5000, 3);
y = (x(:,1) > 0.2) .* (x(:,1) < 0.8) .* (x(:,2) > 0.2) .* (x(:,2) < 0.8) .* (x(:,3) > 0.2) .* (x(:,3) < 0.8);
z = x(y == 0, :)
plot3(z(:,1), z(:,2),z(:,3), 'x', 'color', 'r');

