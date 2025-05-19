// Cluster Unique reads
// Convert to fastq
// Annotation: AMR Finder
// Annotation: VFDB
// Annotation: Bakta
// OASIS

process cluster_reads{
    // https://nf-co.re/modules/cdhit_cdhitest/
    // mash
    // md5
    // vclust
    //input:
        // 

}

process convert_to_fasta{
    // exiting process


}

process amr_detection {
    // https://nf-co.re/modules/abricate_run/
    // nf-core/funcscan
}

process virulance_factors {
    // 

}

process bakta{


}


process oasis{



}
workflow annotation {

    take:
        fastq_ch // fasta

    main:
        cluster_unqiue_reads(fastq_ch)     
        convert_to_fasta(cluster_unqiue_reads.out)




}