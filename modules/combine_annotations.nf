process combine_annotations{
    label 'process_low'
    container 'community.wave.seqera.io/library/bio:1.8.0--1a14c5d84ae932e1'

    publishDir "${params.outdir}/annotation/${unique_id}", mode: 'copy'

    input:
        tuple val(unique_id), path(bakta_tsv), path(minimap_tsv)

    output:
        tuple val(unique_id), path("${unique_id}_*.tsv")

    script:
    """
    compare_tsv.py --bakta_tsv ${bakta_tsv} --minimap_tsv ${minimap_tsv} --prefix ${unique_id}
    """
}