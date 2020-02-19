using LMGPU
using Test

fake_data = rand(100,100)
io = IOBuffer()

write(io, fakedata)

read(io, Float64)


# data_dir = joinpath(Base.@__DIR__, "..", "data", )
# genofile = joinpath(data_dir, "geno_prob.csv")

# @test typeof(LMGPU.get_geno_data(genofile)) <: Array{Float64,2} || Array{Float32,2}
