# LiteQTL.jl Documentation

# Package information
LiteQTL is a package that runs whole genome QTL scans near real-time, utilizing the computation power of GPU. 

# Features
- Near real time computation for whole genome scan using Linear Model
- Genome scan with covairates
- CPU parallelization and GPU acceleration
- Input data can be of different precisions (Float32, or Float64)

# Input and Output
### Input (all with no missing data)
- Genotype probability 
- Phenotype
- Covariates (Optional)
### Output 
- (Default) Maximum LOD (Log of Odds) score, and the index of the maximum
- LOD (Log of Odds) matrix

# Example
See `example/spleen_analysis.ipynb`

# Auxilary Github Repositories

- [LiteQTL.jl Binary Compilation](https://github.com/senresearch/LiteQTL_bin)
This repo contais scripts to compile the LiteQTL package to remove the compilation time of Julia (the extra time in the first run in Julia REPL).

- [LiteQTL.jl G3 Journal Supplemental Materials](https://github.com/senresearch/LiteQTL-G3-supplement)
It is an effort to make our research reproducible. All code related to experiment reuslt, from dowloading data, cleaning data, to running LiteQTL and creating figure are found in this repository. You can recreate the results in our paper [Speeding up eQTL scans in the BXD population using GPUs](https://www.biorxiv.org/content/10.1101/2020.06.22.153742v1) using the scripts in this repository.




