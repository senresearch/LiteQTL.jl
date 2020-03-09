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


julia_result_file = joinpath(@__DIR__, "..", "data", "results", "output.csv")
julia_result = readdlm(julia_result_file, ','; skipstart=1)[:,4:5]

# compare indexes
rqtl_idx = trunc.(Int, rqtl_max_array[:,1])
julia_idx = convert(Array{Int64,1}, julia_result[:,1])

@test sum(isapprox.(rqtl_idx, julia_idx, atol=3)) >= size(rqtl_idx)[1] * 0.95
@test sum(isapprox.(rqtl_max_array[:,2], julia_result[:,2], atol=0.00001)) >= size(rqtl_idx)[1] * 0.95
