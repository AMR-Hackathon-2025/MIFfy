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
    tuple val(sample_id), path("*.embl")             , emit: embl
    tuple val(sample_id), path("*.faa")              , emit: faa
    tuple val(sample_id), path("*.ffn")              , emit: ffn
    tuple val(sample_id), path("*.fna")              , emit: fna
    tuple val(sample_id), path("*.gbff")             , emit: gbff
    tuple val(sample_id), path("*.gff3")             , emit: gff
    tuple val(sample_id), path("*.hypotheticals.tsv"), emit: hypotheticals_tsv
    tuple val(sample_id), path("*.hypotheticals.faa"), emit: hypotheticals_faa
    tuple val(sample_id), path("*.tsv")              , emit: tsv
    tuple val(sample_id), path("*.txt")              , emit: txt

    script:
    """
    mkdir ./temp_matplotlib
    export MPLCONFIGDIR=./temp_matplotlib
    bakta --db ${params.bakta_database} --threads $task.cpus --skip-plot --keep-contig-headers ${fasta}
    """
}


process blast {

    label 'process_medium'
    publishDir "${params.outdir}/annotation/", mode: 'copy'
    container 'biocontainers/blast:2.16.0--h66d330f_5'

    input:
        tuple val(sample_id), file(fasta), file(de_dup_counts_table)
        path(blast_database)

    output:
        tuple val(sample_id), path("${sample_id}.deduplicated.hits.tsv")

    script:
    """
    blastn \\
        -db ${blast_database} \\
        -query ${fasta} \\
        -out ${sample_id}.deduplicated.hits.tsv \\
        -outfmt "6 qseqid sseqid pident length mismatch qstart qend sstart send evalue bitscore qseq" \\
        -max_target_seqs 1 \\
        -num_threads ${task.cpus}
    """

}

workflow annotation {

    take:
        fasta_ch // fasta

    main:
        cluster_reads(fasta_ch)     
        bakta(cluster_reads.out)
        ch_blast_db = params.blast_database ? file("${params.blast_database}") : []
        blast(cluster_reads.out, ch_blast_db)





}