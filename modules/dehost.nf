#!/usr/bin/env nextflow
process fetchHostileReference {

    label 'process_low'

    container 'community.wave.seqera.io/library/hostile:2.0.0--a16bb8e6c792e0d0'

    conda 'bioconda::hostile=2.0.0'
    
    storeDir "${params.store_dir}/hostile/"

    output:
    path "${params.store_dir}/hostile/${params.hostile_database_name}"

    script:
    """
    export HOSTILE_CACHE_DIR='${params.store_dir}/hostile'
    hostile index fetch ${params.hostile_database_name} --minimap2
    """
}

process runHostile {

    label "process_low"
    container "community.wave.seqera.io/library/hostile:2.0.0--a16bb8e6c792e0d0"

    input:
    tuple val(unique_id), path(fastq)

    output:
    tuple val(unique_id), path("${fastq.baseName}.clean.fastq")

    script:
    """
    export HOSTILE_CACHE_DIR='${params.store_dir}/hostile/'
    hostile clean \
      --fastq1 ${fastq} \
      --index ${params.hostile_database_name} \
      -o - > ${fastq.baseName}.clean.fastq
    """
}

workflow  dehost{
    take:
        fastq_ch
    main:
        if (!params.skip_host_filter) {
            /*input_database = file("${params.store_dir}/hostile/${params.hostile_database_name}")
            if (input_database.isEmpty()) {
                database = fetchHostileReference()
            } else {
                database = Channel.of(input_database)
            }*/
            runHostile(fastq_ch)
            filtered_reads_ch = runHostile.out

        } else {
            filtered_reads_ch = fastq_ch
        }
    emit:
        clean = filtered_reads_ch
}