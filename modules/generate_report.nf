process make_clinker_figures {
    label 'process_low'
    container 'community.wave.seqera.io/library/r-tidyverse:2.0.0--dd61b4cbf9e28186'
    publishDir "${params.outdir}/report/${unique_id}", mode: 'copy'

    input:
        tuple val(unique_id), path(read_tsv)
    output:
        tuple val(unique_id), path("${read_tsv}.html")
    script:
    """
    touch "${read_tsv}.html"
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