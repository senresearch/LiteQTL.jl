"""
$(SIGNATURES)

This function will run genome scan without covariates.

# Arguments:
- `Y` : a matrix of phenotypes
- `G` : a matrix of genotypes
- `n` : the number of individuals
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 
- `usegpu` : a boolean value that indicates whether to run scan function on GPU or CPU. Default is false, which runs scan on CPU. 

# Output: 
calls `cpurun` function if `usegpu=false`, otherwise, calls `gpurun`
"""
function scan(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2}, n::Int; export_matrix::Bool=false, usegpu::Bool=false)
    if usegpu
        return LiteQTL.gpurun(Y, G, n)
    end

    return LiteQTL.cpurun(Y,G,n,export_matrix)
end

"""
$(SIGNATURES)

This scan function will run 

# Arguments:
- `Y` : a matrix of phenotypes
- `G` : a matrix of genotypes
- `X` : a matrix of covariates
- `n` : the number of individuals
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 
- `usegpu` : a boolean value that indicates whether to run scan function on GPU or CPU. Default is false, which runs scan on CPU. 

# Output: 
returns the maximum LOD (Log of odds) score if `export_matrix` is false, or LOD score matrix otherwise.
"""
function scan(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2},  X::AbstractArray{<:Real, 2}, n::Int; export_matrix::Bool=false, usegpu::Bool=false)
    if usegpu
        return LiteQTL.gpurun(Y, G, X, n)
    end

    return LiteQTL.cpurun(Y,G,X,n,export_matrix)

end