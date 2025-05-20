include { dehost              } from '../modules/dehost'
include { assemble            } from '../modules/assemble'
include { INTEGRON_FINDER     } from "./integron_finder/main.nf"
include { annotation          } from '../subworkflows/gene_annotation'
include { get_minimap_tsv     } from '../modules/minimap'
include { combine_annotations } from '../modules/combine_annotations'


workflow run_miffy {
    take:
    fastq_ch

    main:
    dehost(fastq_ch)
    assemble(dehost.out)
    INTEGRON_FINDER(assemble.out.fasta)
    
    annotation(INTEGRON_FINDER.out.integrons)
    get_minimap_tsv(INTEGRON_FINDER.out.integrons)
    annotation.out.tsv.combine(get_minimap_tsv.out.tsv, by: 0).set{bakta_and_minimap_ch}
    combine_annotations(bakta_and_minimap_ch)

    emit:
    bakta_and_minimap_ch.out
}
