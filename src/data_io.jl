
function get_geno_data(file)
    # The following two commnet lines shows how genotype file is processed originally in test.jl.
    # G_prob = convert(Array{Float32,2},readdlm("../data/hippocampus-genopr-AA-BB.csv", ','; skipstart=1)[:,2:end])
    # G = G_prob[:, 1:2:end]

    geno_prob = convert(Array{Float32,2},readdlm(file, ','; skipstart=1)[:,2:end])
    return geno_prob[:,1:2:end]
end

function get_pheno_data(file)
    # The following two commnet lines shows how phenotype file is processed originally in test.jl.
    # pheno = readdlm("../data/hippocampus-pheno-nomissing.csv", ','; skipstart=1)[:,2:end-1]
    # Y = convert(Array{Float32,2}, pheno[:, 1:end])

    pheno = readdlm(file, ','; skipstart=1)[:,2:end-1]
    return convert(Array{Float32,2}, pheno[:, 1:end])

end

# function extract_gmap()
#     # geno_file = readdlm("../data/spleen/BXD_current.geno", ' '; skipstart=21)[:,2:end-1]
#     gmap = readdlm("../data/spleen/BXD_current.geno", '\t'; skipstart=21)[:,1:4]
#     idx = ["id"; collect(1:1:size(gmap,1)-1)]
#     writedlm("../data/spleen/gmap.csv", [idx gmap], ',')
# end
