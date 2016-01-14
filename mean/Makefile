DST=outputs
all: $(DST)/mean.txt

$(DST)/mean.txt: mean.py
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@mkdir -p $(DST)
	./mean.py --db $(TINYIMAGES) -v > $(DST)/mean.txt

clean:
	rm -rf $(DST)
