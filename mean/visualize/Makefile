MEANBIN=../bin/mean.py

all: mean viz

mean:
	make -C ..

viz: mean
	@mkdir -p outputs
	octave -q viz.m

clean:
	rm -rf outputs
