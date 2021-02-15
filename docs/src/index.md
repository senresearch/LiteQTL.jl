# LiteQTL.jl Documentation

# Package information
LiteQTL is a package that runs whole genome QTL scans near real-time, utilizing the computation power of GPU. 

# Features
- Near real time computation for whole genome scan using Linear Model
- Genome scan with covairates
- CPU parallelization and GPU acceleration
- Input data can be of different precision (Float32, or Float64)

# Input and Output
### Input (all with no missing data)
- Genotype probability 
- Phenotype
- Covariates (Optional)
### Output 
- (Default) Maximum LOD (Log of Odds) score, and the index of the maximum
- LOD (Log of Odds) matrix

# Example


# Auxilary Github repo

```@index
```

# List of functions
```@autodocs
Modules = [LiteQTL]
```

