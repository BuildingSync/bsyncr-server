# bsyncr server
A light HTTP wrapper around the bsyncr R package.

## Setup
```bash
# build the image (it takes a while to install the R packages)
docker build -t bsyncr_server:latest .

# run the server container
# note that the NOAA_TOKEN is required, you can get one here:
# https://www.ncdc.noaa.gov/cdo-web/token
docker run -p 5000:5000 -v $(pwd):/usr/src/app -e NOAA_TOKEN=YOUR_TOKEN_HERE bsyncr_server:latest
```
