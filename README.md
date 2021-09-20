# bsyncr server
A light HTTP wrapper around the bsyncr R package.

## Setup

Pull the image from dockerhub or clone this repo and build it yourself:
```bash
# pull the image from dockerhub
docker pull seedplatform/bsyncr-server

# alternatively, build the image (it takes a while to install the R packages)
docker build -t bsyncr_server:latest .
```

Run the server. Note that the NOAA_TOKEN environment variable is required, you can get one here:
https://www.ncdc.noaa.gov/cdo-web/token
```bash
# run the server on localhost:5000
docker run -p 5000:5000 -v $(pwd):/usr/src/app -e NOAA_TOKEN=YOUR_TOKEN_HERE bsyncr_server:latest

# run the server along with SEED (assuming SEED is being run with docker-compose)
docker run \
  --network="seed_default" \
  --name="bsyncr-server" \
  -e NOAA_TOKEN=$NOAA_TOKEN \
  seedplatform/bsyncr-server:latest
```
