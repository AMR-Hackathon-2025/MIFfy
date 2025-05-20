library(here)
library(rmarkdown)

here::i_am("bin/make_summaries.R")


args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 3) {
  stop("Too many arguments. Please specify *only* input directory, contig result tsv and desired outfile.")
}
if (length(args) < 3) {
  stop("Missing arguments. Please specify input directory, contig result tsv and desired outfile.")
}

input.dir <- args[1]
contig.results <- args[2]
outfile <- args[3]

rmarkdown::render(here("bin", "summaries.Rmd"),
                  output_format = "html_document",
                  output_file = outfile,
                  params = list("result_dir" = input.dir, "result_file"=contig.results))