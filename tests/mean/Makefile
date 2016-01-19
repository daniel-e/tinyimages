MEANBIN=../../bin/mean.py
DST=$(TINYIMAGES_OUT)/tests/mean/

all: check test

check:
	make -C .. check

test: $(DST)/out_mean_py.txt $(DST)/out_mean_octave.txt cmp.py
	./cmp.py $(DST)

$(DST)/data.bin: create_test_set.py
	@mkdir -p $(DST)
	./create_test_set.py $(DST)

$(DST)/data.txt: create_test_set.py
	@mkdir -p $(DST)
	./create_test_set.py $(DST)

$(DST)/out_mean_py.txt: $(MEANBIN) $(DST)/data.bin
	$(MEANBIN) --db $(DST)/data.bin -v -o $(DST)/out_mean_py.txt

$(DST)/out_mean_octave.txt: $(DST)/data.txt oct_mean.m
	octave -q oct_mean.m $(DST)/data.txt $(DST)/out_mean_octave.txt

clean:
	rm -rf $(DST)
