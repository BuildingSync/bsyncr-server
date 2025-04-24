# Install required packages if not already installed
required_packages <- c(
  "remotes", "crayon", "dplyr", "tidyr", "crul", "xml2", "testthat", "anytime","lubridate", "segmented", "xts", "zoo",
  "ggplot2", "scales", "XML", "rappdirs", "gridExtra", "isdparser", "geonames", "hoardr", "data.table"
)

cat("Checking and installing required packages...\n")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
}

library('remotes')
remotes::install_github('ropensci/rnoaa@v1.3.4', upgrade='never')
remotes::install_github('kW-Labs/nmecr@v1.0.17', upgrade='never')
# TODO: Release version of bsyncr and link to the tag.
remotes::install_github('BuildingSync/bsyncr', ref='update-nmecr-version-add-test', upgrade='never')

library(rnoaa)
rnoaa::ghcnd_stations()
