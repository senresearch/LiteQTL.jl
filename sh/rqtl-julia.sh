#!/bin/bash

# Assuming you are in LMGPU directory

URL="./data/HC_M2_0606_R.zip"
output_dir="./data/HIPPO_CLEAN_DATA/"
scan="FALSE"

time Rscript --vanilla ./r/cleaning.R $URL $output_dir $scan
#
export_matrix="false"
output_file="julia_result.csv"
# rqtl_file is needed to find gmap.csv.
rqtl_file=$URL
r_sign=false
# Test running time of binary built by PackageCompiler 1.0
time JULIA_NUM_THREADS=16 julia ./bin/MyAppCompiled/bin/MyApp $output_dir $output_file $rqtl_file $export_matrix $r_sign
