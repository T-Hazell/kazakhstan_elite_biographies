# Preamble ----
source("0. selenium_setup.R")

# Search pages ----
urls_full_list <- list()

urls_check_list <- list()

for (i in 1:301) {
  # Print index
  print(i)

  # Load page i
  current_url_i <- paste0(
    "https://online.zakon.kz/lawyer?m=s#text=%D0%BF%D0%B5%D1%80%D1%81%D0%BE%D0%BD%D0%B0%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F%20%D1%81%D0%BF%D1%80%D0%B0%D0%B2%D0%BA%D0%B0&source=1864&selsource=1864&baseId=1&free=1&page=",
    i
  )
  remDr$navigate(current_url_i)

  # Wait for page to load, then scrape links
  Sys.sleep(5)

  links <- remDr$findElements(using = "css selector", value = ".link_bu")
  link_urls_temp <- sapply(
    links,
    function(link) link$getElementAttribute("href")
  )

  # Confirm page has loaded properly + contains expected number of results
  urls_check_list <- append(urls_full_list, link_urls_temp)

  while (length(unique(urls_check_list)) - (i * 25) != 0 && i != 301) {
    print("Refreshing")

    # Reload and retry if not
    remDr$refresh()
    Sys.sleep(30)

    links <- remDr$findElements(using = "css selector", value = ".link_bu")
    link_urls_temp <-
      sapply(links, function(link) link$getElementAttribute("href"))

    urls_check_list <- append(urls_full_list, link_urls_temp)
  }

  # Append to full list
  urls_full_list <- append(urls_full_list, link_urls_temp)
  rlist::list.save(urls_full_list, "zakon/links/zakon_bio_links.RData")

  print(paste(
    "Iteration",
    i,
    "completed, with",
    length(urls_full_list),
    "links found in total.",
    sep = " "
  ))
}

remDr$close()
