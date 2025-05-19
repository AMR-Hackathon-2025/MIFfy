// Cluster Unique reads
// Convert to fastq
// Annotation: AMR Finder
// Annotation: VFDB
// Annotation: Bakta
// OASIS

process cluster_reads{
    label 'process_low'
    container 'community.wave.seqera.io/library/bio:1.8.0--1a14c5d84ae932e1'

    publishDir "${params.outdir}/annotation/", mode: 'copy'

    input:
        tuple val(sample_id), file(fasta)

    output:
        tuple val(sample_id), file("*.deduplicated.fasta"), file("*.duplication_counts.tsv")

    script:
    """
    deduplicate_fasta.py -f ${fasta} 
    """

}

process bakta{
    label 'process_low'

    publishDir "${params.outdir}/annotation/", mode: 'copy'
    
    container 'biocontainers/bakta:1.11.0--pyhdfd78af_0'

    input:
        tuple val(sample_id), file(fasta), file(de_dup_counts_table)

    script:
    """
    bakta --db ${database} --skip-plot --keep-contig-headers ${fasta}
    """
}


// process oasis{



// }


workflow annotation {

    take:
        fasta_ch, database // fasta

    main:
        cluster_reads(fasta_ch)     
        bakta(cluster_unqiue_reads.out)




}