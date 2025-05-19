include { annotation } from './subworkflows/annotation'



workflow {
    
    sample_sheet = "${projectDir}/test/annotation_test.csv"

    fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.fasta))}

    fasta_ch.view()
    annotation(fasta_ch, database)

}