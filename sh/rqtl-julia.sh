#!/bin/bash

# Assuming you are in LMGPU directory

# Input in Rqtl2 format.
URL="./data/HC_M2_0606_R.zip"
# Intermediate and final scan result will be stored here.
output_dir="./data/HIPPO_CLEAN_DATA/"
# Do genome scan with R/qtl2, default is False. Only True if we need to compare genome scan results produced by LMGPU.
scan="FALSE"

time Rscript --vanilla ./r/cleaning.R $URL $output_dir $scan
#
# If export_matrix set to true, then the entire LOD score matrix will be exported. If false, only maximum lod and related gmpa info will be exported.
export_matrix="false"
# genome scan results.
output_file="julia_result.csv"
# rqtl_file is needed to find gmap.csv.
rqtl_file="./data/HC_M2_0606_R.zip"
# Preserve the sign of original r before squaring? Default is false
r_sign="false"

time JULIA_NUM_THREADS=16 ./bin/MyAppCompiled/bin/MyApp $output_dir $output_file $rqtl_file $export_matrix $r_sign
