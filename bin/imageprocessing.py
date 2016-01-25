import math, cv2, unittest, os
import numpy as np

sx = np.array([[1, 0, -1], [2, 0, -2], [1, 0, -1]])
sy = np.array([[1, 2, 1], [0, 0, 0], [-1, -2, -1]])

def fold(a, b):
	return sum([i * j for i, j in zip(iter(a.flatten()), iter(b.flatten()))])

def sobel(r, g, b):
	w = r.shape[1]
	h = r.shape[0]
	c = 0.21 * r + 0.72 * g + 0.07 * b
	d = np.zeros((h, w), np.float64)
	for y in range(1, h - 1):
		for x in range(1, w - 1):
			rx = fold(sx, c[y-1:y+2, x-1:x+2])
			ry = fold(sy, c[y-1:y+2, x-1:x+2])
			d[y, x] = int(math.sqrt(rx * rx + ry * ry))
	return d

# -----------------------------------------------------------------------------

def read_rgb_image(filename):
	img = cv2.imread(filename)
	assert(img.dtype == 'uint8')
	assert(img.shape[2] == 3) # check that this is an RGB image
	h = img.shape[0]
	w = img.shape[1]
	b = img[:, :, 0]
	r = img[:, :, 2]
	img[:, :, 0], img[:, :, 2] = r.copy(), b.copy()
	return img

def write_rgb_image(filename, img):
	assert(img.dtype == 'uint8')
	assert(img.shape[2] == 3)
	i = img.copy()
	r = i[:, :, 0]
	b = i[:, :, 2]
	i[:, :, 0], i[:, :, 2] = b.copy(), r.copy()
	cv2.imwrite(filename, i)

# return: [r, r, r, ..., g, g, g, ..., b, b, b, ...]
def flatten_rgb_image(img):
	assert(img.dtype == 'uint8')
	assert(img.shape[2] == 3)  # color channels
	# order = 'C' seems to be the default for appending
	return np.append(np.append(img[:, :, 0].flatten(), img[:, :, 1]), img[:, :, 2])

def unflatten_rgb_image(arr, w, h):
	assert(arr.dtype == 'uint8')
	r = np.reshape(arr[:w * h], (h, w), order = 'C')
	g = np.reshape(arr[w * h:2 * w * h], (h, w), order = 'C')
	b = np.reshape(arr[2 * w * h:], (h, w), order = 'C')
	z = np.zeros((h, w, 3), np.uint8)
	z[:, :, 0] = r
	z[:, :, 1] = g
	z[:, :, 2] = b
	return z

# -----------------------------------------------------------------------------

class TestImageProcessing(unittest.TestCase):

	def gen_test_img(self):
		img = np.zeros((64, 32, 3), np.uint8)  # h = 64, w = 32
		for i in range(64):
			for x in range(32):
				img[i, x, i % 3] = 255
		return img
		
	def test_write_rgb_image(self):
		img = self.gen_test_img()
		try:
			os.unlink("/tmp/test_write_rgb_image.png")
		except:
			pass
		write_rgb_image("/tmp/test_write_rgb_image.png", img)

	def test_read_rgb_image(self):
		self.test_write_rgb_image()
		t = self.gen_test_img();
		img = read_rgb_image("/tmp/test_write_rgb_image.png")
		self.assertEqual(img[0, 0, 0], 255)
		self.assertEqual(img[0, 0, 1], 0)
		self.assertEqual(img[0, 0, 2], 0)
		self.assertEqual(img[1, 0, 0], 0)
		self.assertEqual(img[1, 0, 1], 255)
		self.assertEqual(img[1, 0, 2], 0)
		self.assertEqual(img[2, 0, 0], 0)
		self.assertEqual(img[2, 0, 1], 0)
		self.assertEqual(img[2, 0, 2], 255)
		self.assertTrue(np.equal(img, t).all())

	def test_flatten_rgb_image(self):
		img = self.gen_test_img()
		f = flatten_rgb_image(img)
		self.assertEqual(f.shape, (64 * 32 * 3,))  # h = 64, w = 32

		self.assertEqual(f[0], 255) # red component of pixel (x = 0, y = 0)
		self.assertEqual(f[1], 255) # red component of pixel (1,0)
		self.assertEqual(f[31], 255) # red component of pixel (31, 0)
		self.assertEqual(f[32], 0) # red component of pixel (0, 1)

		self.assertEqual(f[2048], 0) # green component of pixel (0, 0)
		self.assertEqual(f[2048 + 31], 0) # green component of pixel (31, 0)
		self.assertEqual(f[2048 + 32], 255) # green component of pixel (1, 0)

		self.assertEqual(f[4096], 0) # blue component of pixel (0, 0)
		self.assertEqual(f[4096 + 32], 0) # blue component of pixel (1, 0)
		self.assertEqual(f[4096 + 64], 255) # blue component of pixel (2, 0)

	def test_unflatten_rgb_image(self):
		img = self.gen_test_img()
		f = flatten_rgb_image(img).copy()
		i = unflatten_rgb_image(f, 32, 64)
		self.assertTrue(np.equal(img, i).all())

if __name__ == '__main__':
	unittest.main()

