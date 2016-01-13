all: data.bin data.txt out_mean_py.txt out_mean_octave.txt test

data.bin: create_test_set.py
	./create_test_set.py

data.txt: create_test_set.py
	./create_test_set.py

out_mean_py.txt: ../mean2.py data.bin
	../mean2.py --db data.bin -v > out_mean_py.txt

out_mean_octave.txt: data.txt oct_mean.m
	octave -q oct_mean.m

test: out_mean_py.txt out_mean_octave.txt
	./cmp.py

clean:
	rm -f data.bin data.txt out_mean_octave.txt out_mean_py.txt
