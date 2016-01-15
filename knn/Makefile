MOSAICBIN=../bin/mosaic.py
DST=outputs

all: $(DST)/mosaic.jpg $(DST)/images_small $(DST)/scores $(DST)/summary.pdf

# create mosaic image from random tinydb
$(DST)/mosaic.jpg: $(MOSAICBIN)
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@mkdir -p $(DST)
	$(MOSAICBIN) --db $(TINYIMAGES) -o $(DST)/mosaic.jpg -c 20 --seed 123

# create thumbs
$(DST)/images_small: resize.sh
	@echo Resizing images...
	@./resize.sh $(DST)

# compute nearest neighbors
$(DST)/scores: knn.sh knn.py
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@echo Computing nearest neighbors...
	@./knn.sh $(DST)

# summary of results
$(DST)/summary.pdf: summary.sh
	@echo Creating summary.
	@./summary.sh $(DST)

clean:
	rm -rf $(DST)
