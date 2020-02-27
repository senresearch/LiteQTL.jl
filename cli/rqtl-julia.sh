#!/bin/bash

# Assuming you are in LMGPU directory

URL="./data/UTHSC_SPL_RMA_1210.zip"
geno_output_file="./data/SPLEEN_CLEAN_DATA/geno_prob.csv"
pheno_output_file="./data/SPLEEN_CLEAN_DATA/pheno.csv"
new_gmap_file="./data/SPLEEN_CLEAN_DATA/gmap.csv"

time Rscript --vanilla ./cli/cleaning.R $URL $geno_output_file $pheno_output_file $new_gmap_file

geno_file="./data/SPLEEN_CLEAN_DATA/geno_prob.csv"
pheno_file="./data/SPLEEN_CLEAN_DATA/pheno.csv"
export_matrix="false"
output_file="./data/results/output.csv"
rqtl_file="./data/UTHSC_SPL_RMA_1210.zip"

time JULIA_NUM_THREADS=8 ./cli/MyAppCompiled/bin/MyApp $geno_file $pheno_file $export_matrix $output_file $rqtl_file
