# bsyncr server

A light HTTP wrapper around the `bsyncr` R package.

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
export NOAA_TOKEN=<YOUR_TOKEN>
docker run -p 5000:5000 -v $(pwd):/usr/src/app -e NOAA_TOKEN bsyncr_server:latest

# run the server along with SEED (assuming SEED is being run with docker-compose)
docker run \
  --network="seed_default" \
  --name="bsyncr-server" \
  -e NOAA_TOKEN \
  seedplatform/bsyncr-server:latest
```

## Running Example with Curl

To post via CURL for easy testing:

```bash
curl -X POST "http://localhost:8080/?model_type=SLR" \
  -F "file=@tests/data/ex_bsync.xml" \
  --max-time 120 \
  --output ./tests/slr_results.zip

curl -X POST "http://localhost:8080/?model_type=3PH" \
  -F "file=@tests/data/ex_bsync.xml" \
  --max-time 120 \
  --output ./tests/3ph_results.zip
```

## Running Example with Python

To post via python using requests:

```python
import requests

with open("tests/data/ex_bsync.xml", "rb") as file_:
    response = requests.request(
        method="POST",
        url="http://localhost:8080/",
        files=[("file", file_)],
        params={"model_type": "4P"},  # can be SLR, 3PC, 3PH, 4P
        timeout=60 * 2,  # timeout after two minutes
    )

print(response.status_code)
print(response.text)
```
