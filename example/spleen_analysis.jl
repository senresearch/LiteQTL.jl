using LiteQTL
using DelimitedFiles
using CSV
using DataFrames 

function main()
    geno_file = joinpath(@__DIR__, "..", "data", "processed", "spleen-bxd-genoprob.csv")
    pheno_file = joinpath(@__DIR__, "..", "data","processed", "spleen-pheno-nomissing.csv")
    gmap_file = joinpath(@__DIR__, "..", "data","processed", "gmap.csv")
    export_matrix = false
    output_file = "output.csv"
    rqtl_file = joinpath(@__DIR__, "..", "data", "UTHSC_SPL_RMA_1210.zip")

    LiteQTL.set_blas_threads(16);
    # Read in data.
    G = get_geno_data(geno_file, Float64)
    Y = get_pheno_data(pheno_file, Float64, transposed=false)
    # getting geno and pheno file size.
    n = size(Y,1)
    m = size(Y,2)
    p = size(G,2)
    println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");
    # cpu_timing = benchmark(5, scan, Y, G, n; export_matrix);
    # println("CPU timing: $(cpu_timing[3])")

    # running analysis without covariates.
    @time lodc = scan(Y, G, export_matrix=export_matrix, maf_threshold=0.00, usegpu=false, lod_or_pval="lod");
    # lodg = scan(Y, G; usegpu=true)

    

    if !export_matrix 
        gmap = CSV.read(gmap_file, DataFrame)
        idx = trunc.(Int, lodc[:,1])
        gmap_lod = hcat(gmap[idx,:], DataFrame(lodc, [:idx, :maxlod]))
    end

    # write output to file
    # writedlm(joinpath(Base.@__DIR__, "..", "data", "results", output_file), lod, ',')

    # TODO: generate plot?
    # return lod

end


lod = main()
