# BuildingSync®, Copyright (c) Alliance for Sustainable Energy, LLC, and other contributors.
# See also https://github.com/BuildingSync/bsyncr-server/blob/main/LICENSE.txt


# Install required packages if not already installed
required_packages <- c(
  "remotes", "crayon", "dplyr", "tidyr", "crul", "xml2", "testthat", "anytime","lubridate", "segmented", "xts", "zoo", "ggplot2", "scales", "XML", "rappdirs", "gridExtra", "isdparser", "geonames", "hoardr", "data.table"
)

cat("Checking and installing required packages...\n")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
}

library('remotes')
# RNOAA for weather data
remotes::install_github('ropensci/rnoaa@v1.4.0', upgrade='never')

# NMECR from kW Engineering
remotes::install_github('kW-Labs/nmecr@v1.0.17', upgrade='never')

# TODO: Release version of bsyncr and link to the tag.
remotes::install_github('BuildingSync/bsyncr', ref='develop', upgrade='never')

library(rnoaa)
rnoaa::ghcnd_stations()
