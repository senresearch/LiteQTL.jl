using LMGPU # always your module
using Test # and of course the test package.


@testset "LMGPU.jl" begin
    # Write your own tests here.
    include("rqtl_test.jl")
end

# # @test "testing data io" begin include("data_io_test.jl") end
# @test "testing against R/qtl2" begin  end
