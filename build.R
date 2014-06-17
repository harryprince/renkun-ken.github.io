library(knitr)
library(tools)
src <- list.files("_src",pattern = "*.Rmd",full.names = T)
files <- file_path_sans_ext(basename(src))
lapply(files,function(name) {
  src <- paste0("_src/",name,".Rmd")
  tar <- paste0("_posts/",name,".md")
  knit(src,tar)
})

