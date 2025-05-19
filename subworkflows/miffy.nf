include { dehost } from '../modules/dehost'


workflow run_miffy
{
    take:
        fastq_ch
    main:
        dehost(fastq_ch)
    emit:
        dehost.out
}