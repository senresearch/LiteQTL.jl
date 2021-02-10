using LiteQTL # always your module
using Test # and of course the test package.


@testset "LiteQTL.jl" begin
    # Write your own tests here.
    # include("download_data.jl")
    # run(`Rscript --vanilla clean_data.R`)
    # run(`Rscript --vanilla rqtl2scan.R`)
    include("scan_test.jl")
end

# # @test "testing data io" begin include("data_io_test.jl") end
# @test "testing against R/qtl2" begin  end
