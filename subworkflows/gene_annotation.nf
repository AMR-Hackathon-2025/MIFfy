process cluster_reads {
        label "process_low"
        container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/biopython:1.81'
        : 'biocontainers/biopython:1.81'}"

    input:
        tuple val(sample_id), file(fasta)

    output:
        tuple val(sample_id), file("*.deduplicated.fasta"), file("*.duplication_counts.tsv")

    script:
        """
        deduplicate_fasta.py -f ${fasta} 
        """
}
process bakta {
        label 'process_high'
        publishDir "${params.outdir}/annotation/${sample_id}", mode: 'copy'
        container 'biocontainers/bakta:1.11.0--pyhdfd78af_0'

    input:
        tuple val(sample_id), file(fasta), file(de_dup_counts_table)

    output:
        tuple val(sample_id), path("*.embl"), emit: embl
        tuple val(sample_id), path("*.faa"), emit: faa
        tuple val(sample_id), path("*.ffn"), emit: ffn
        tuple val(sample_id), path("*.fna"), emit: fna
        tuple val(sample_id), path("*.gbff"), emit: gbff
        tuple val(sample_id), path("*.gff3"), emit: gff
        tuple val(sample_id), path("*.hypotheticals.tsv"), emit: hypotheticals_tsv
        tuple val(sample_id), path("*.hypotheticals.faa"), emit: hypotheticals_faa
        tuple val(sample_id), path("*.tsv"), emit: tsv
        tuple val(sample_id), path("*.txt"), emit: txt

    script:
        """
        mkdir ./temp_matplotlib
        export MPLCONFIGDIR=./temp_matplotlib
        bakta --db ${params.bakta_database} --threads ${task.cpus} --skip-plot --keep-contig-headers ${fasta}
        """
}
process blast {
        label 'process_medium'
        publishDir "${params.outdir}/annotation/${sample_id}", mode: 'copy'
        container 'biocontainers/blast:2.16.0--h66d330f_5'

    input:
        tuple val(sample_id), file(fasta), file(de_dup_counts_table)

    output:
        tuple val(sample_id), path("${sample_id}.blastn_deduplicated_hits.tsv")

    script:
        """
        blastn \\
            -db ${params.blast_database} \\
            -query ${fasta} \\
            -out ${sample_id}.blastn_deduplicated_hits.tsv \\
            -outfmt "6 qseqid sseqid pident length mismatch qstart qend sstart send evalue bitscore qseq" \\
            -max_target_seqs 1 \\
            -num_threads ${task.cpus}
        """
}
process combine_bakta_and_blast {
        label 'process_low'
        container 'community.wave.seqera.io/library/r-tidyverse:2.0.0--dd61b4cbf9e28186'
        publishDir "${params.outdir}/annotation/${params.unique_id}", mode: 'copy'

    input:
        tuple val(unique_id), path(bakta_tsv), path(blast_tsv)

    output:
        tuple val(unique_id), path("${unique_id}.bakta_blast_annotation_merge.tsv")

    script:
        """
        Rscript ${projectDir}/bin/annotation_merging.R ${bakta_tsv} ${blast_tsv} ${unique_id}.bakta_blast_annotation_merge.tsv
        """
}
workflow annotation {
    take:
    fasta_ch // fasta

    main:
        cluster_reads(fasta_ch)
        bakta(cluster_reads.out)
        blast(cluster_reads.out)
        bakta.out.tsv.combine(blast.out, by: 0).set { bakta_and_blast_ch }
        combine_bakta_and_blast(bakta_and_blast_ch)

    emit:
    tsv = combine_bakta_and_blast.out 

}
