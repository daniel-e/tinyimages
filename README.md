# User Stories

- [x] Search the nearest neighbours of the images stored in data/images/
  - [x] on raw pixel data
    - no image processing / feature scaling is done
    - no dimension reduciton is done
    - the Euclidean distance is computed on the raw pixel data
  - [ ] after applying the Sobel operator to the raw pixel data
  - [ ] after applying dimension reduction
    - [ ] on raw pixel data
    - [ ] after applying the Sobel operator to the raw pixel data

# Tasks

- [ ] Dimension reduction
  - [x] compute mean
  - [x] compute standard deviation
  - [x] compute covariance matrix
  - [ ] compute pca
    - [ ] plot S (from svd)
- [ ] Image processing
  - [ ] Sobel operator
    - [x] implement the Sobel operator
    - [ ] include the Sobel operator as a filter in the knn search

