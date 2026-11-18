# BuildingSync, Copyright (c) Alliance for Sustainable Energy, LLC, and other contributors.
# See also https://github.com/BuildingSync/bsyncr-server/blob/main/LICENSE.txt


# Use HTTPS CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install required packages if not already installed
required_packages <- c(
  "remotes", "crayon", "dplyr", "tidyr", "crul", "xml2", "testthat", "anytime", "lubridate", "segmented", "xts", "zoo", "ggplot2", "scales", "XML", "rappdirs", "gridExtra", "isdparser", "geonames", "hoardr", "data.table"
)

cat("Checking and installing required packages...\n")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(paste0("Installing: ", pkg, "\n"))
    install.packages(pkg)
  }
}

# Verify remotes installed successfully before proceeding
if (!requireNamespace("remotes", quietly = TRUE)) {
  stop("Failed to install 'remotes' package. Check network connectivity and CRAN mirror.")
}

library("remotes")
# RNOAA for weather data
remotes::install_github("ropensci/rnoaa@v1.4.0", upgrade = "never")

# NMECR from kW Engineering
remotes::install_github("kW-Labs/nmecr@v1.0.17", upgrade = "never")

# BSync package for reading/writing BuildingSync files for NMECR
remotes::install_github("BuildingSync/bsyncr@v0.2.0", upgrade = "never")

library(rnoaa)
rnoaa::ghcnd_stations()
