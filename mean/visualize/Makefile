MEANBIN=../../bin/mean.py
MEANFILE=$(TINYIMAGES_OUT)/mean/mean.txt
DST=$(TINYIMAGES_OUT)/mean/viz/

all: check viz

check:
	make -C .. check
viz:
	@mkdir -p $(DST)
	octave -q viz.m $(MEANFILE) $(DST)/mean.png $(DST)/mean_stretched.png

clean:
	rm -rf $(DST)
