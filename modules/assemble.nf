process assemble {
    label 'process_high'

    container "community.wave.seqera.io/library/flye:2.9.5--d577924c8416ccd8"

    publishDir "${params.outdir}/${unique_id}/assembly/", mode: 'copy', pattern: "*.gz"
    publishDir "${params.outdir}/${unique_id}/assembly/", mode: 'copy', pattern: "*.log"


    input:
    tuple val(unique_id), path(reads)

    output:
    tuple val(unique_id), path("*.fasta.gz"), emit: fasta
    tuple val(unique_id), path("*.gfa.gz"), emit: gfa
    tuple val(unique_id), path("*.gv.gz"), emit: gv
    tuple val(unique_id), path("*.txt"), emit: txt
    tuple val(unique_id), path("*.log"), emit: log
    tuple val(unique_id), path("*.json"), emit: json
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${unique_id}"
    def valid_mode = ["--pacbio-raw", "--pacbio-corr", "--pacbio-hifi", "--nano-raw", "--nano-corr", "--nano-hq"]
    if (!valid_mode.contains(params.flye_mode)) {
        error("Unrecognised mode ${params.flye_mode} to run Flye. Options: ${valid_mode.join(', ')}")
    }
    """
    flye \\
        ${params.flye_mode} \\
        ${reads} \\
        --out-dir . \\
        --threads \\
        ${task.cpus} \\
        ${args}

    gzip -c assembly.fasta > ${prefix}.assembly.fasta.gz
    gzip -c assembly_graph.gfa > ${prefix}.assembly_graph.gfa.gz
    gzip -c assembly_graph.gv > ${prefix}.assembly_graph.gv.gz
    mv assembly_info.txt ${prefix}.assembly_info.txt
    mv flye.log ${prefix}.flye.log
    mv params.json ${prefix}.params.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flye: \$( flye --version )
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${unique_id.id}"
    """
    echo stub | gzip -c > ${prefix}.assembly.fasta.gz
    echo stub | gzip -c > ${prefix}.assembly_graph.gfa.gz
    echo stub | gzip -c > ${prefix}.assembly_graph.gv.gz
    echo contig_1 > ${prefix}.assembly_info.txt
    echo stub > ${prefix}.flye.log
    echo stub > ${prefix}.params.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        flye: \$( flye --version )
    END_VERSIONS
    """
}