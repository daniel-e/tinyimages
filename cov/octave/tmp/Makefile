TXTBIN=../../bin/tinydb2txt.py
DST=outputs

all: example

example: $(DST)/20000.txt.gz viz.m
	octave -q viz.m

$(DST)/20000.txt.gz: $(TXTBIN)
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@mkdir -p $(DST)
	$(TXTBIN) --db $(TINYIMAGES) -v -n 20000 | gzip > $(DST)/20000.txt.tmp.gz
	@mv $(DST)/20000.txt.tmp.gz $(DST)/20000.txt.gz

clean:
	rm -rf $(DST)
