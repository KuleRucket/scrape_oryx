#' daily_count
#' @description Accrues data to the dataset daily_count by referencing and updating a baseline table, and appending a date to new observations.
#'
#' @return
#' @export
#'
#' @examples
daily_count <- function() {
  count_cols <- c("destroyed", "abandoned", "captured", "damaged", "type_total")

  # The baseline only stores raw counts; diffs are recomputed on every run
  baseline <- readr::read_csv("inputfiles/daily_count_baseline.csv") %>%
    dplyr::select(country, equipment_type, dplyr::all_of(count_cols), date_recorded) %>%
    dplyr::mutate(equipment_type = clean_equipment_type(equipment_type))

  today_total <- totals_by_type() %>%
    dplyr::mutate(date_recorded = as.Date(today()))

  check <- today_total %>%
    dplyr::anti_join(baseline, by = c("country", "equipment_type", count_cols))

  combined <- baseline %>%
    dplyr::bind_rows(check) %>%
    dplyr::distinct(country, equipment_type, date_recorded, .keep_all = TRUE) %>%
    dplyr::arrange(country, equipment_type, date_recorded)

  if (nrow(check) > 0) {
    combined %>% readr::write_csv("inputfiles/daily_count_baseline.csv")
  }

  combined %>%
    dplyr::group_by(country, equipment_type) %>%
    dplyr::mutate(dplyr::across(dplyr::all_of(count_cols), ~ .x - dplyr::lag(.x), .names = "{.col}_diff")) %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("_diff"), ~ tidyr::replace_na(.x, 0))) %>%
    dplyr::ungroup()
}