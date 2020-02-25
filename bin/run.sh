#!/bin/bash

geno_file="./data/cleandata/geno_prob.csv"
pheno_file="./data/cleandata/imputed_pheno.csv"
export_matrix="false"
output_file="./data/results/output.csv"

time JULIA_NUM_THREADS=8 ./bin/MyAppCompiled/bin/MyApp $geno_file $pheno_file $export_matrix $output_file
