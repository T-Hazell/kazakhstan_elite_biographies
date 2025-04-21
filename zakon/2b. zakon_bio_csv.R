# Read in data ----
file_list <- list.files("zakon/results/", full.names = TRUE)

ZakonReader <- function(file_name) {
    bio_i <- rvest::read_html(file_name, encoding = "UTF-8")

    # Extract individual's name
    name_i <- bio_i |>
        rvest::html_node(xpath = '//*[(@id = "VP2")]//span') |>
        rvest::html_text2() |>
        as.character()

    output_df <- tibble::tibble(
        name = name_i,
        bio_html = as.character(bio_i)
    ) |>
        dplyr::mutate(dplyr::across(
            dplyr::everything(),
            ~ ifelse(
                . == "character(0)" || . == "" || . == " ",
                NA_character_,
                .
            )
        ))

    return(output_df)
}

all_zakon <- purrr::map(file_list, ZakonReader, .progress = TRUE) |>
    dplyr::bind_rows()

readr::write_csv(all_zakon, "zakon/zakon_bios_date.csv")
