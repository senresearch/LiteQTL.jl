module MyApp


using LMGPU
using DelimitedFiles

function julia_main()
    try
        main()
    catch
        Base.invokelatest(Base.display_error, Base.catch_stack())
        return 1
    end
    return 0
end


function main()
    
    args = ARGS

    geno_file = args[1]
    pheno_file = args[2]
    export_matrix = args[3] == "true"
    output_file = args[4]
    rqtl_file = args[5]

    LMGPU.set_blas_threads(16);
    # Read in data.
    G = LMGPU.get_geno_data(geno_file)
    Y = LMGPU.get_pheno_data(pheno_file)
    # getting geno and pheno file size.
    n = size(Y,1)
    m = size(Y,2)
    p = size(G,2)
    println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");
    # cpu_timing = benchmark(5, cpurun, Y, G,n,export_matrix);

    # running analysis.
    lod = LMGPU.cpurun(Y, G,n,export_matrix);
    if !export_matrix
        gmap = LMGPU.get_gmap_info(rqtl_file, "gmap.csv")
        idx = trunc.(Int, lod[:,1])
        gmap_info = LMGPU.match_gmap(idx, gmap)
        lod = hcat(gmap_info, lod)
        header = reshape(["marker", "chr", "pos", "idx", "lod"], 1,:)
        lod = vcat(header, lod)
    end

    # write output to file
    writedlm(output_file, lod, ',')
    println("Lod exported to $output_file")

    # TODO: generate plot?
    # return lod

end

if abspath(PROGRAM_FILE) == @__FILE__
    real_main()
end

end # module
