import sys, time, os, argparse

class TinyDB:

	def __init__(self, dimensions = 3072, parse_args = True):
		self.parser = argparse.ArgumentParser()
		self.parser.add_argument("--db", required = True)
		self.parser.add_argument("-v", action = 'store_true')
		self.parser.add_argument("--dimensions", type=int, default = dimensions)
		if parse_args:
			self.parse_args()

	def arg_parser(self):
		return self.parser

	def parse_args(self):
		rp = self.parser.parse_args()
		self.verbose = rp.v
		self.dimensions = rp.dimensions
		self.dbname = rp.db
		return rp

	def status_msg(self, n, fpos, fsiz):
		mb_read = float(fpos) / 1024 / 1024
		mb_siz = float(fsiz) / 1024 / 1024
		dt = time.time() - self.starttime
		mb_per_sec = mb_read / dt
		mb_left = mb_siz - mb_read
		eta_sec = mb_left / mb_per_sec
		print >> sys.stderr, n, "%.2f MB/s, %.1f minutes left" % (mb_per_sec, eta_sec / 60)

	def chunks(self):
		self.f = open(self.dbname)
		self.cnt = 0
		self.starttime = time.time()
		while True:
			data = self.f.read(self.dim())
			if len(data) != self.dim():
				break
			self.cnt += 1
			if self.verbose and self.cnt % 10000 == 0:
				self.status_msg(self.cnt, self.f.tell(), os.path.getsize(self.dbname))
			yield data
		self.f.close()

	def at(self, idx):
		with open(self.dbname) as f:
			f.seek(idx * self.dim())
			data = f.read(self.dim())
			if len(data) != self.dim():
				return None
			return data

	def count(self):
		return self.cnt

	def dim(self):
		return self.dimensions
	
	def rows(self):
		return os.path.getsize(self.dbname) / self.dim()

