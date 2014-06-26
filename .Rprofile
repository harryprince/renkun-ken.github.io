library(knitr)

build <- function() {
  lapply(list.files("_posts",pattern = "*.Rmd",full.names = T),function(file) {
    info <- file.info(file)

    # knitr::knit(file)
  })
}
