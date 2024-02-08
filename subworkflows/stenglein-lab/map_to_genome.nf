include { BOWTIE2_ALIGN                          } from '../../modules/nf-core/bowtie2/align/main'

workflow MAP_TO_GENOME {

 take:
  reads
  index

 main:

  // define some empty channels for keeping track of stuff
  ch_versions     = Channel.empty()                                               

  // map reads 
  def sort_bam = true 
  def save_unaligned = false 
  BOWTIE2_ALIGN (reads, index, save_unaligned, sort_bam)
  ch_versions = ch_versions.mix ( BOWTIE2_ALIGN.out.versions )      


 emit: 
  versions      = ch_versions
  bam           = BOWTIE2_ALIGN.out.bam

}
