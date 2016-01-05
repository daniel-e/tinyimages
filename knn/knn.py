#!/usr/bin/env python

import cv2, sys, time, os, collections, argparse, multiprocessing
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('--db', required = True)
parser.add_argument('-v', action = 'store_true')
parser.add_argument('filename', nargs = 1)
rp = parser.parse_args()

verbose = rp.v
f = open(rp.db)
d = 32

i = np.uint8(np.reshape(cv2.imread(rp.filename[0]), (d, d, 3), order = 'F'))
b = list(i[:, :, 0].flatten(order = 'F'))
g = list(i[:, :, 1].flatten(order = 'F'))
r = list(i[:, :, 2].flatten(order = 'F'))
qi = np.int32(np.reshape(r + g + b, (1, d * d * 3), order = 'F'))

start = time.time()

# -------------------------------------------------------------------

def read_stream():
	l = []
	while True:
		data = f.read(d * d * 3)
		if not data or len(data) != d * d * 3:
			break
		l.append(data)
		if len(l) >= 400:
			yield l
			l = []
	yield l

def status_msg(n, fpos, fsiz):
	if n % 10000 != 0:
		return
	mb_read = float(fpos) / 1024 / 1024
	mb_siz = float(fsiz) / 1024 / 1024
	dt = time.time() - start
	mb_per_sec = mb_read / dt
	mb_left = mb_siz - mb_read
	eta_sec = mb_left / mb_per_sec
	print >> sys.stderr, n, "%.2f MB/s, %.1f minutes left" % (mb_per_sec, eta_sec / 60)

def compute_distance(datachunks):
	return [np.linalg.norm(qi - np.fromstring(c, np.uint8)) for c in datachunks]

def process(stream):
	q = collections.deque()
	pool = multiprocessing.Pool(processes = 4)
	for i in stream:
		if len(q) >= 20:
			yield q.popleft().get()
		q.append(pool.apply_async(compute_distance, (i,)))
	for i in q:
		yield i.get()

c = 0
for j, result in enumerate(process(read_stream())):
	for k in result:
		print k, c
		c += 1
	if verbose:
		status_msg(j, f.tell(), os.path.getsize(rp.db))

if verbose:
	mb_read = float(f.tell()) / 1024 / 1024
	dt = time.time() - start
	print >> sys.stderr, "%.2f MB/s done" % (mb_read / dt), dt, "seconds"
