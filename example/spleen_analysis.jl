using LMGPU
using DelimitedFiles

function main()
    # if no input args.
    geno_file = joinpath(@__DIR__, "..", "data", "SPLEEN_CLEAN_DATA", "geno_prob.csv")
    pheno_file = joinpath(@__DIR__, "..", "data","SPLEEN_CLEAN_DATA", "pheno.csv")
    export_matrix = false
    output_file = "output.csv"
    rqtl_file = joinpath(@__DIR__, "..", "data", "UTHSC_SPL_RMA_1210.zip")

    LMGPU.set_blas_threads(16);
    # Read in data.
    G = LMGPU.get_geno_data(geno_file, Float64)
    Y = LMGPU.get_pheno_data(pheno_file, Float64)
    # getting geno and pheno file size.
    n = size(Y,1)
    m = size(Y,2)
    p = size(G,2)
    println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");
    # cpu_timing = benchmark(5, cpurun, Y, G,n,export_matrix);
    # println("CPU timing: $(cpu_timing[3])")

    # running analysis.
    @time lodc = LMGPU.cpurun(Y, G,n,export_matrix);
    # lodg = LMGPU.gpurun(Y, G,n,m,p)

    display(lodc[1:20, 1:2])
    # display(lodg[1:20, 1:2])

    # if !export_matrix
    #     gmap = LMGPU.get_gmap_info(rqtl_file)
    #     idx = trunc.(Int, lod[:,1])
    #     gmap_info = LMGPU.match_gmap(idx, gmap)
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
