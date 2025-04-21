# Selenium start-up -------------------------------------------------------

# Start Selenium-controlled Firefox instance on a random open port
# Requires Firefox to be installed (other browsers are available)
driver <- RSelenium::rsDriver(
    browser = "firefox",
    chromever = NULL,
    port = httpuv::randomPort(),
    verbose = FALSE,
    check = FALSE
)

# Attach driver control to remDr
remDr <- driver[["client"]]

# Helper function to scroll to bottom of the current page
scroll_to_bottom <- function(driver) {
    last_height <- driver$executeScript("return document.body.scrollHeight")[[1]]
    repeat {
        driver$executeScript("window.scrollTo(0, document.body.scrollHeight);")
        Sys.sleep(3)
        new_height <- driver$executeScript("return document.body.scrollHeight")[[1]]
        if (new_height == last_height) {
            break
        }
        last_height <- new_height
    }
}

# Use Purrr::safely to check if an element exists without error if it does not
safe_findElement <- purrr::safely(function(driver, using, value) {
    driver$findElement(using = using, value = value)
})

safe_findElements <- purrr::safely(function(driver, using, value) {
    driver$findElements(using = using, value = value)
})
