#!/bin/bash

# Assuming you are in LMGPU directory


geno_file="../data/cleandata/geno_prob.csv"
pheno_file="../data/cleandata/traits.csv"
export_matrix="false"
output_file="../data/results/output.csv"
rqtl_file="../data/UTHSC_SPL_RMA_1210.zip"

time JULIA_NUM_THREADS=8 ./MyAppCompiled/bin/MyApp $geno_file $pheno_file $export_matrix $output_file $rqtl_file
