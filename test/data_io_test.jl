using LMGPU
using Test
using DelimitedFiles

fake_data = rand(100,100)

open("/tmp/delim_file.csv", "w") do io
    writedlm(io, fake_data)
end;

# just testing the return type is Float64.
@test typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_geno_data("/tmp/delim_file.csv")) <: Array{Float32,2}
@test typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float64,2} || typeof(get_pheno_data("/tmp/delim_file.csv")) <: Array{Float32,2}



# data_dir = joinpath(Base.@__DIR__, "..", "data", )
# genofile = joinpath(data_dir, "geno_prob.csv")

# @test typeof(LMGPU.get_geno_data(genofile)) <: Array{Float64,2} || Array{Float32,2}
