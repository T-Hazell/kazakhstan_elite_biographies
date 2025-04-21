if (!exists("all_zakon")) {
    source("3. zakon_structure.R")
}

zakon_filtered <- all_zakon |>
    dplyr::filter(!is.na(name) & !is.na(work_history)) |>
    dplyr::mutate(
        index = paste0("ZAK", dplyr::row_number())
    )

zakon_jobwise <- zakon_filtered |>
    dplyr::select(index, name, work_history) |>
    dplyr::mutate(
        work_history = stringr::str_squish(work_history),
        work_history = stringr::str_remove(
            work_history,
            "Трудовой стаж:\n·|Трудовой стаж: ·"
        )
    ) |>
    tidyr::separate_longer_delim(work_history, delim = "·") |>
    dplyr::mutate(
        work_history = stringr::str_squish(work_history)
    )
