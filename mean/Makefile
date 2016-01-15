MEANBIN=../bin/mean.py
DST=outputs
all: $(DST)/mean.txt

$(DST)/mean.txt: $(MEANBIN)
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@mkdir -p $(DST)
	$(MEANBIN) --db $(TINYIMAGES) -v > $(DST)/mean.txt

clean:
	rm -rf $(DST)
