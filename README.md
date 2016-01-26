# User Stories

- [x] Search the nearest neighbours of the images stored in data/images/
  - [x] on raw pixel data
    - no image processing / feature scaling is done
    - no dimension reduciton is done
    - the Euclidean distance is computed on the raw pixel data
  - [ ] after applying the Sobel operator to the raw pixel data
    - [ ] on tiny images dataset
    - [x] on toy data
      - [ ] describe results
      - green pixel probelm
  - [ ] after applying dimension reduction via PCA
    - [ ] on raw pixel data
    - [ ] after applying the Sobel operator to the raw pixel data

# Tasks

- [ ] dimension reduction
  - [x] compute mean
  - [x] compute standard deviation
  - [x] compute covariance matrix
  - [ ] compute pca
    - [ ] plot S (from svd)
- [x] image processing
  - [x] Sobel operator
    - [x] implement the Sobel operator
    - [x] include the Sobel operator as a filter in the knn search
- [ ] visualize the filtered images in the knn summary report
    - [x] query image
    - [ ] query results
    - [ ] ensure that the filtered image that is shown really has been used by knn
- [ ] solve the green pixel problem
    - possible solutions
      - [x] user another weighting scheme, e.g. 0.3, 0.3, 0.3
        - does not work for toy dataset
        - no edges are found anymore (even on edges that are clearly visible)
      - [ ] compute the Sobel operator on each color channel

# Subtasks

# Changelog

- [x] clarify: why are there no edges for green lines after applying sobel
  - lines do disappear after image is converted into grayscale
    - the formular is: 0.21r + 0.72g + 0.07b
    - the green component is quite near to the noise -> green pixel problem
- [x] show filtered query image in the summary report
- [x] knn.py can write the filtered query image into a file
- [x] integrated sobel from scipy
- [x] improved performance of gen.py to generate toy dataset
- [x] compute knn with sobel filter enabled
- [x] created library imageprocessing.py for reading/writing images
