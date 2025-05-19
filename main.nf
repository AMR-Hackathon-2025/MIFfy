include { annotation } from './subworkflows/annotation'



workflow {
    
    sample_sheet = "${projectDir}/test/annotation_test.csv"
    database  = "/shared/public/db/bakta/2024-01-19/db"


    println "Samplesheet: ${sample_sheet}"

    fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.fasta))}

    fasta_ch.view()
    annotation(fasta_ch, database)

}