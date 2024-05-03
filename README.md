###

This directory contains a nextflow workflow to attempt to assign drosophild species using cytochrome C oxidase subunit-1 (COX1)-mapping reads.

The workflow maps reads to a curated set of drosophilid COX1 sequences and allows the COX1 sequences to compete for mapping.  

The entry point into the workflow is the run_species_id shell script.

### Software dependencies

These analyses are implemented in [nextflow](https://www.nextflow.io/docs/latest/).  Dependencies are handled through singularity so installation of other software besides nextflow and singularity shouldn't be necessary.  

