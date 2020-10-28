module LMGPU

#put all external pacakges here.
using DelimitedFiles
using LinearAlgebra
using Base.Threads
using ZipFile
using CUDA


#put all your source file here.
include("data_io.jl")
export get_geno_data, get_pheno_data, get_gmap_file
include("util.jl")
include("cpu.jl")
export cpurun 
include("gpu.jl")
include("common_func.jl")
include("match_gmap_info.jl")
export  get_gmap_info, match_gmap
# include("cli.jl")


end # module
