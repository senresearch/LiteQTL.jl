
function get_geno_data(file, datatype)

    geno_prob = convert(Array{datatype,2},readdlm(file, ','; skipstart=1))
    return geno_prob[:,1:2:end]
end

# function get_pheno_data(file, datatype)

#     #first column is individual ID such as : BXD1
#     pheno = readdlm(file, ','; skipstart=1)
#     return convert(Array{datatype,2}, pheno)
# end


function get_pheno_data(file, datatype; transposed=true)

    #first column is individual ID such as : BXD1
    pheno = readdlm(file, ','; skipstart=1)[:,2:end]
    pheno = convert(Array{datatype,2}, pheno)
    # pheno = convert2float.(pheno, datatype)
    if transposed 
        return transpose(pheno) |> collect
    else 
        return pheno
    end

end

function convert2float(a, datatype)
    if a == "NA"
        return missing 
    else 
        return convert(datatype, a)
    end
end

