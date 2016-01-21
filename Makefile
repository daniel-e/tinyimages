TIDB=$(TINYIMAGES)
DST=$(TINYIMAGES_OUT)

BIN_MEAN=bin/mean.py
BIN_COV=bin/cov.py
BIN_MOSAIC=bin/mosaic.py
BIN_GEN = bin/gen.py
SH_KNN = bin/knn.sh
BIN_KNN = bin/knn.py

SCRIPT_PCA=octave/pca.m
SCRIPT_MEANVIZ=octave/meanviz.m

MEANIMG1=$(DST)/mean/mean.png
MEANIMG2=$(DST)/mean/mean_stretched.png

MOSAICFILE=$(DST)/mosaic/mosaic.jpg
MEANFILE=$(DST)/mean/mean.txt
COVFILE=$(DST)/cov/cov.mat
PCAFILE=$(DST)/pca/u.mat

KNN_OUT = $(DST)/knn/
KNN_IMAGES = data/images/

GEN_DIR = $(DST)/gen
GEN_DATASET = $(GEN_DIR)/imagedb.bin
GEN_TESTSET = $(GEN_DIR)/testdb.bin
GEN_LABELS = $(GEN_DIR)/labels.txt
GEN_TESTLABELS = $(GEN_DIR)/testlabels.txt
GEN_MOSAICFILE = $(GEN_DIR)/mosaic.jpg

# -----------------------------------------------------------------------------

all: check gen computeknn mosaic mean mean_viz cov pca

check:
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@if [ -z $(TINYIMAGES_OUT) ]; then echo "Please set the TINYIMAGES_OUT environment variable"; exit 1; fi

clean:
	rm -rf $(DST)

test:
	make -C tests

# -----------------------------------------------------------------------------
# SECTION FOR TOY DATASET
# -----------------------------------------------------------------------------

gen: check gendataset genmosaic genknn

gendataset: $(GEN_DATASET) $(GEN_TESTSET)

# we have 5 categories; generate 1.000 images per category
# = 15MB
$(GEN_DATASET): $(BIN_GEN)
	@echo "Creating toy dataset ..."
	@echo "  output: $(GEN_DATASET)"
	@echo "  output: $(GEN_LABELS)"
	@mkdir -p $(GEN_DIR)
	@$(BIN_GEN) -n 1000 -o $(GEN_DATASET) -l $(GEN_LABELS)

# we have 5 categories; generate 100 images per category
# = 1.5MB
$(GEN_TESTSET): $(BIN_GEN)
	@echo "Creating toy testset ..."
	@echo "  output: $(GEN_TESTSET)"
	@echo "  output: $(GEN_TESTLABELS)"
	@mkdir -p $(GEN_DIR)
	@$(BIN_GEN) -n 100 -o $(GEN_TESTSET) -l $(GEN_TESTLABELS)

genmosaic: $(GEN_MOSAICFILE)

$(GEN_MOSAICFILE): $(GEN_DATASET)
	@echo "Creating toy mosaic ..."
	@echo "  output: $(GEN_MOSAICFILE)"
	@echo "  input : $(GEN_DATASET)"
	@$(BIN_MOSAIC) --db $(GEN_DATASET) --seed 1 -c 20 -k 400 -o $(GEN_MOSAICFILE)

# ---

SH_GENKNNIMAGES = bin/genknnimages.sh
GEN_KNNIMAGESOUT = $(GEN_DIR)/images/

genknnimages: check $(SH_GENKNNIMAGES) $(GEN_TESTSET)
	@echo "Creating images for knn on toy dataset ..."
	@echo "  output: $(GEN_KNNIMAGESOUT)"
	@echo "  input : $(GEN_TESTSET)"
	@$(SH_GENKNNIMAGES) $(GEN_TESTSET) $(GEN_KNNIMAGESOUT)

TODO

# -----------------------------------------------------------------------------

computeknn: check $(SH_KNN) $(BIN_KNN) $(BIN_MOSAIC) $(TIDB)
	@echo "Computing knn ..."
	@echo "  output: $(KNN_OUT)"
	@echo "  input : $(KNN_IMAGES)"
	@$(SH_KNN) $(BIN_KNN) $(BIN_MOSAIC) $(TIDB) $(KNN_IMAGES) $(KNN_OUT)

# -----------------------------------------------------------------------------

mosaic: check $(MOSAICFILE)

$(MOSAICFILE): $(BIN_MOSAIC) $(TIDB)
	@mkdir -p $(DST)/mosaic
	@echo "Creating mosaic ..."
	@echo "  output: $(MOSAICFILE)"
	@echo "  input : $(TIDB)"
	@$(BIN_MOSAIC) --db $(TIDB) -o $(MOSAICFILE) -c 20 --seed 123

# -----------------------------------------------------------------------------

mean: check $(MEANFILE)

$(MEANFILE): $(BIN_MEAN) $(TIDB)
	@mkdir -p $(DST)/mean
	@echo "Computing mean ..."
	@echo "  output: $(MEANFILE)"
	@echo "  input : $(TIDB)"
	@$(BIN_MEAN) --db $(TIDB) -v -o $(MEANFILE)

mean_viz: check $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

$(MEANIMG1) $(MEANIMG2): $(MEANFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating mean image ..."
	@echo "  output: $(MEANIMG1)"
	@echo "  output: $(MEANIMG2)"
	@echo "  input : $(MEANFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

# -----------------------------------------------------------------------------

cov: check $(COVFILE)

$(COVFILE): $(BIN_COV) $(MEANFILE) $(TIDB)
	@mkdir -p $(DST)/cov
	@echo "Computing covariance matrix ..."
	@echo "  output: $(COVFILE)"
	@echo "  input : $(MEANFILE)"
	@echo "  input : $(TIDB)"
	@$(BIN_COV) --db $(TIDB) -v --mean $(MEANFILE) -o $(COVFILE)

# -----------------------------------------------------------------------------

pca: check $(PCAFILE)

$(PCAFILE): $(SCRIPT_PCA) $(COVFILE)
	@mkdir -p $(DST)/pca
	@echo "Computing PCA ..."
	@echo "  output: $(PCAFILE)"
	@echo "  input : $(COVFILE)"
	@octave -q $(SCRIPT_PCA) $(COVFILE) $(PCAFILE)

# TODO
