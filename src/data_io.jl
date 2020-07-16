
function get_geno_data(file, datatype)

    geno_prob = convert(Array{datatype,2},readdlm(file, ','; skipstart=1)[:,2:end])
    return geno_prob[:,1:2:end]
end

function get_pheno_data(file, datatype)

    #first column is individual ID such as : BXD1
    pheno = readdlm(file, ','; skipstart=1)[:,2:end]
    return convert(Array{datatype,2}, pheno[:, 1:end])
end
