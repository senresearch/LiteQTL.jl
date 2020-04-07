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
    @info "getting args"
    output_dir = args[1]
    output_file = args[2]
    rqtl_file = args[3]
    export_matrix = args[4] == "true"
    r_sign = args[5] == "true"

    @info "getting geno file and pheno file"
    geno_file = joinpath(output_dir,"geno_prob.csv")
    pheno_file = joinpath(output_dir, "pheno.csv")
    output_file = joinpath(output_dir, output_file)

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
    lod = LMGPU.cpurun(Y, G,n,export_matrix, r_sign);
    if !export_matrix
        gmap = LMGPU.get_gmap_info(rqtl_file)
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
    return lod

end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

end # module
