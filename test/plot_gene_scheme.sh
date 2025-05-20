## Transform mify output to genbank format
Rscript longread_to_genbank.R -t read1_from_mify.txt -f read1.fasta -o read1.gbk
Rscript longread_to_genbank.R -t read2_from_mify.txt -f read2.fasta -o read2.gbk
## Generate colorcode for AMR class
Rscript generate_amr_annotations.R --input_file read1_from_mify.txt --gene_function_out gene_function.csv --colorcode_out function_colorcode.csv
## Plot schematic gene plot
clinker *.gbk --plot ./image/read1_2.html -gf gene_function.csv -cm function_colorcode.csv