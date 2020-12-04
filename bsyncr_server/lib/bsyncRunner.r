#! /usr/bin/Rscript

library("nmecr")
library("bsyncr")

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
# sc_reporting <- xml2::xml_find_first(bsync_doc, reporting_xpath)
# not_used <- sc_reporting %>% bsyncr::bs_stub_derived_model(dm_id = "DerivedModel-Reporting",
#                                                            dm_period = "Reporting",
#                                                            sc_type = "Package of Measures")

start_dt <- "03/01/2012 00:00"
end_dt <- "02/28/2013 23:59"
data_int <- "Daily"
b_df <- nmecr::create_dataframe(eload_data = nmecr::eload,
                                temp_data = nmecr::temp,
                                start_date = start_dt,
                                end_date = end_dt,
                                convert_to_data_interval = data_int)
SLR_model <- nmecr::model_with_SLR(b_df,
                                   nmecr::assign_model_inputs(regression_type = "SLR"))

not_used <- bs_gen_dm_nmecr(nmecr_baseline_model = SLR_model,
                            x = bsync_doc)

if (!dir.exists("output") ) {
  dir.create("output")
}
not_used <- xml2::write_xml(bsync_doc, "output/test1.xml")
