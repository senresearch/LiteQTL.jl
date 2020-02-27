
function get_geno_data(file)

    geno_prob = convert(Array{Float64,2},readdlm(file, ','; skipstart=1)[:,2:end])
    return geno_prob[:,1:2:end]
end

function get_pheno_data(file)

    #first column is individual ID such as : BXD1
    pheno = readdlm(file, ','; skipstart=1)[:,2:end]
    return convert(Array{Float64,2}, pheno[:, 1:end])
end

# function extract_gmap()
#     # geno_file = readdlm("../data/spleen/BXD_current.geno", ' '; skipstart=21)[:,2:end-1]
#     gmap = readdlm("../data/spleen/BXD_current.geno", '\t'; skipstart=21)[:,1:4]
#     idx = ["id"; collect(1:1:size(gmap,1)-1)]
#     writedlm("../data/spleen/gmap.csv", [idx gmap], ',')
# end
