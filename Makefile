# -------------------------------------
# configuration
# -------------------------------------

TIDB=$(TINYIMAGES)
DST=$(TINYIMAGES_OUT)
VERBOSE=
#VERBOSE=-v

KNN_IMAGES = data/images/

# -------------------------------------
# executables and scripts
# -------------------------------------

BIN_MEAN=bin/mean.py
BIN_COV=bin/cov.py
BIN_MOSAIC=bin/mosaic.py
BIN_TOY = bin/gen.py
BIN_DB2IMG = bin/db2img.py
BIN_KNN = bin/knn.py
BIN_STD = bin/std.py
SH_KNN = bin/knn.sh
SH_TOYKNNIMAGES = bin/genknnimages.sh

SCRIPT_PCA=octave/pca.m
SCRIPT_MEANVIZ=octave/meanviz.m
SCRIPT_COVVIZ = octave/covviz.m

# -------------------------------------
# generated files
# -------------------------------------

MOSAICFILE=$(DST)/mosaic/mosaic.jpg
MEANFILE=$(DST)/mean/mean.txt
COVFILE=$(DST)/cov/cov.mat
PCAFILE=$(DST)/pca/u.mat
MEANIMG1=$(DST)/mean/mean.png
MEANIMG2=$(DST)/mean/mean_stretched.png
STDFILE = $(DST)/std/std.txt
STDIMG1 = $(DST)/std/std.png
STDIMG2 = $(DST)/std/std_stretched.png
KNN_OUT = $(DST)/knn/

# -------------------------------------
# toy dataset
# -------------------------------------

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
TOY_STDFILE = $(TOY_DIR)/std.txt
TOY_STDIMG1 = $(TOY_DIR)/std.png
TOY_STDIMG2 = $(TOY_DIR)/std_stretched.png

# -------------------------------------

TEST_COV = tests/cov.m

# -----------------------------------------------------------------------------

all: check toy computeknn mosaic mean mean_viz std std_viz cov pca

check:
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@if [ -z $(TINYIMAGES_OUT) ]; then echo "Please set the TINYIMAGES_OUT environment variable"; exit 1; fi

clean:
	rm -rf $(DST)

test: $(TEST_COV) $(TOY_DATASET) $(TOY_COVFILE)
	@octave -q $(TEST_COV) $(TOY_DATASET) $(TOY_COVFILE)

#TODO
#	make -C tests

# -----------------------------------------------------------------------------
# SECTION FOR TOY DATASET
# -----------------------------------------------------------------------------

toy: check toydataset toymosaic toyknn toymean toystd toycov

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

toyknnimages: check $(SH_TOYKNNIMAGES) $(TOY_TESTSET)
	@echo "Creating images for knn on toy dataset ..."
	@echo "  output: $(TOY_KNNIMAGESOUT)"
	@echo "  input : $(TOY_TESTSET)"
	@$(SH_TOYKNNIMAGES) $(BIN_DB2IMG) 20 $(TOY_TESTSET) $(TOY_KNNIMAGESOUT)

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
	@$(BIN_MEAN) --db $(TOY_DATASET) $(VERBOSE) -o $(TOY_MEANFILE)

toymean_viz: check $(TOY_MEANFILE) $(TOY_MEANIMG1) $(TOY_MEANIMG2)

$(TOY_MEANIMG1) $(TOY_MEANIMG2): $(TOY_MEANFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating mean image for toy dataset ..."
	@echo "  output: $(TOY_MEANIMG1)"
	@echo "  output: $(TOY_MEANIMG2)"
	@echo "  input : $(TOY_MEANFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(TOY_MEANFILE) $(TOY_MEANIMG1) $(TOY_MEANIMG2)

# ---

toystd: check $(TOY_STDFILE) $(TOY_MEANFILE) toystd_viz

$(TOY_STDFILE): $(BIN_STD) $(TOY_DATASET) $(TOYMEANFILE)
	@mkdir -p $(TOY_DIR)
	@echo "Computing standard deviation of toy dataset ..."
	@echo "  output: $(TOY_STDFILE)"
	@echo "  input : $(TOY_DATASET)"
	@echo "  input : $(TOY_MEANFILE)"
	@$(BIN_STD) --db $(TOY_DATASET) $(VERBOSE) --mean $(TOY_MEANFILE) -o $(TOY_STDFILE)
	
toystd_viz: check $(TOY_STDFILE) $(TOY_STDIMG1) $(TOY_STDIMG2)

$(TOY_STDIMG1) $(TOY_STDIMG2): $(TOY_STDFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating std image for toy dataset ..."
	@echo "  output: $(TOY_STDIMG1)"
	@echo "  output: $(TOY_STDIMG2)"
	@echo "  input : $(TOY_STDFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(TOY_STDFILE) $(TOY_STDIMG1) $(TOY_STDIMG2)

# ---

toycov: check $(TOY_COVFILE) $(BIN_COV) $(TOY_MEANFILE) $(TOY_STDFILE) toycovviz

$(TOY_COVFILE): $(BIN_COV) $(TOY_MEANFILE) $(TOY_STDFILE) $(TOY_DATASET)
	@echo "Computing covariance matrix of toy dataset ..."
	@echo "  output: $(TOY_COVFILE)"
	@echo "  input : $(TOY_MEANFILE)"
	@echo "  input : $(TOY_DATASET)"
	@echo "  input : $(TOY_STDFILE)"
	@$(BIN_COV) --db $(TOY_DATASET) $(VERBOSE) --std $(TOY_STDFILE) --mean $(TOY_MEANFILE) -o $(TOY_COVFILE)

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
	@$(BIN_MEAN) --db $(TIDB) $(VERBOSE) -o $(MEANFILE)

mean_viz: check $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

$(MEANIMG1) $(MEANIMG2): $(MEANFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating mean image ..."
	@echo "  output: $(MEANIMG1)"
	@echo "  output: $(MEANIMG2)"
	@echo "  input : $(MEANFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

# -----------------------------------------------------------------------------

std: check $(STDFILE) $(MEANFILE)

$(STDFILE): $(BIN_STD) $(TIDB) $(MEANFILE)
	@mkdir -p $(DST)/std
	@echo "Computing standard deviation ..."
	@echo "  output: $(STDFILE)"
	@echo "  input : $(TIDB)"
	@echo "  input : $(MEANFILE)"
	@$(BIN_STD) --db $(TIDB) $(VERBOSE) --mean $(MEANFILE) -o $(STDFILE)

std_viz: check $(STDFILE) $(STDIMG1) $(STDIMG2)

$(STDIMG1) $(STDIMG2): $(STDFILE) $(SCRIPT_MEANVIZ)
	@echo "Creating standard deviation image ..."
	@echo "  output: $(STDIMG1)"
	@echo "  output: $(STDIMG2)"
	@echo "  input : $(STDFILE)"
	@octave -q $(SCRIPT_MEANVIZ) $(STDFILE) $(STDIMG1) $(STDIMG2)

# -----------------------------------------------------------------------------

cov: check $(COVFILE)

$(COVFILE): $(BIN_COV) $(MEANFILE) $(TIDB) $(STDFILE)
	@mkdir -p $(DST)/cov
	@echo "Computing covariance matrix ..."
	@echo "  output: $(COVFILE)"
	@echo "  input : $(MEANFILE)"
	@echo "  input : $(STDFILE)"
	@echo "  input : $(TIDB)"
	@$(BIN_COV) --db $(TIDB) $(VERBOSE) --std $(STDFILE) --mean $(MEANFILE) -o $(COVFILE)

# -----------------------------------------------------------------------------

pca: check $(PCAFILE)

$(PCAFILE): $(SCRIPT_PCA) $(COVFILE)
	@mkdir -p $(DST)/pca
	@echo "Computing PCA ..."
	@echo "  output: $(PCAFILE)"
	@echo "  input : $(COVFILE)"
	@octave -q $(SCRIPT_PCA) $(COVFILE) $(PCAFILE)

# TODO
