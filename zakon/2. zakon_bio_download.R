# Preamble ----
source("0. selenium_setup.R")

# Store archive copies of all biographies ----

# Load in saved list of urls
list_loaded <- rlist::list.load("zakon/links/zakon_bio_links.RData")

# Iterate through list and save to html
i <- 1
while (i <= length(list_loaded)) {
    # Print index
    print(i)

    # Load page i
    current_url_i <- list_loaded[[i]]
    remDr$navigate(current_url_i)

    # Scrape biography text as html
    bio_el <- remDr$findElements(using = "class name", value = "MsoNormalTable")

    if (length(bio_el) == 0) {
        print("No biography found")

        remDr$refresh()

        Sys.sleep(5)

        bio_el <- remDr$findElements(
            using = "class name",
            value = "MsoNormalTable"
        )

        if (length(bio_el) == 0) {
            print("No biography found after refresh")
            i <- i + 1
            next
        }
    }

    bio_html <- bio_el[[1]]$getElementAttribute("outerHTML")

    name_i <- bio_html[[1]] |>
        rvest::read_html(encoding = "UTF-8") |>
        rvest::html_node(xpath = '//*[(@id = "VP2")]//span') |>
        rvest::html_text2()

    print(name_i)

    save_name <- stringr::str_replace_all(name_i, "[^[:alnum:]]", "_")

    # Save to html file
    store_name <- paste0(
        "zakon/results/",
        save_name,
        "_archive_04122024.html"
    )

    xml2::write_html(rvest::read_html(bio_html[[1]]), store_name)

    list_loaded <- rlist::list.load(
        "zakon/links/zakon_bio_links.RData"
    )

    i <- i + 1
}

# Kill Selenium driver
remDr$close()
