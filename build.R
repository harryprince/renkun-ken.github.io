library(knitr)
wd <- getwd()
dir <- "_posts/"
setwd(dir)
rmds <- list.files(".",pattern = "*.Rmd")
lapply(rmds,function(rmd) {
  knit(rmd)
})
setwd(wd)
