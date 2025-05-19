


workflow {
    
    sample_sheet = "${projectDir}/test/annotation_test.csv"

    println "Samplesheet: ${sample_sheet}"

    fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.fasta))}

    fasta_ch.view()
    annotation(fasta_ch)

}