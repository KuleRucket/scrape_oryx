#!/usr/bin/env Rscript
#' @title scrape_oryx
#' @description A simple R script for extracting tabular data from Oryx's
#'   excellent post detailing materiel lost by all sides in the Russian
#'   invasion of Ukraine
#' @details Oryx's post is here: https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-equipment.html # nolint
#' @author Daniel Scarnecchia
#'
#' When is breaks, try these:file
#' rm -rf ./outputfiles/log/ ./renv/library/
#' rm -rf ~/.cache/R

# Setup
if (Sys.info()["sysname"] == "Linux") {
  Sys.setenv(R_INSTALL_STAGED = FALSE)
  print("Setting Staged Install to False")
}

# Activate renv project
source("renv/activate.R")

library(renv)
renv::restore(prompt = FALSE)
library(rvest)
library(tidyr)
library(lubridate)
library(tibble)
library(stringr)
library(readr)
options(readr.show_col_types = FALSE)
library(dplyr)
library(logger)

source("R/functions.R")
source("R/totals_by_type.R")
source("R/daily_count.R")

log_info("starting")

russia_url <- "https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-equipment.html" # nolint
ukraine_url <- "https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-ukrainian.html" # nolint

log_info("updating daily_count.csv")
daily_count <- daily_count() |>
  readr::write_csv(file = "outputfiles/daily_count.csv")

log_info("done")
