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

### Example Results

The results will be a zip file with a plot and the updated BuildingSync file with the derived model persisted into the reporting section

e.g.,

```xml
<auc:DerivedModel ID="bsyncr-DerivedModel-2">
  <auc:DerivedModelName>DerivedModel-bsyncr</auc:DerivedModelName>
  <auc:MeasuredScenarioID IDref="Scenario-Measured"/>
  <auc:Models>
    <auc:Model ID="bsyncr-Model-3">
      <auc:StartTimestamp>2018-01-19T00:00:00</auc:StartTimestamp>
      <auc:EndTimestamp>2020-06-16T00:00:00</auc:EndTimestamp>
      <auc:DerivedModelInputs>
        <auc:IntervalFrequency>Month</auc:IntervalFrequency>
        <auc:ResponseVariable>
          <auc:ResponseVariableName>Electricity</auc:ResponseVariableName>
          <auc:ResponseVariableUnits>kWh</auc:ResponseVariableUnits>
          <auc:ResponseVariableEndUse>All end uses</auc:ResponseVariableEndUse>
        </auc:ResponseVariable>
        <auc:ExplanatoryVariables>
          <auc:ExplanatoryVariable>
            <auc:ExplanatoryVariableName>Drybulb Temperature</auc:ExplanatoryVariableName>
            <auc:ExplanatoryVariableUnits>Fahrenheit, F</auc:ExplanatoryVariableUnits>
          </auc:ExplanatoryVariable>
        </auc:ExplanatoryVariables>
      </auc:DerivedModelInputs>
      <auc:DerivedModelCoefficients>
        <auc:Guideline14Model>
          <auc:ModelType>2 parameter simple linear regression</auc:ModelType>
          <auc:Intercept>281152.481344513</auc:Intercept>
          <auc:Beta1>822.58243910445</auc:Beta1>
        </auc:Guideline14Model>
      </auc:DerivedModelCoefficients>
      <auc:DerivedModelPerformance>
        <auc:RSquared>0.6861739</auc:RSquared>
        <auc:CVRMSE>8.15</auc:CVRMSE>
        <auc:NDBE>0.00</auc:NDBE>
        <auc:NMBE>0.00</auc:NMBE>
      </auc:DerivedModelPerformance>
    </auc:Model>
  </auc:Models>
</auc:DerivedModel>
```

## Releasing the stack

There are several steps to releasing all the dependent package of this stack.

1. Ensure that the `requirements.txt` file is pointing to a correct release of the Building/TestSuite package (repository).
2. For building the docker containers, make sure `install_r_packages.R` points to the correct releases of NMECR and RNOAA.
   - Verify that the `bsyncr` package install from GitHub is pointing to the correct release (or develop branch for testing).
   - These should be the same versions that are used in the `bsyncr` package.

Now follow the process for releasing:

- Create a branch with the prepared release change log.
- For testing purposes, make sure the versions of NMECR and RNOAA are correct in the `install_r_packages.R` script
- Create CHANGELOG in GitHub, paste in updates into CHANGELOG.md. Use semantic versioning for the next version.
- Run `pre-commit` locally
- Format the R files
- Open `bysync-server.Rproj` in RStudio
- In RStudio, format all the R files by running the following commands in RStudio

```R
install.packages("styler")
styler::style_dir()
```

- Merge release prep PR to develop
- Test as needed
- To release, from the command line merge latest develop into latest main: `git merge --ff-only origin develop`. This will point the HEAD of main to latest develop. Then push the main branch to GitHub with `git push`, which may require a developer with elevated privileges to push to main.
- Back on GitHub create a new tag in GitHub against main and copy the change log notes into the tag description.
- Tag on GitHub, copy over the correct version (format vX.Y.Z) and CHANGELOG content.
