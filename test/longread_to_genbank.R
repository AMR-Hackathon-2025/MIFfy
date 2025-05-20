suppressPackageStartupMessages({
  library(optparse)
  library(dplyr)
  library(stringr)
  library(readr)
  library(Biostrings)
})

option_list <- list(
  make_option(c("-t", "--txt"), type = "character", help = "Annotation file (output.txt)", metavar = "file"),
  make_option(c("-f", "--fasta"), type = "character", help = "FASTA file (read.fasta)", metavar = "file"),
  make_option(c("-o", "--output"), type = "character", default = "read_output.gbk", help = "Output GenBank file", metavar = "file")
)

opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$txt) || is.null(opt$fasta)) {
  stop("Please provide both -t (txt) and -f (fasta) input files.")
}

cat("Reading annotations from:", opt$txt, "\n")
ann <- read_tsv(opt$txt, show_col_types = FALSE)

cat("Reading FASTA from:", opt$fasta, "\n")
read_seq <- readDNAStringSet(opt$fasta)
read_id <- names(read_seq)[1]
sequence <- as.character(read_seq[[1]])
seq_len <- nchar(sequence)

cat("Writing GenBank to:", opt$output, "\n")
sink(opt$output)

cat(sprintf("LOCUS       %s     %d bp    DNA     linear       %s\n", read_id, seq_len, format(Sys.Date(), "%d-%b-%Y")))
cat("DEFINITION  Long read GenBank generated from annotation fragments.\n")
cat(sprintf("ACCESSION   %s_001\n", read_id))
cat(sprintf("VERSION     %s_001.1\n", read_id))
cat("KEYWORDS    .\n")
cat("SOURCE      ", ann$Organism[1], "\n")
cat("  ORGANISM  ", ann$Organism[1], "\n")
cat("FEATURES             Location/Qualifiers\n")


for (i in seq_len(nrow(ann))) {
  row <- ann[i, ]
  cat(sprintf("     CDS             %d..%d\n", row$Start, row$End))
  cat(sprintf("                     /gene=\"%s\"\n", row$Gene_Annotation))
  cat(sprintf("                     /locus_tag=\"%s\"\n", row$Locus_Tag))
  cat(sprintf("                     /product=\"%s\"\n", row$CDS_Product))
  cat(sprintf("                     /protein_id=\"%s\"\n", row$CDS_Protein_ID))
  cat(sprintf("                     /codon_start=%s\n", row$CDS_Codon_Start))
  cat(sprintf("                     /translation=\"%s\"\n", row$CDS_Translation))
  cat(sprintf("                     /note=\"AMR class: %s\"\n", row$AMR_Class))
}


cat("ORIGIN\n")
wrapped <- strwrap(tolower(sequence), width = 60)
for (i in seq_along(wrapped)) {
  line_num <- (i - 1) * 60 + 1
  cat(sprintf("%9d %s\n", line_num, wrapped[i]))
}
cat("//\n")
sink()

cat("GenBank file created:", opt$output, "\n")






