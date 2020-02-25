using LMGPU
using Test
using DelimitedFiles
include(joinpath(@__DIR__, "..", "src", "cpu.jl"))

# readdlm(file, ','; skipstart=1)[:,2:end-1]
rqtl_result_file = joinpath(@__DIR__, "..", "data", "results", "rqtl_lod_score.csv")
rqtl_result = readdlm(rqtl_result_file, ','; skipstart=1)
rqtl_result_float = convert(Array{Float64,2}, rqtl_result[:,2:end])
find_max_idx_value(rqtl_result_float)
display(rqtl_result_float[:,1])


# julia_result_file = joinpath(@__DIR__, "..", "data", "results", "output.csv")
# julia_result = readdlm(julia_result_file, ',')

#
# open("/tmp/delim_file.csv", "w") do io
#     writedlm(io, fake_data)
# end;
#
# # just testing the return type is Float64.
# @test typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float32,2}
# @test typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float32,2}
