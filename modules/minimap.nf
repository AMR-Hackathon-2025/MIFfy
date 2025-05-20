process minimap2_ref {

    label "process_medium"

    conda "bioconda::minimap2=2.28"
    container "community.wave.seqera.io/library/minimap2:2.28--78db3d0b6e5cb797"

    input:
    tuple val(unique_id), val(fastq)
    path refs

    output:
    tuple val(unique_id), path("${unique_id}.mmp.sam")

    script:
    preset = ""
    if (params.read_type == "illumina") {
        preset = "sr"
    }
    else {
        preset = "map-ont"
    }
    """
        minimap2 -ax ${preset} ${refs} ${fastq} --secondary=no -N 1 -t ${task.cpus} --sam-hit-only > "${unique_id}.mmp.sam"
        """
}

process evaluate_minimap2_output {
    container 'community.wave.seqera.io/library/simplesam_numpy_pandas:ea9b7172ad7bff36'

    input:
    tuple val(unique_id), path(sam)

    output:
    tuple val(unique_id), path("minimap.tsv")

    script:
    """
    touch "minimap.tsv"
    """
}

workflow get_minimap_tsv {
    take:
    fastq_ch

    main:
    refs = file("${params.minimap_refs}", type: "file", checkIfExists: true)
    minimap2_ref(fastq_ch, refs)
    evaluate_minimap2_output(minimap2_ref.out)

    emit:
    evaluate_minimap2_output.out
}
