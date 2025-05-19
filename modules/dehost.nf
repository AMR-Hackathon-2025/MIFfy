#!/usr/bin/env nextflow

process dehost {

    label "process_low"
    container "community.wave.seqera.io/library/hostile:2.0.0--a16bb8e6c792e0d0"

    input:
    tuple val(unique_id), path(fastq)

    output:
    tuple val(unique_id), path("${fastq.baseName}.clean.fastq")

    script:
    """
    hostile clean \
      --fastq1 ${fastq} \
      --index human-t2t-hla.argos-bacteria-985_rs-viral-202401_ml-phage-202401 \
      -o - > ${fastq.baseName}.clean.fastq
    """
}