#! /usr/bin/Rscript

library("nmecr")
library("bsyncr")
library("rjson")

run_analysis <- function() {
  NOAA_TOKEN <- Sys.getenv('NOAA_TOKEN')
  if (NOAA_TOKEN == "") {
    stop("Missing NOAA token env var: NOAA_TOKEN")
  }
  options(noaakey=NOAA_TOKEN)

  args <- commandArgs(trailingOnly=TRUE)
  if (length(args) < 1) {
    stop("Missing file argument. Please pass a file path")
  }
  bsync_filepath <- args[1]

  schema_loc <- "https://raw.githubusercontent.com/BuildingSync/schema/feat/nmecr-support/BuildingSync.xsd"
  bsync_doc <- bsyncr::bs_gen_root_doc(schema_loc) %>%
    bsyncr::bs_stub_bldg(bldg_id = "My-Fav-Building") %>%
    bsyncr::bs_stub_scenarios(linked_building_id = "My-Fav-Building")


  baseline_xpath <- "//auc:Scenario[auc:ScenarioType/auc:CurrentBuilding/auc:CalculationMethod/auc:Measured]"
  reporting_xpath <- "//auc:Scenario[auc:ScenarioType/auc:PackageOfMeasures/auc:CalculationMethod/auc:Measured]"

  sc_baseline <- xml2::xml_find_first(bsync_doc, baseline_xpath)
  not_used <- sc_baseline %>% bsyncr::bs_stub_derived_model(dm_id = "DerivedModel-Baseline",
                                                            dm_period = "Baseline",
                                                            sc_type = "Current Building")

  b_df <- bsyncr::bs_parse_nmecr_df(xml2::read_xml(bsync_filepath))
  SLR_model <- nmecr::model_with_SLR(b_df,
                                    nmecr::assign_model_inputs(regression_type = "SLR"))

  not_used <- bs_gen_dm_nmecr(nmecr_baseline_model = SLR_model,
                              x = bsync_doc)

  return(bsync_doc)
}

output_filename <- "output/test1.xml"
err_filename <- "output/error.json"
tryCatch({
  # setup/cleanup
  if (!dir.exists("output") ) {
    dir.create("output")
  }
  if (file.exists(output_filename)) {
    file.remove(output_filename)
  }
  if (file.exists(err_filename)) {
    file.remove(err_filename)
  }

  # run analysis
  bsync_doc <- run_analysis()
  not_used <- xml2::write_xml(bsync_doc, output_filename)
}, error = function(e) {
  print(e)
  err <- list(message=e$message)
  write(rjson::toJSON(err), err_filename)
  quit(status=1)
})
