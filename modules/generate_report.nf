process make_clinker_figures {
    label 'process_low'
    container 'community.wave.seqera.io/library/r-tidyverse:2.0.0--dd61b4cbf9e28186'
    publishDir "${params.outdir}/report/${unique_id}", mode: 'copy'

    input:
        tuple val(unique_id), path(read_tsv), path(read_fasta)
    output:
        tuple val(unique_id), path("${read_tsv}.html")
    script:
    """
    ## Transform mify output to genbank format
    Rscript longread_to_genbank.R -t ${read_tsv} -f ${read_fasta} -o ${read_fasta.simpleName}.gbk
    
    ## Generate colorcode for AMR class
    Rscript gen_colourcode.R --input_file ${read_tsv} --gene_function_out ${read_fasta.simpleName}_gene_function.csv --colorcode_out ${read_fasta.simpleName}_colorcode.csv
    
    ## Plot schematic gene plot
    clinker *.gbk --plot ./images/${read_fasta.simpleName}.html -gf ${read_fasta.simpleName}_gene_function.csv -cm ${read_fasta.simpleName}_colorcode.csv
    """

}

process generate_html {
    label 'process_low'
    container 'community.wave.seqera.io/library/r-tidyverse:2.0.0--dd61b4cbf9e28186'
    publishDir "${params.outdir}/report/${unique_id}", mode: 'copy'

    input:
        tuple val(unique_id), path("${read_tsv}.html"), path(read_tsv}), path(summary_rmd)
    output:
        tuple val(unique_id), path("miffy_summary.html")
    script:
    """
    Rscript -e 'rmarkdown::render("${summary_rmd}", output_dir=getwd(), output_format = "html_document", output_file = "miffy_summary.html", params = list("result_dir" = "${params.outdir}", "result_file"="${read_tsv}"))'

    """

}