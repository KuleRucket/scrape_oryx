#!/usr/bin/env Rscript
#' @title scrape_oryx
#' @description A simple R script for extracting tabular data from Oryx' excellent
#'   post detailing materiel lost by all sides in the [Russian invasion of
#'   Ukraine](https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-equipment.html).
#'
#'
#' @author Daniel Scarnecchia

# Setup
if (Sys.info()["sysname"] == "Linux") {
  Sys.setenv(R_INSTALL_STAGED = FALSE)
  print("Setting Staged Install to False")
}

message("Init libraries")

library(renv)
renv::restore(prompt = FALSE)
library(rvest)
library(dplyr)
library(tidyr)
library(lubridate)
library(purrr)
library(magrittr)
library(tibble)
library(stringr)
library(readr)
library(glue)
library(ggplot2)
library(scales)
library(ggthemes)

source("R/functions.R")
source("R/scrape_data.R")
source("R/totals_by_type.R")
source("R/daily_count.R")

message("starting")

russia_url <- "https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-equipment.html"
ukraine_url <- "https://www.oryxspioenkop.com/2022/02/attack-on-europe-documenting-ukrainian.html"

today <- format(Sys.Date(), "%Y-%m-%d")

message("updating totals_by_system.csv (this takes ages)")
totals_by_system <- create_data() %>%
  readr::write_csv(., file = glue::glue("outputfiles/totals_by_system.csv"))

message("updating totals_by_system_wide.csv")
totals_by_system_wide <- total_by_system_wide(totals_by_system) %>%
  readr::write_csv(.,
                   file = glue::glue("outputfiles/totals_by_system_wide.csv"))

message("updating total_by_type.csv")
total_by_type <- totals_by_type() %>%
  readr::write_csv(., file = glue::glue("outputfiles/totals_by_type.csv"))

message("updating daily_count.csv")
daily_count <- daily_count() %>%
  readr::write_csv(., file = "outputfiles/daily_count.csv")

message("quarto_render")

#rmarkdown::render("index.Rmd")
quarto::quarto_render("index.qmd")

message("done")
