


workflow {
    
    sample_sheet = "${params.sample_sheet}"


    if (params.sample_sheet){
        fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.read1))}
    }
    annotation(fasta_ch)

}

