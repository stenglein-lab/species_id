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
  output_dir      = "./"
} else {
  # if running via RStudio
  # r_lib_dir = "../lib/R/"
  tsv_input      = "../results/process/summarized_mapping_stats.txt"
  output_dir     = "../results/"
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
colnames(df) <- c("dataset", "species", "count", "pct_id")

# calculate mapping count totals for each dataset
# then determine fractional counts 
df <- df %>% 
  group_by(dataset) %>% 
  mutate(total_count = sum(count), 
            fractional_count = count / total_count) %>% 
  mutate(accession_species = species,  species = str_match(species, "_([A-Z].*)")[,2]) %>%
  arrange(dataset, -fractional_count)

# output observed spp - all hits
write.table(df, 
            file=paste0(output_dir, "co1_observed_species.all_hits.txt"), 
            quote=F, sep="\t", row.names=F)

# output observed spp - all hits
write.table(filter(df, fractional_count > 0.01),, 
            file=paste0(output_dir, "co1_observed_species.gt_1_pct_hits.txt"), 
            quote=F, sep="\t", row.names=F)

# top hits for each datset
top_hits <- 
  df %>% 
  group_by(dataset) %>% 
  arrange(-fractional_count) %>% 
  filter(row_number()==1) 


# what species were observed?
observed_species <- top_hits %>% 
  group_by(species) %>% 
  summarize(n=n()) %>%
  arrange(-n)

# output observed spp - only top hits from each dataset
write.table(observed_species, 
            file=paste0(output_dir, "co1_observed_species.top_hits.txt"), 
            quote=F, sep="\t", row.names=F)


# actually make assignments based on highest fractional count
df_assigned <- df %>% 
  group_by(dataset) %>% 
  arrange(-fractional_count) %>% 
  filter(row_number()==1) %>%
  mutate(assigned_species = if_else(fractional_count > 0.50, species, "undetermined")) %>%
  select(dataset, assigned_species, count, fractional_count, pct_id) %>%
  arrange(dataset)

  # summarize(fraction_co1 = max(fractional_count), 
            # count=count[1], 
            # pct_id = pct_id[1],
            # assigned_species = if_else(fraction_co1 > 0.50, species[1], "undetermined"))

# write output to tsv file
write.table(df_assigned, 
            file = paste0(output_dir, "co1_based_species_assignments.txt"), 
            quote=F, sep="\t", row.names=F)
