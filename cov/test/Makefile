MEANBIN=../../bin/mean.py
COVBIN=../../bin/cov.py
DST=$(TINYIMAGES_OUT)/tests/cov

all: check test

check:
	mkdir -p $(DST)
	make -C .. check

clean:
	rm -f $(DST)

test: $(DST)/cov.mat $(DST)/data.txt oct_cov.m
	octave -q oct_cov.m $(DST)/data.txt $(DST)/cov.mat

$(DST)/cov.mat: $(MEANBIN) $(COVBIN) $(DST)/data.bin $(DST)/mean.txt
	$(COVBIN) --db $(DST)/data.bin --rows 1000 --mean $(DST)/mean.txt -o $(DST)/cov.mat

$(DST)/data.bin: create_test_set.py
	./create_test_set.py $(DST)

$(DST)/data.txt: create_test_set.py
	./create_test_set.py $(DST)

$(DST)/mean.txt: $(MEANBIN) $(DST)/data.bin
	$(MEANBIN) --db $(DST)/data.bin -o $(DST)/mean.txt


viz: oct_vizcov.m $(DST)/cov.mat
	octave -q oct_vizcov.m $(DST)/cov.mat








