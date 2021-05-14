

"""
$(SIGNATURES)

This function is the main API for eQTL scans. EQTL scan process includes
    If no covariate: 
    - filter maf if the threshold is greater than 0
    - standardizing phenotype matrix (Y) and genotype matrix (G)
    - calculate correlation (R) matrix. 
    - computes log of odds (LOD) score matrix, or p-value if `lod_or_pval` is set to `lod`
    - calculate maximum LOD score if `export_matrix` is set to false. 
    
    If covariates exists:
    - calculate px 
    - computes Y hat and G hat by matrix multiplication. 
    - substract Y hat and G hat from Y and G respectively. 
    - filter maf if the threshold is greater than 0
    - standardizing phenotype matrix (Y) and genotype matrix (G)
    - calculate correlation (R) matrix. 
    - computes log of odds (LOD) score matrix, or p-value if `lod_or_pval` is set to `lod`
    - calculate maximum LOD score if `export_matrix` is set to false. 
    
    
# Arguments:
- `Y` : a matrix of phenotypes.
- `G` : a matrix of genotypes.
- `X` : a matrix of covariates. Default is `nothing`. If `nothing`, scan is run without covariates. 
- `maf_threshold`: a floating point number to indicate the maf_threshold. Default is 0.05. Set to 0 if no maf filtering should be done. 
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 
- `usegpu` : a boolean value that indicates whether to run scan function on GPU or CPU. Default is false, which runs scan on CPU. 
- `lod_or_pval`: a string value of either `lod` or `pval` to indicate the desired output. 
- `timing_file`: a string that indicates the file location for the timing outputs. Default is nothing. 
# Output: 
returns LOD score or pval, in vector or matrix format depending on value of `export_matrix`. 
"""
function scan(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2},  X::Union{AbstractArray{<:Real, 2}, Nothing}=nothing; maf_threshold=0.05, export_matrix=false, usegpu=false, lod_or_pval="lod", timing_file="")
    if usegpu
        # TODO: return p-value functionality implementation in GPU. 
        return LiteQTL.gpurun(Y, G, X, maf_threshold=maf_threshold, export_matrix=export_matrix, timing_file=timing_file)
    end

    return LiteQTL.cpurun(Y,G,X, maf_threshold=maf_threshold, export_matrix = export_matrix, lod_or_pval = lod_or_pval, timing_file=timing_file)
end
