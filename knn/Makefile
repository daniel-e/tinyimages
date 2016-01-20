DST=outputs

all: $(DST)/scores $(DST)/summary.pdf

# compute nearest neighbors
$(DST)/scores: knn.sh knn.py
	@echo Computing nearest neighbors...
	@./knn.sh $(DST)

# summary of results
$(DST)/summary.pdf: summary.sh
	@echo Creating summary.
	@./summary.sh $(DST)

clean:
	rm -rf $(DST)
