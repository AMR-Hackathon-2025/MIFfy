#!/usr/bin/env Rscript

# Load necessary libraries
suppressPackageStartupMessages({
  library(optparse)
  library(dplyr)
  library(RColorBrewer)
})

# Define command line options
option_list <- list(
  make_option(c("-i", "--input_file"), type="character", help="Path to read1_from_mify.txt", metavar="FILE"),
  make_option(c("-g", "--gene_function_out"), type="character", help="Output path for gene_function.csv", metavar="FILE"),
  make_option(c("-c", "--colorcode_out"), type="character", help="Output path for function_colorcode.csv", metavar="FILE")
)

# Parse options
opt <- parse_args(OptionParser(option_list = option_list))

# Check required arguments
if (is.null(opt$input_file) || is.null(opt$gene_function_out) || is.null(opt$colorcode_out)) {
  stop("Missing one or more required arguments. Use -h for help.")
}

# Read the input file
read1_data <- read.delim(opt$input_file, stringsAsFactors = FALSE)

# Create gene_function.csv: extract Locus_Tag and AMR
gene_function <- read1_data %>%
  select(Locus_Tag, AMR) %>%
  distinct()

# Write gene_function.csv
write.csv(gene_function, opt$gene_function_out, row.names = FALSE)

# Generate function_colorcode.csv
unique_amrs <- unique(gene_function$AMR)
n_colors <- length(unique_amrs)

# Use enough colors from Set3 or extend with interpolation
colors <- colorRampPalette(brewer.pal(min(n_colors, 8), "Set3"))(n_colors)

function_colorcode <- data.frame(
  AMR = unique_amrs,
  ColorCode = colors,
  stringsAsFactors = FALSE
)

# Write function_colorcode.csv
write.csv(function_colorcode, opt$colorcode_out, row.names = FALSE)

message("✓ Files written successfully.")
