#!/bin/bash

# Assuming you are in LMGPU directory

URL="./data/UTHSC_SPL_RMA_1210.zip"
geno_output_file="./data/SPLEEN_CLEAN_DATA/geno_prob.csv"
pheno_output_file="./data/SPLEEN_CLEAN_DATA/pheno.csv"
new_gmap_file="./data/SPLEEN_CLEAN_DATA/gmap.csv"

# time Rscript --vanilla ./cli/cleaning.R $URL $geno_output_file $pheno_output_file $new_gmap_file

geno_file="./data/SPLEEN_CLEAN_DATA/geno_prob.csv"
pheno_file="./data/SPLEEN_CLEAN_DATA/pheno.csv"
export_matrix="false"
output_file="./data/results/output.csv"
rqtl_file="./data/UTHSC_SPL_RMA_1210.zip"

# Test running time of passing Julia and the source file. AKA no compile version.
# time JULIA_NUM_THREADS=16 julia ./bin/MyApp/src/MyApp.jl $geno_file $pheno_file $export_matrix $output_file $rqtl_file

# Test running time of binary built by PackageCompiler 1.0
time JULIA_NUM_THREADS=16 ./bin/MyAppCompiled/bin/MyApp $geno_file $pheno_file $export_matrix $output_file $rqtl_file

# Testing julia1.4 running example. AKA no compiler version.
# time JULIA_NUM_THREADS=16 julia4 ./example/spleen_analysis.jl $geno_file $pheno_file $export_matrix $output_file $rqtl_file

# Testing running time of binary built by PackageCompiler 0.6.5
# time JULIA_NUM_THREADS=16 /home/xhu/.julia/dev/LMGPU/bin/MyApp/src/builddir/MyApp $geno_file $pheno_file $export_matrix $output_file $rqtl_file
