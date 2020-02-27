#!/bin/bash

URL="../data/UTHSC_SPL_RMA_1210.zip"
geno_output_file="../data/SPLEEN_CLEAN_DATA/geno_prob.csv"
pheno_output_file="../data/SPLEEN_CLEAN_DATA/pheno.csv"
new_gmap_file="../data/SPLEEN_CLEAN_DATA/gmap.csv"
rqtl_result_file="../data/results/rqtl2_lod_score.csv"

Rscript --vanilla ../r/cleaning.R $URL $geno_output_file $pheno_output_file $new_gmap_file $rqtl_result_file
