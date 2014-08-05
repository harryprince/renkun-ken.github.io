build <- function() {
  src <- list.files("_src",full.names = TRUE)
  posts <- list.files("_posts",full.names = TRUE)
  src.info <- file.info(src)["mtime"]
  src.info$path <- rownames(src.info)
  src.info$name <- tools::file_path_sans_ext(basename(src.info$path))
  rownames(src.info) <- NULL
  posts.info <- file.info(posts)["mtime"]
  posts.info$path <- rownames(posts.info)
  posts.info$name <- tools::file_path_sans_ext(basename(posts.info$path))
  rownames(posts.info) <- NULL
  common <- merge(src.info,posts.info,by = "name",all.x = TRUE)
  ids <- which((common$mtime.x > common$mtime.y) | is.na(common$mtime.y))
  lapply(ids, function(i) {
    input <- common[i,"path.x"]
    output <- sprintf("_posts/%s.md", common[i,"name"])
    knitr::knit(input,output)
  })
  message("All finished")
}
