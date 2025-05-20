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
    label 'process_high'

    publishDir "${params.outdir}/annotation/", mode: 'copy'
    
    container 'biocontainers/bakta:1.11.0--pyhdfd78af_0'

    input:
        tuple val(sample_id), file(fasta), file(de_dup_counts_table)

    output:
    tuple path("*.embl")             , emit: embl
    tuple path("*.faa")              , emit: faa
    tuple path("*.ffn")              , emit: ffn
    tuple path("*.fna")              , emit: fna
    tuple path("*.gbff")             , emit: gbff
    tuple path("*.gff3")             , emit: gff
    tuple path("*.hypotheticals.tsv"), emit: hypotheticals_tsv
    tuple path("*.hypotheticals.faa"), emit: hypotheticals_faa
    tuple path("*.tsv")              , emit: tsv
    tuple path("*.txt")              , emit: txt
    path "versions.yml"              , emit: versions


    script:
    """
    mkdir ./temp_matplotlib
    export MPLCONFIGDIR=./temp_matplotlib
    bakta --db ${params.bakta_database} --threads $task.cpus --skip-plot --keep-contig-headers ${fasta}
    """
}



workflow annotation {

    take:
        fasta_ch // fasta

    main:
        cluster_reads(fasta_ch)     
        bakta(cluster_reads.out)




}