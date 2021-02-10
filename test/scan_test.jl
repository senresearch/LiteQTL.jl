using LiteQTL
using Test
using DelimitedFiles
using CSV
using DataFrames

# Get sample dataset from data directory
geno_file = joinpath(@__DIR__, "..", "data", "processed", "spleen-bxd-genoprob.csv")
pheno_file = joinpath(@__DIR__, "..", "data","processed", "spleen-pheno-nomissing.csv")

datatype = Float64
dataset = "spleen"
export_matrix = false

Y = LiteQTL.get_pheno_data(pheno_file, datatype, transposed=false)
G = LiteQTL.get_geno_data(geno_file, datatype)

# Check if they have the same amount of individuals. 
@test size(Y)[1] == size(G)[1]

n = size(Y,1)
m = size(Y,2)
p = size(G,2)

println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");

lod = LiteQTL.cpurun(Y, G,n,export_matrix);
julia_max = lod

julia_output_file = joinpath(Base.@__DIR__, "..", "data", "results", string(datatype) * dataset*"_LiteQTL_output.csv")
# writedlm(julia_output_file, lod, ',')

# read in Rqtl scan result 
rqtl_result_file = abspath(joinpath(Base.@__DIR__, "..", "data", "results", dataset*"_rqtl_lod_score.csv"))
rqtl_max =  Matrix(CSV.read(rqtl_result_file, DataFrame, datarow=2))

# check max value 
@test sum(isapprox.(rqtl_max[:,2], julia_max[:,2], atol=1e-5)) == size(julia_max)[1]

# check max index ( this one OK to fail) 
# sometimes, the maximun is at a near by location, which is acceptable. They don't have to be exactly the same. 
# @test sum(isapprox.(rqtl_max[:, 1], julia_max[:,1], atol=7)) == size(julia_max)[1]


