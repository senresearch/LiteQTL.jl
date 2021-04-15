using LiteQTL
using DelimitedFiles

function main()
    geno_file = joinpath(@__DIR__, "..", "data", "processed", "spleen-bxd-genoprob.csv")
    pheno_file = joinpath(@__DIR__, "..", "data","processed", "spleen-pheno-nomissing.csv")
    export_matrix = true
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
    @time lodc = scan(Y, G, export_matrix=export_matrix, usegpu=false, lod_or_pval="lod");
    # lodg = scan(Y, G; usegpu=true)


    # if !export_matrix
    #     gmap = get_gmap_info(rqtl_file)
    #     idx = trunc.(Int, lod[:,1])
    #     gmap_info = match_gmap(idx, gmap)
    #     lod = hcat(gmap_info, lod)
    #     header = reshape(["marker", "chr", "pos", "idx", "lod"], 1,:)
    #     lod = vcat(header, lod)
    # end

    # write output to file
    # writedlm(joinpath(Base.@__DIR__, "..", "data", "results", output_file), lod, ',')

    # TODO: generate plot?
    # return lod

end


lod = main()
