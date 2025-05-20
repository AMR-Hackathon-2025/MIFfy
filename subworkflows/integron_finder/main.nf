include { INTEGRONFINDER         } from "./modules/local/integron_finder/main.nf"
include { PARSE_INTEGRON_RESULTS } from "./modules/local/integron_finder/main.nf"

workflow INTEGRON_FINDER {
    take:
    ch_contigs

    main:
    ch_contigs
        .map { samp_id, contigs -> [[id: samp_id], contigs] }
        .set { contigs }

    INTEGRONFINDER(contigs)

    ch_parse_input = INTEGRONFINDER.out.integrons.join(contigs)

    PARSE_INTEGRON_RESULTS(ch_parse_input)

    emit:
    integrons           = PARSE_INTEGRON_RESULTS.out.fasta.map { meta, integron_fasta -> [meta.id, integron_fasta] }
    integron_result_tsv = PARSE_INTEGRON_RESULTS.out.integron_results_tsv.map { meta, integron_tsv -> [meta.id, integron_tsv] }
}
