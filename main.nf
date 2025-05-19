include { run_miffy } from './subworkflows/miffy'


workflow {
    if (params.output)
    	exit 1, "Please specify outdir with --outdir -- aborting"
    if (params.out_dir)
        exit 1, "Please specify outdir with --outdir -- aborting"

    unique_id = "${params.unique_id}"

    if (unique_id == "null") {
        if (params.fastq) {
            fastq = file(params.fastq, type: "file", checkIfExists:true)
            unique_id = "${fastq.simpleName}"
        } else {
            exit 1, "Please specify --fastq -- aborting"
        }
    }

    fastq_ch = Channel.from(fastq)
    input_ch = [unique_id, fastq_ch]
    

}
