
"""
$(SIGNATURES)
returns the genotype data. Will skip every other column because genotype probability is duplicated. 

"""
function get_geno_data(file, datatype)

    geno_prob = convert(Array{datatype,2},readdlm(file, ','; skipstart=1))
    return geno_prob[:,1:2:end]
end

# function try_string2num(num)
#     return tryparse(Float64,num) != nothing
# end

"""
$(SIGNATURES)
returns the phenotype data. If transposed=true, then the data will be transposed. 

"""
function get_pheno_data(file, datatype; transposed=true)

    #first column is individual ID such as : BXD1 , need to be removed. 
    pheno = readdlm(file, ','; skipstart=1)[:, 2:end]

    if pheno[1,end] == "f" || pheno[1,end] == "m"
        @info "Removing sex column of phenotype. "
        pheno = pheno[:, 1:end-1]
        
    end

    pheno = convert(Array{datatype,2}, pheno)

    if transposed 
        return transpose(pheno) |> collect
    else 
        return pheno
    end

end

"""
$(SIGNATURES)
Filter genotype data with a minor allele frequency threshold. 

# Arguments
- `genotype` : genotype matrix
- `maf_threshold` : default value is 0.05. 

# Output: 
returns filtered genotype matrix. 

"""
function filter_maf(genotype::Array{<:Real, 2}; maf_threshold=0.05)
    alleles = 2
    
    af = sum(genotype, dims=1) ./ (alleles * size(genotype, 1))
    maf = replace(x -> x > 0.5 ? 1-x : x, af)

    if maf_threshold > 0 
        mask = vec(maf .>= maf_threshold)
        if size(mask,1) != size(genotype, 2)
            error("Mask dimention does not match original matrix. Mask size: $(size(mask)), Matrix size: $(size(genotype))")
        end
        newgenotype = genotype[:, mask]
    end
    return newgenotype
end
