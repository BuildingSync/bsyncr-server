# bsyncr server
A light HTTP wrapper around the bsyncr R package.

## Setup
```bash
# build the image (it takes a while to install the R packages)
docker build -t bsyncr_server:latest .

# run the server container
docker run -p 5000:5000 -v $(pwd):/usr/src/app bsyncr_server:latest
```
