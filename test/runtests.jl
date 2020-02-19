using LMGPU
using Test
using SafeTestsets

# @testset "LMGPU.jl" begin
#     # Write your own tests here.
#
# end

@safetestset "testing data io" begin include("data_io_test.jl") end
