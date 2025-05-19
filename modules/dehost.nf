#!/usr/bin/env nextflow
process fetchHostileReference {

    label 'process_low'

    container 'community.wave.seqera.io/library/hostile:2.0.0--a16bb8e6c792e0d0'

    conda 'bioconda::hostile=2.0.0'

    input:
    path store_dir

    output:
    path "hostile.ok"

    script:
    """
    export HOSTILE_CACHE_DIR='${store_dir}/hostile'
    hostile fetch --aligner bowtie2

    touch hostile.ok
    """
}

process runHostile {

    label "process_low"
    container "community.wave.seqera.io/library/hostile:2.0.0--a16bb8e6c792e0d0"

    input:
    tuple val(unique_id), path(fastq)
    path hostile_ok


    output:
    tuple val(unique_id), path("${fastq.baseName}.clean.fastq")

    script:
    """
    export HOSTILE_CACHE_DIR='${params.store_dir}/hostile/'
    hostile clean \
      --fastq1 ${fastq} \
      --index human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401 \
      -o - > ${fastq.baseName}.clean.fastq
    """
}

workflow  dehost{
    take:
        fastq_ch
    main:
        if (!params.skip_host_filter) {
            fetchHostileReference(params.store_dir)
            runHostile(fastq_ch, fetchHostileReference.out)
            filtered_reads_ch = runHostile.out

        } else {
            filtered_reads_ch = fastq_ch
        }
    emit:
        clean = filtered_reads_ch
}