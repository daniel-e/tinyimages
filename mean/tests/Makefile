MEANBIN=../../bin/mean.py

all: test

test: out_mean_py.txt out_mean_octave.txt
	./cmp.py

data.bin: create_test_set.py
	./create_test_set.py

data.txt: create_test_set.py
	./create_test_set.py

out_mean_py.txt: $(MEANBIN) data.bin
	$(MEANBIN) --db data.bin -v > out_mean_py.txt.tmp
	@mv out_mean_py.txt.tmp out_mean_py.txt

out_mean_octave.txt: data.txt oct_mean.m
	octave -q oct_mean.m

clean:
	rm -f data.bin data.txt out_mean_octave.txt out_mean_py.txt *.tmp
