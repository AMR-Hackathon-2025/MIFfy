library(tidyverse)

print_usage <- function() {
  cat("Usage: Rscript annotation_merging.R <bakta.tsv> <blast.hits.tsv> <output.file>\n")
  cat("  <bakta.tsv>  - Path to .tsv file from bakta\n")
  cat("  <blast.hits.txt> - Path to text file output from blast\n")
  cat("  <output.file> - Path to output file\n")
  quit(status = 1)
}


args <- commandArgs(trailingOnly = TRUE)
# Check argument length
if (length(args) != 3) {
  cat("Error: Incorrect number of arguments.\n")
  print_usage()
}


# function to process Bakta hits
read_IS_annotations <- function(path) {
  my.input <- read.csv(path, sep="\t", comment.char="#", check.names = F, header=F, col.names = c("Sequence Id","Type","Start","Stop","Strand","Locus Tag","Gene","Product","DbXrefs"))
  my.input.tnp <- my.input %>%
    mutate(is.tnp = ifelse(grepl("tnp", Gene), "tnp","other")) %>%
    mutate(has.attl = ifelse(grepl("attI", Product), "attI","other"))  
  return(my.input.tnp)
}

# function to process blastn hits against integrons
read_blast_hits <- function(path) {
  my.input <- read.csv(path, sep="\t", comment.char="#", check.names = F, header=F, col.names = c("qseqid","sseqid","pident","length","mismatch","qstart","qend","sstart","send","evalue","bitscore","qseq"))
  return(my.input)
}

# function to combine hits
create_search_hits <- function(bakta.path, blast.path, output.path) {
  bakta.data <- read_IS_annotations(bakta.path) %>%
    select(-is.tnp)
  blast.data <- read_blast_hits(blast.path)
  blast.data <- blast.data %>% 
    mutate(attl_qseq = qseq) %>%
    group_by(qseqid) %>% mutate(count=n()) %>% arrange(bitscore) %>% distinct(qseqid, .keep_all = T) %>%
    select(qseqid, sseqid, length, attl_qseq)
  combined.data <- left_join(bakta.data, blast.data, by=c("Sequence Id"="qseqid"))
  #return(bakta.data)
  #return(blast.data)
  return(combined.data)
}

# function to output data to file
write_file <- function(bakta.path, blast.path, output.path) {
  processed.file <- create_search_hits(bakta.file, blast.file, output.file)
  write.csv(processed.file, file=output.path, row.names = F, quote=F)
}

bakta.file <- args[1]
blast.file <- args[2]
output.file <- args[3]

write_file(bakta.file, blast.file, output.file)


