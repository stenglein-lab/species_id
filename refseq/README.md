This directory contains a file, co1.fasta, that contains a set of 546 cytochrome oxidase subunit 1 sequences from Drosophilidae.  

The fasta header lines have been reformated to be of the form:

>Genes_species__accession:range_min-range_max

These sequences were collected on 8/13/2024 by:

- Using the CO1 coding sequence from from NC_024511 as a megabast query to the NCBI core_nt nucleotide database to identify other drosophilid CO1 sequences.  
- We restricted megablast results to sequences from Drosophilidae and to alignments with >90% query coverage.  
- We used cd-hit-est to collapse sequences that shared >99% pairwise nucleotide identity to create a set of representative sequences. 

Note that this strategy will not necessarily capture all representative CO1 sequences in Drosophilidae.  For instance, it would miss sequences that were not sufficiently similar to the query to produce megablast alignments.

We also have manually added CO1 sequences from other drosophilid species that have turned up in our sampling of North American flies (e.g. Megaselia scalaris).
