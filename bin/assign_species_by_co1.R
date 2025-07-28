#!/usr/bin/env Rscript

library(tidyverse)

# This code block sets up input arguments to either come from the command line
# (if running from the pipeline, so not interactively) or to use expected default values
# (if running in interactive mode, for example in RStudio for troubleshooting
# or development).
#
if (!interactive()) {
  # if running from Rscript
  args = commandArgs(trailingOnly=TRUE)
  # lib_dir=args[1]
  tsv_input       = args[1]
  metadata_rds    = args[2] # optional metadata input
  output_dir      = "./"
} else {
  # if running via RStudio
  # r_lib_dir = "../lib/R/"
  tsv_input      = "../results_species_id/process/summarized_mapping_stats.txt"
  metadata_rds   = "../../metadata/collected_metadata.rds"
  output_dir     = "../results_species_id/process/"
}

#
# assign species using counts of reads
# from a competitive mapping analysis 
#
# for instance, by mapping reads to all available
# Drosophila CO1 (cytochrome oxidase 1) sequencs
#
# MDS 2/14/2024
#

# read in the data
df <- read.delim(tsv_input, sep="\t", header=F)

# name columns
colnames(df) <- c("dataset", "co1_species", "count", "pct_id")

# check to see if optional metadata file exists.  If not, don't use it.
if (file.exists(metadata_rds)) {
  use_metadata <- T
} else {
  use_metadata <- F
  warning(paste0("WARNING: metadata file " , metadata_rds, " does not exist.  Metadata will not be used."))
}

# read in metadata
if (use_metadata) {
  metadata <- readRDS(metadata_rds)
}

# pull out refseq accession and species names from accession_species sequence IDs
df <- df %>% 
  group_by(dataset) %>% 
  mutate(accession_species = co1_species,  
         accession   = str_match(co1_species, "(.*)_([A-Z].*)")[,2], 
         co1_species = str_match(co1_species, "(.*)_([A-Z].*)")[,3]) 

# calculate count totals for each dataset
# then determine fractional counts 
df <- df %>% 
  group_by(dataset) %>% 
  mutate(total_count = sum(count)) 

# calculate fractional counts for each refseq
df <- df %>% 
  group_by(dataset) %>% 
  mutate(fractional_count = count / total_count)  %>%
  arrange(dataset, -fractional_count)

# sum fractional counts in case > 1 refseq for each species
df_spp <- df %>% 
  group_by(dataset, co1_species) %>% 
  summarize(count = sum(count), 
         fractional_count = sum(fractional_count),
         .groups="drop") %>%
  arrange(dataset, -fractional_count)

# merge in metadata, if it exists
if (use_metadata) {
  df <- left_join(df, metadata, by=c("dataset" = "sample_id"))
}

# output observed spp - all hits
write.table(df, 
            file=paste0(output_dir, "co1_observed_species.all_hits.txt"), 
            quote=F, sep="\t", row.names=F)

# output observed spp - hits constituting >1% of mapped reads
write.table(filter(df, fractional_count > 0.01),
            file=paste0(output_dir, "co1_observed_species.gt_1_pct_hits.txt"), 
            quote=F, sep="\t", row.names=F)

# top hit for each datset
top_hits <- 
  df %>% 
  group_by(dataset) %>% 
  arrange(-fractional_count) %>% 
  filter(row_number()==1) 

# what species were observed?
observed_species <- top_hits %>% 
  group_by(co1_species) %>% 
  summarize(n=n()) %>%
  arrange(-n)

# output observed spp - only top hits from each dataset
write.table(observed_species, 
            file=paste0(output_dir, "co1_observed_species.top_hits.txt"), 
            quote=F, sep="\t", row.names=F)


# actually make assignments based on highest fractional count
# requirements for assignment:
# - some species accounted for >50% of co1-mapping reads
df_assigned <- df %>% 
  group_by(dataset) %>% 
  arrange(-fractional_count) %>% 
  filter(row_number()==1) %>%
  mutate(co1_assigned_species = if_else(fractional_count > 0.50, co1_species, "undetermined")) %>%
  arrange(sample_type, sample_order) %>%
  select(dataset, co1_assigned_species, count, fractional_count, accession, pct_id)

# write output to tsv file
write.table(df_assigned, 
            file = paste0(output_dir, "co1_based_species_assignments.txt"), 
            quote=F, sep="\t", row.names=F)
