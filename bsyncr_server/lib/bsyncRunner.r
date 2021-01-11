#! /usr/bin/Rscript

library("nmecr")
library("bsyncr")
library("rjson")

run_analysis <- function(bsync_filepath, model_type) {
  baseline_scenario_id <- "Scenario-bsyncr"
  bsync_doc <- xml2::read_xml(bsync_filepath) %>%
    bsyncr::bs_stub_scenarios(linked_building_id = "My-Fav-Building", baseline_id = baseline_scenario_id)

  baseline_xpath <- sprintf("//auc:Scenario[@ID = '%s']", baseline_scenario_id)
  sc_baseline <- xml2::xml_find_first(bsync_doc, baseline_xpath)
  not_used <- sc_baseline %>% bsyncr::bs_stub_derived_model(dm_id = "DerivedModel-bsyncr",
                                                            dm_period = "Baseline",
                                                            sc_type = "Current Building")

  b_df <- bsyncr::bs_parse_nmecr_df(bsync_doc, insert_weather_data=TRUE)

  if (model_type == "SLR") {
    model <- nmecr::model_with_SLR(b_df,
                                   nmecr::assign_model_inputs(regression_type = "SLR"))
  } else if (model_type == "3PC") {
    model <- nmecr::model_with_CP(b_df,
                                  nmecr::assign_model_inputs(regression_type = "3PC"))
  } else if (model_type == "3PH") {
    model <- nmecr::model_with_CP(b_df,
                                  nmecr::assign_model_inputs(regression_type = "3PH"))
  } else if (model_type == "4P") {
    model <- nmecr::model_with_CP(b_df,
                                  nmecr::assign_model_inputs(regression_type = "4P"))
  } else {
    stop('Invalid model_type')
  }

  # add model to bsync tree
  bs_gen_dm_nmecr(nmecr_baseline_model = model,
                  x = bsync_doc)

  return(list("bsync_doc"=bsync_doc, "model"=model))
}

# setup
args <- commandArgs(trailingOnly=TRUE)
if (length(args) != 3) {
  print('USAGE:')
  print('Rscript bsyncRunner.r bsync_input model_type output_directory')
  print('  bsync_input: path to input file')
  print('  model_type: type of model to fit')
  print('  output_directory: directory to output files')
  stop("Invalid arguments to script. See usage")
}
bsync_filepath <- args[1]
model_type <- args[2]
output_dir <- args[3]
output_xml <- paste(output_dir, "result.xml", sep="/")
output_plot <- paste(output_dir, "plot.png", sep="/")
err_filename <- paste(output_dir, "error.json", sep="/")

NOAA_TOKEN <- Sys.getenv('NOAA_TOKEN')
if (NOAA_TOKEN == "") {
  stop("Missing NOAA token env var: NOAA_TOKEN")
}
options(noaakey=NOAA_TOKEN)

tryCatch({
  # run analysis
  analysis_result <- run_analysis(bsync_filepath, model_type)
  bsync_doc <- analysis_result$bsync_doc
  model <- analysis_result$model

  # save the updated bsync doc
  xml2::write_xml(bsync_doc, output_xml)

  # save the plot
  model_df <- model$training_data %>%
    tidyr::gather(key = "variable", value = "value", c("eload", "model_fit"))

  ggplot2::ggplot(model_df, aes(x = temp, y = value)) +
    geom_point(aes(color = variable), data=model_df[model_df$variable == "eload",]) +
    geom_line(aes(color = variable), data=model_df[model_df$variable == "model_fit",], size = 1) +
    xlab("Temperature") +
    scale_y_continuous(name = "Energy Data & Model Fit (kWh)", labels = scales::comma) +
    theme_minimal() +
    theme(legend.position = "bottom") +
    theme(legend.title = element_blank())

  ggsave(output_plot)
}, error = function(e) {
  print(e)
  err <- list(message=e$message)
  write(rjson::toJSON(err), err_filename)
  quit(status=1)
})
