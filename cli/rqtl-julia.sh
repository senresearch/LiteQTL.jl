#!/bin/bash

# Assuming you are in LMGPU directory

URL="./data/HC_M2_0606_R.zip"
geno_output_file="./data/HIPPO_CLEAN_DATA/geno_prob.csv"
pheno_output_file="./data/HIPPO_CLEAN_DATA/pheno.csv"
new_gmap_file="./data/HIPPO_CLEAN_DATA/gmap.csv"

time Rscript --vanilla ./r/clean-and-scan.R $URL $geno_output_file $pheno_output_file

# geno_file="./data/HIPPO_CLEAN_DATA/geno_prob.csv"
# pheno_file="./data/HIPPO_CLEAN_DATA/pheno.csv"
# export_matrix="false"
# output_file="./data/results/hippo_output.csv"
# # rqtl_file is needed to find gmap.csv.
# rqtl_file="./data/HC_M2_0606_R.zip"
#
# # Test running time of binary built by PackageCompiler 1.0
# time JULIA_NUM_THREADS=16 ./bin/MyAppCompiled/bin/MyApp $geno_file $pheno_file $export_matrix $output_file $rqtl_file
