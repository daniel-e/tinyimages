#!/usr/bin/env python

import sys, time, os, argparse, itertools
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument("--db", required = True)
parser.add_argument("-v", action = 'store_true')
rp = parser.parse_args()

start = time.time()
chunk_size = 32 * 32 * 3
cnt = 0

def status_msg(n, fpos, fsiz):
	mb_read = float(fpos) / 1024 / 1024
	mb_siz = float(fsiz) / 1024 / 1024
	dt = time.time() - start
	mb_per_sec = mb_read / dt
	mb_left = mb_siz - mb_read
	eta_sec = mb_left / mb_per_sec
	print >> sys.stderr, n, "%.2f MB/s, %.1f minutes left" % (mb_per_sec, eta_sec / 60)

def chunks():
	global cnt
	f = open(rp.db)
	while True:
		if rp.v and cnt > 0 and cnt % 10000 == 0:
			status_msg(cnt, f.tell(), os.path.getsize(rp.db))
		data = f.read(chunk_size)
		if len(data) != chunk_size:
			break
		cnt += 1
		yield np.fromstring(data, np.uint8)

acc = reduce(lambda acc, c: acc + c, chunks(), np.zeros(chunk_size, np.int64))
acc = np.float64(acc) / cnt

print " ".join(["%f" % (i) for i in acc.flatten()])
