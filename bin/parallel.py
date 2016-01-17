import multiprocessing, collections

def process(stream, fnc, procs = 4, qlen = 20):
	q = collections.deque()
	pool = multiprocessing.Pool(processes = procs)
	for i in stream:
		if len(q) >= qlen:
			yield q.popleft().get()
		q.append(pool.apply_async(fnc, (i,)))
	for i in q:
		yield i.get()
