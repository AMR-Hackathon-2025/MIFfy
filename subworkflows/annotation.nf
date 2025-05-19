// Cluster Unique reads
// Convert to fastq
// Annotation: AMR Finder
// Annotation: VFDB
// Annotation: Bakta
// OASIS

process cluster_reads{
    label 'process_low'
    container 'community.wave.seqera.io/library/bio:1.8.0--1a14c5d84ae932e1'
    
    publishDir "${params.outdir}/annotation/", mode: 'copy'

    input:
        tuple val(sample_id), file(fasta)

    output:
        tuple file("*.deduplicated.fasta"), file("*.duplication_counts.fasta")

    script:
    """
    deduplicate_fasta.py -i ${fasta} 
    """

}

// process convert_to_fasta{
//     // exiting process


// }

// process amr_detection {
//     // https://nf-co.re/modules/abricate_run/
//     // nf-core/funcscan
// }

// process virulance_factors {
//     // 

// }

// process bakta{


// }


// process oasis{



// }


workflow annotation {

    take:
        fastq_ch // fasta

    main:
        cluster_reads(fastq_ch)     
        // convert_to_fasta(cluster_unqiue_reads.out)




}