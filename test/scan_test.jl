using LMGPU
using Test
using DelimitedFiles
using CSV

# Get sample dataset from data directory
geno_file = joinpath(@__DIR__, "..", "data", "SPLEEN_CLEAN_DATA", "geno_prob.csv")
pheno_file = joinpath(@__DIR__, "..", "data","SPLEEN_CLEAN_DATA", "pheno.csv")

datatype = Float64
dataset = "spleen"
export_matrix = false

Y = LMGPU.get_pheno_data(pheno_file, datatype, transposed=false)
G = LMGPU.get_geno_data(geno_file, datatype)

# Check if they have the same amount of individuals. 
@test size(Y)[1] == size(G)[1]

n = size(Y,1)
m = size(Y,2)
p = size(G,2)

println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");

lod = LMGPU.cpurun(Y, G,n,export_matrix);

julia_output_file = joinpath(Base.@__DIR__, "..", "data", "results", string(datatype) * dataset*"_lmgpu_output.csv")
writedlm(julia_output_file, lod, ',')

# read in Rqtl scan result 
rqtl_result_file = joinpath(Base.@__DIR__, "..", "data", "results", dataset*"_rqtl_lod_score.csv")
rqtl_result =  CSV.read(rqtl_result_file, datarow=2)

# check max value 
@test isapprox.(rqtl_max[:,2], julia_max[:,2], atol=1e-5)

# check max index 
@test rqtl_max[:, 1] .!= julia_max[:,1]


