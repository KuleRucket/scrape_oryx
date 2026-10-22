#' daily_count
#' @description Appends today's totals to the existing daily_count dataset
#'   when they differ from what's already recorded.
#'
#' @param path the daily_count csv to read from
#' @return a tibble
#' @export
daily_count <- function(path) {
  count_cols <- c("destroyed", "abandoned", "captured", "damaged", "type_total")

  # Drops the _diff columns older versions of this file carried
  baseline <- readr::read_csv(path) %>%
    dplyr::select(country, equipment_type, dplyr::all_of(count_cols), date_recorded) %>%
    dplyr::mutate(equipment_type = clean_equipment_type(equipment_type))

  today_total <- totals_by_type() %>%
    dplyr::mutate(date_recorded = as.Date(today()))

  check <- today_total %>%
    dplyr::anti_join(baseline, by = c("country", "equipment_type", count_cols))

  baseline %>%
    dplyr::bind_rows(check) %>%
    dplyr::distinct(country, equipment_type, date_recorded, .keep_all = TRUE) %>%
    dplyr::arrange(country, equipment_type, date_recorded)
}