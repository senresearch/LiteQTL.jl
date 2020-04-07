# Documentation for the command line interface of LMGPU
This documentation describes what happens in `LMGPU/sh/rqtl-julia.sh`. The script assumes you are in LMGPU directory, not in any of the sub directory.

The command-line interface is divided into two parts: data cleaning and genome scan.

## Data cleaning
Data cleaning uses R and qtl2 package. The R script that does the cleaning is `r/cleaning.R`.

It takes three arguments.
- URL: rqtl2 expects input to be in rqtl2 format. For more information about rqlt2 format, visit [rqtl2 documentation](https://kbroman.org/qtl2/assets/vignettes/input_files.html). Note: In Karl's documentation, you can pass either a zip file or yaml file as the input and it will parse the file. This would be ok with the cleaning file, but in the next step, julia only takes .zip file as an acceptable input.
- output directory: The location of all intermediate and final results. This cleaning step will generate `geno_prob.csv` and `pheno.csv` and store them in that diretory.
- scan: Default is false for data cleaning. Only set to true if you need to let rqlt2 run genome scan and output its result, to be able to compare with the julia result generated from next step.


## Genome scan
Genome scan uses julia and LMGPU package. You can use just the julia scripts to run genome scan. However, in order to reduce compile time, I have also writen code to build binary. Details about how to build your binary will come later. For now, the binary is `LMGPU/bin/MyAppCompiled/bin/MyApp`.

The binary takes 5 arguments.
- output directory: this is the same as the previous data cleaning step. LMGPU expect `geno_prov.csv` and `pheno.csv` to be in this folder, and will also export final genome scan result here, with the file name specified by next argument.
- output file: this is the name of genome scan result. The content depends on `export_matrix` and `r_sign`.  
- export_matrix: Default is false. If true, Julia will write the entire LOD score matrix. If false, only maximum LOD score for every phenotype are exported, with corresponding gmap information. This option will reduce I/O time which was a significant bottleneck for performance.
- R_sign. Default is false. If set to true, the sign of R before squaring to get the LOD score will be prepended to the final LOD score result. Since the sign of LOD score will always be positive, we put the sign in front of the lod score. I am not very keen about this design. 1) Because this design has resulted more complicated arithmetic in finding the maximum lod score, I think I might change back to just have a boolean array to hold the signbit, to trade for possibly faster calculation. 2) this design is not standard. People expecting positive LOD scores may be thrown off by the negative number. 



## Things that will make this command-line interface better:
- modify the scripts so they can run anywhere, not just from LMGPU directory.
- Let julia genome scan accepts yaml file as a rqtl2 format input or just gmap file. Currently it only accepts .zip file, it would be better if you can also just pass in the gmap file. This feature will become necessary if we have missing data in geno file and need to insert pseudo-markers, because then, gmap file will be updated.
- Let user choose their own file name for `geno_prob.csv` and `pheno.csv`
