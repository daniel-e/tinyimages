COVBIN=../bin/cov.py
DST=$(TINYIMAGES_OUT)/cov/
MEANFILE=../data/mean.txt

all: check $(DST)/cov.mat

check:
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@if [ -z $(TINYIMAGES_OUT) ]; then echo "Please set the TINYIMAGES_OUT environment variable"; exit 1; fi
	@mkdir -p $(DST)

$(DST)/cov.mat: $(COVBIN) $(MEANFILE)
	$(COVBIN) --db $(TINYIMAGES) -v --mean $(MEANFILE) -o $(DST)/cov.mat

clean:
	rm -rf $(DST)
