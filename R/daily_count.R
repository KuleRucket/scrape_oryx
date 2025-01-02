#' daily_count
#' @description Accrues data to the dataset daily_count by referencing and updating a baseline table, and appending a date to new observations.
#'
#' @return
#' @export
#'
#' @examples
daily_count <- function() {
  baseline <- readr::read_csv("inputfiles/daily_count_baseline.csv")

  today_total <- totals_by_type() %>%
    dplyr::mutate(date_recorded = as.Date(today()))

  check <- today_total %>%
    dplyr::anti_join(baseline, by = c("country", "equipment_type", "destroyed", "abandoned", "captured", "damaged", "type_total"))

  if (length(check) > 0) {
    baseline %>%
      dplyr::bind_rows(check) %>%
      dplyr::group_by(country, equipment_type) %>%
      dplyr::arrange(country, equipment_type, date_recorded) %>%
      readr::write_csv("inputfiles/daily_count_baseline.csv")

    running_count <- baseline %>%
      dplyr::bind_rows(check) %>%
      dplyr::group_by(country, equipment_type) %>%
      dplyr::arrange(country, equipment_type, date_recorded) %>%
      dplyr::mutate(dplyr::across(where(is.numeric), ~ .x - dplyr::lag(.x), .names = "{.col}_diff")) %>%
      dplyr::mutate(dplyr::across(where(is.numeric), ~ tidyr::replace_na(.x, 0))) %>%
      dplyr::distinct(country, equipment_type, date_recorded, .keep_all=TRUE)

    rm(check)

    return(running_count)
  } else {
    return(baseline)
  }
}