


workflow {
    
    sample_sheet = "${projectDir}/test/annotation_test.csv"

    println ${sample_sheet}

    if (params.sample_sheet){
        fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.fasta))}
    }
    annotation(fasta_ch)

}