using LMGPU
using Test
using DelimitedFiles
using LinearAlgebra

URL=joinpath(@__DIR__, "..", "data", "HC_M2_0606_R.zip")
output_dir=joinpath(@__DIR__, "..", "data","HIPPO_CLEAN_DATA")
scan="FALSE"
r_cleaning_script = joinpath(@__DIR__, "..", "r", "cleaning.R")

@test isfile(URL)
@test isfile(r_cleaning_script)

run(`Rscript --vanilla $r_cleaning_script $URL $output_dir $scan`)
#
export_matrix="false"
output_file="julia_result.csv"
# rqtl_file is needed to find gmap.csv.
rqtl_file=URL
r_sign="false"
julia_scan_script = joinpath(@__DIR__, "..", "bin", "MyApp", "src", "MyApp.jl")

run(`julia $julia_scan_script $output_dir $output_file $rqtl_file $export_matrix $r_sign`)

# readdlm(file, ','; skipstart=1)[:,2:end-1]
@info "Getting Rqtl scan results"
rqtl_result_file = joinpath(output_dir, "rqtl_result.csv")
rqtl_result = readdlm(rqtl_result_file, ','; skipstart=1)
rqtl_result_float = convert(Array{Float64,2}, rqtl_result[:,2:end])
tmp = zeros(size(rqtl_result_float)[2], size(rqtl_result_float)[1])
rqtl_max_array = find_max_idx_value(transpose!(tmp, rqtl_result_float))

@info "Getting Julia scan results"
julia_result_file = joinpath(output_dir, "julia_result.csv")
julia_result = readdlm(julia_result_file, ','; skipstart=1)[:,4:5]

# compare indexes
@info "Comparing both index and lod score"
rqtl_idx = trunc.(Int, rqtl_max_array[:,1])
julia_idx = convert(Array{Int64,1}, julia_result[:,1])

@info "Do the indices and lod scores match at least 95 percent?"
@test sum(isapprox.(rqtl_idx, julia_idx, atol=3)) >= size(rqtl_idx)[1] * 0.95
@test sum(isapprox.(rqtl_max_array[:,2], abs.(julia_result[:,2]), atol=0.00001)) >= size(rqtl_idx)[1] * 0.95
