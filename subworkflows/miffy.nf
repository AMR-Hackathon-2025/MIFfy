include { dehost          } from '../modules/dehost'
include { assemble        } from '../modules/assemble'
include { INTEGRON_FINDER } from "./integron_finder/main.nf"

workflow run_miffy {
    take:
    fastq_ch

    main:
    dehost(fastq_ch)
    assemble(dehost.out)
    INTEGRON_FINDER(assemble.out.fasta)
    annotation(INTEGRON_FINDER.out.integrons)

    emit:
    assemble.out.fasta
}
