include { dehost } from '../modules/dehost'
include { assemble } from '../modules/assemble'

workflow run_miffy
{
    take:
        fastq_ch
    main:
        dehost(fastq_ch)
        assemble(dehost.out)

        annotation(find_integrons.out)
    emit:
        assemble.out.fasta
}