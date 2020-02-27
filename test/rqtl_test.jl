using LMGPU
using Test
using DelimitedFiles
using LinearAlgebra
include(joinpath(@__DIR__, "..", "src", "cpu.jl"))

# readdlm(file, ','; skipstart=1)[:,2:end-1]
rqtl_result_file = joinpath(@__DIR__, "..", "data", "results", "rqtl2_lod_score.csv")
rqtl_result = readdlm(rqtl_result_file, ','; skipstart=1)
rqtl_result_float = convert(Array{Float64,2}, rqtl_result[:,2:end])
tmp = zeros(size(rqtl_result_float)[2], size(rqtl_result_float)[1])
rqtl_max_array = find_max_idx_value(transpose!(tmp, rqtl_result_float))
display(rqtl_max_array[1:10,:])


julia_result_file = joinpath(@__DIR__, "..", "data", "results", "output.csv")
julia_result = readdlm(julia_result_file, ','; skipstart=1)[:,4:5]
display(julia_result[1:10,:])

# # just testing the return type is Float64.
# @test typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float32,2}
# @test typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float32,2}
plot(rqtl_max_array[:,2], julia_result[:,2])
