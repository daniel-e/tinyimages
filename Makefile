TIDB=$(TINYIMAGES)
DST=$(TINYIMAGES_OUT)

BIN_MEAN=bin/mean.py
BIN_COV=bin/cov.py
BIN_MOSAIC=bin/mosaic.py
BIN_TOY = bin/gen.py
BIN_DB2IMG = bin/db2img.py
BIN_KNN = bin/knn.py
SH_KNN = bin/knn.sh
SH_GENKNNIMAGES = bin/genknnimages.sh

SCRIPT_PCA=octave/pca.m
SCRIPT_MEANVIZ=octave/meanviz.m
SCRIPT_COVVIZ = octave/covviz.m

MEANIMG1=$(DST)/mean/mean.png
MEANIMG2=$(DST)/mean/mean_stretched.png

MOSAICFILE=$(DST)/mosaic/mosaic.jpg
MEANFILE=$(DST)/mean/mean.txt
COVFILE=$(DST)/cov/cov.mat
PCAFILE=$(DST)/pca/u.mat

KNN_OUT = $(DST)/knn/
KNN_IMAGES = data/images/

TOY_DIR = $(DST)/toy
TOY_DATASET = $(TOY_DIR)/imagedb.bin
TOY_TESTSET = $(TOY_DIR)/testdb.bin
TOY_LABELS = $(TOY_DIR)/labels.txt
TOY_TESTLABELS = $(TOY_DIR)/testlabels.txt
TOY_MOSAICFILE = $(TOY_DIR)/mosaic.jpg
TOY_KNNIMAGESOUT = $(TOY_DIR)/images/
TOY_KNNOUT = $(TOY_DIR)/knn
TOY_MEANFILE=$(TOY_DIR)/mean.txt
TOY_MEANIMG1=$(TOY_DIR)/mean.png
TOY_MEANIMG2=$(TOY_DIR)/mean_stretched.png
TOY_COVFILE=$(TOY_DIR)/cov.mat
TOY_COVIMG = $(TOY_DIR)/cov.png

# -----------------------------------------------------------------------------

all: check toy computeknn mosaic mean mean_viz cov pca

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

toy: check toydataset toymosaic toyknn toymean toycov

# TODO: cov, pca, knn on reduced data

toydataset: $(TOY_DATASET) $(TOY_TESTSET)

# we have 5 categories; generate 1.000 images per category
# = 15MB
$(TOY_DATASET): $(BIN_TOY)
	@echo "Creating toy dataset ..."
	@echo "  output: $(TOY_DATASET)"
	@echo "  output: $(TOY_LABELS)"
	@mkdir -p $(TOY_DIR)
	@$(BIN_TOY) -n 1000 --seed 1 -o $(TOY_DATASET) -l $(TOY_LABELS)

# we have 5 categories; generate 100 images per category
# = 1.5MB
$(TOY_TESTSET): $(BIN_TOY)
	@echo "Creating toy testset ..."
	@echo "  output: $(TOY_TESTSET)"
	@echo "  output: $(TOY_TESTLABELS)"
	@mkdir -p $(TOY_DIR)
	@$(BIN_TOY) -n 100 --seed 2 -o $(TOY_TESTSET) -l $(TOY_TESTLABELS)

toymosaic: $(TOY_MOSAICFILE)

$(TOY_MOSAICFILE): $(TOY_DATASET)
	@echo "Creating toy mosaic ..."
	@echo "  output: $(TOY_MOSAICFILE)"
	@echo "  input : $(TOY_DATASET)"
	@$(BIN_MOSAIC) --db $(TOY_DATASET) --seed 1 -c 20 -k 400 -o $(TOY_MOSAICFILE)

# ---

toyknn: toyknnimages toycomputeknn

toyknnimages: check $(SH_GENKNNIMAGES) $(TOY_TESTSET)
	@echo "Creating images for knn on toy dataset ..."
	@echo "  output: $(TOY_KNNIMAGESOUT)"
	@echo "  input : $(TOY_TESTSET)"
	@$(SH_GENKNNIMAGES) $(BIN_DB2IMG) 20 $(TOY_TESTSET) $(TOY_KNNIMAGESOUT)

toycomputeknn: check $(SH_KNN) $(BIN_KNN) $(BIN_MOSAIC) $(TOY_DATASET) toyknnimages
	@echo "Computing knn on toy dataset ..."
	@echo "  output: $(TOY_KNNOUT)"
	@echo "  input : $(TOY_KNNIMAGESOUT)"
	@echo "  input : $(TOY_DATASET)"
	@$(SH_KNN) $(BIN_KNN) $(BIN_MOSAIC) $(TOY_DATASET) $(TOY_KNNIMAGESOUT) $(TOY_KNNOUT)

# ---

toymean: check $(TOY_MEANFILE) toymean_viz

$(TOY_MEANFILE): $(BIN_MEAN) $(TOY_DATASET)
	@mkdir -p $(TOY_DIR)
	@echo "Computing mean of toy dataset ..."
	@echo "  output: $(TOY_MEANFILE)"
	@echo "  input : $(TOY_DATASET)"
	@$(BIN_MEAN) --db $(TOY_DATASET) -v -o $(TOY_MEANFILE)

toymean_viz: check $(TOY_MEANFILE) $(TOY_MEANIMG1) $(TOY_MEANIMG2)

$(TOY_MEANIMG1) $(TOY_MEANIMG2): $(TOY_MEANFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating mean image for toy dataset ..."
	@echo "  output: $(TOY_MEANIMG1)"
	@echo "  output: $(TOY_MEANIMG2)"
	@echo "  input : $(TOY_MEANFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(TOY_MEANFILE) $(TOY_MEANIMG1) $(TOY_MEANIMG2)

# ---

toycov: check $(TOY_COVFILE) $(BIN_COV) $(TOY_MEANFILE) toycovviz

$(TOY_COVFILE): $(BIN_COV) $(TOY_MEANFILE) $(TOY_DATASET)
	@echo "Computing covariance matrix of toy dataset ..."
	@echo "  output: $(TOY_COVFILE)"
	@echo "  input : $(TOY_MEANFILE)"
	@echo "  input : $(TOY_DATASET)"
	@$(BIN_COV) --db $(TOY_DATASET) -v --mean $(TOY_MEANFILE) -o $(TOY_COVFILE)

toycovviz: $(TOY_COVIMG)

$(TOY_COVIMG): $(TOY_COVFILE) $(SCRIPT_COVVIZ)
	@echo "Visualize covariance matrix of toy dataset ..."
	@echo "  output: $(TOY_COVIMG)"
	@echo "  input : $(TOY_COVFILE)"
	@octave -q $(SCRIPT_COVVIZ) $(TOY_COVFILE) $(TOY_COVIMG)

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
