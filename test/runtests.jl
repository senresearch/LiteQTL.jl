using LMGPU
using Test
using SafeTestsets

# @testset "LMGPU.jl" begin
#     # Write your own tests here.
#
# end

@safetestset "testing reading data" begin include("read_data_test.jl") end
