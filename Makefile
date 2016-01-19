TIDB=$(TINYIMAGES)
DST=$(TINYIMAGES_OUT)

BIN_MEAN=bin/mean.py
BIN_COV=bin/cov.py

SCRIPT_PCA=octave/pca.m
SCRIPT_MEANVIZ=octave/meanviz.m

MEANIMG1=$(DST)/mean/mean.png
MEANIMG2=$(DST)/mean/mean_stretched.png

MEANFILE=$(DST)/mean/mean.txt
COVFILE=$(DST)/cov/cov.mat
PCAFILE=$(DST)/pca/u.mat

# -----------------------------------------------------------------------------

all: check mean mean_viz cov pca

check:
	@if [ -z $(TINYIMAGES) ]; then echo "Please set the TINYIMAGES environment variable"; exit 1; fi
	@if [ -z $(TINYIMAGES_OUT) ]; then echo "Please set the TINYIMAGES_OUT environment variable"; exit 1; fi

clean:
	rm -rf $(DST)

test:
	make -C tests

# -----------------------------------------------------------------------------

mean: $(MEANFILE)

$(MEANFILE): $(BIN_MEAN) $(TIDB)
	@mkdir -p $(DST)/mean
	$(BIN_MEAN) --db $(TIDB) -v -o $(MEANFILE)

mean_viz: $(MEANIMG1) $(MEANIMG2)

$(MEANIMG1): $(MEANFILE) $(SCRIPT_MEANVIZ)
	octave -q $(SCRIPT_MEANVIZ) $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

$(MEANIMG2): $(MEANFILE) $(SCRIPT_MEANVIZ)
	octave -q $(SCRIPT_MEANVIZ) $(MEANFILE) $(MEANIMG1) $(MEANIMG2)

# -----------------------------------------------------------------------------

cov: $(COVFILE)

$(COVFILE): $(BIN_COV) $(MEANFILE) $(TIDB)
	@mkdir -p $(DST)/cov
	$(BIN_COV) --db $(TIDB) -v --mean $(MEANFILE) -o $(COVFILE)

# -----------------------------------------------------------------------------

pca: $(PCAFILE)

$(PCAFILE): $(SCRIPT_PCA) $(COVFILE)
	@mkdir -p $(DST)/pca
	octave -q $(SCRIPT_PCA) $(COVFILE) $(PCAFILE)

# -----------------------------------------------------------------------------

