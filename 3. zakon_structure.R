# Read in data ----

file_list <- list.files("zakon-scraping/zakon-results", full.names = TRUE)

ZakonReader <- function(file_name) {
    bio_i <- rvest::read_html(file_name, encoding = "UTF-8")

    # Extract individual's name
    name_i <- bio_i |>
        rvest::html_node(xpath = '//*[(@id = "VP2")]//span') |>
        rvest::html_text2() |>
        as.character()

    # Extract work history section from biography
    work_hist <- bio_i |>
        rvest::html_table() |>
        _[[1]] |>
        dplyr::rename(information = X1) |>
        dplyr::select(information) |>
        dplyr::filter(stringr::str_starts(information, "Трудовой")) |>
        as.character()

    # Extract education section from biography
    education_i <- bio_i |>
        rvest::html_table() |>
        _[[1]] |>
        dplyr::rename(education_i = X1) |>
        dplyr::select(education_i) |>
        dplyr::filter(stringr::str_starts(education_i, "Образование")) |>
        as.character()

    # Extract higher degree section from biography
    higher_deg_i <- bio_i |>
        rvest::html_table() |>
        _[[1]] |>
        dplyr::rename(higher_deg_i = X1) |>
        dplyr::select(higher_deg_i) |>
        dplyr::filter(stringr::str_starts(higher_deg_i, "Научные звания")) |>
        as.character()

    # Extract date of birth from biography
    birth_date_i <- bio_i |>
        rvest::html_nodes(xpath = '//*[(@id = "VP5")]') |>
        rvest::html_text2() |>
        stringr::str_flatten(" ") |>
        stringr::str_extract(
            "\\b\\d\\d\\.\\d\\d\\.\\d\\d\\d\\d|\\b\\d\\d\\d\\d\\b"
        ) |>
        as.character()

    # Extract place of birth from biography
    birth_place_i <- bio_i |>
        rvest::html_nodes(xpath = '//*[(@id = "VP6")]') |>
        rvest::html_text2() |>
        stringr::str_flatten(" ") |>
        stringr::str_remove_all("Место рождения: ") |>
        as.character()

    output_df <- tibble::tibble(
        name = name_i,
        work_history = work_hist,
        education = education_i,
        higher_deg = higher_deg_i,
        birth_date = birth_date_i,
        birth_place = birth_place_i
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
