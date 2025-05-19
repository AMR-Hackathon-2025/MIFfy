<<<<<<< HEAD
include { run_miffy } from './subworkflows/miffy'


workflow {
    if (params.output)
    	exit 1, "Please specify outdir with --outdir -- aborting"
    if (params.out_dir)
        exit 1, "Please specify outdir with --outdir -- aborting"

    fastq = file(params.fastq, type: "file", checkIfExists:true)
    if (params.unique_id == "null"){
        unique_id = "${fastq.simpleName}"
    } else {
        unique_id = "${params.unique_id}"
    }

    fastq_ch = Channel.of([unique_id, fastq])
    fastq_ch.view()
    run_miffy(fastq_ch)

}
=======



workflow {
    
    sample_sheet = "${params.projecDir}/test/annotation_test.csv"


    if (params.sample_sheet){
        fasta_ch = Channel.fromPath(sample_sheet) | splitCsv(header:true) | map {row->tuple(row.sample_id, file(row.fasta))}
    }
    annotation(fasta_ch)

}
>>>>>>> 0532adab064f7a1fd4d5f985d428d3eabdf01864
