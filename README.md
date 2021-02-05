# LMGPU

[![Build Status](https://travis-ci.com/senresearch/LMGPU.jl.svg?branch=master)](https://travis-ci.com/senresearch/LMGPU.jl)
[![Codecov](https://codecov.io/gh/senresearch/LMGPU.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/senresearch/LMGPU.jl)
[![Coveralls](https://coveralls.io/repos/github/senresearch/LMGPU.jl/badge.svg?branch=master)](https://coveralls.io/github/senresearch/LMGPU.jl?branch=master)

LMGPU is a package that runs whole genome QTL scans near real-time, utilizing the computation power of GPU. 

LMGPU uses new algorithms that enables near-real time whole genome QTL scans for up to 1 million traits.
By using easily parallelizable operations including matrix multiplication, vectorized operations,
and element-wise operations, our method is about 300 times faster than a R/qtl linear model genome scan
using 16 threads.

## Paper: 
To find out more about methods used and also acceleration techniques, please refer to our paper on Biorxiv: 

Chelsea Trotter, Hyeonju Kim, Gregory Farage, Pjotr Prins, Robert W. Williams, Karl W. Broman, and Saunak Sen.  
[Speeding up eQTL scans in the BXD population using GPUs](https://www.biorxiv.org/content/10.1101/2020.06.22.153742v1.full.pdf). 

## How to use LMGPU: 
This package is developed in Julia. To add LMGPU to your Julia installation:
```julia
julia> using Pkg; 
julia> Pkg.add(url="https://github.com/senresearch/LMGPU.jl")
```
To run the example provided by LMGPU:
```julia
julia> using LMGPU
julia> include("./example/spleen_analysis.jl")
```

For more examples on how to use LMGPU, please take a look at this [example](https://github.com/senresearch/LMGPU.jl/blob/master/example/spleen_analysis.jl) file.

## Auxiliary Repositories:
- #### [LMGPU_Bin](https://github.com/senresearch/lmgpu_bin)    
This repo contais scripts to compile the LMGPU package to remove the compilation time of Julia (the extra time in the first run in Julia REPL).   
- #### [LMGPU G3 Supplement](https://github.com/senresearch/LMGPU-G3-supplement)  
It is an effort to make our research reproducible. All code related to experiment reuslt, from dowloading data, cleaning data, to running LMGPU and creating figure are found in this repository. You can recreate the results in our paper [Speeding up eQTL scans in the BXD population using GPUs](https://www.biorxiv.org/content/10.1101/2020.06.22.153742v1.full.pdf) using the scripts in this repository. 

