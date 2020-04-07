
function get_geno_data(file)

    geno_prob = convert(Array{Float64,2},readdlm(file, ','; skipstart=1)[:,2:end])
    return geno_prob[:,1:2:end]
end

function get_pheno_data(file)

    #first column is individual ID such as : BXD1
    pheno = readdlm(file, ','; skipstart=1)[:,2:end]
    return convert(Array{Float64,2}, pheno[:, 1:end])
end
