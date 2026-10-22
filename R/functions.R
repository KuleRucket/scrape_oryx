get_data <- function(url, elements) {
  rvest::read_html(url) |> rvest::html_elements(elements)
}

#' clean_equipment_type
#' @description Strips the counts from an Oryx section header, handling both
#'   the "Tanks (3264, of which ...)" and "Losses of ... - 14193, of which: ..."
#'   formats.
clean_equipment_type <- function(x) {
  x |>
    stringr::str_remove(" - \\d+, of which.*$") |>
    stringr::str_remove_all(" \\(.*\\)")
}
