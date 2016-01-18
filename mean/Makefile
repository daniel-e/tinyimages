MEANBIN=../bin/mean.py
DST=$(TINYIMAGES_OUT)/mean/
DB=$(TINYIMAGES)

all: check $(DST)/mean.txt

check:
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@if [ -z $(TINYIMAGES_OUT) ]; then echo "Please set the TINYIMAGES_OUT environment variable"; exit 1; fi

$(DST)/mean.txt: $(MEANBIN)
	@mkdir -p $(DST)
	$(MEANBIN) --db $(DB) -v -o $(DST)/mean.txt

clean:
	rm -rf $(DST)/mean.txt
