function calculate_r(a::AbstractArray{<:Real,2},b::AbstractArray{<:Real, 2})
    return LinearAlgebra.BLAS.gemm('T', 'N', a,b);
end

function lod_score_multithread(m,r::AbstractArray{Float64, 2})
    n = m 
    Threads.@threads for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square = (r[i,j]/n)^2
            tmp = (-n/2.0) * log10(1.0-r_square)
            r[i,j] = tmp
        end
    end
    return r
end

function lod_score_multithread(m,r::AbstractArray{Float32,2})
    n = m 
    Threads.@threads for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square = (r[i,j]/n)^2
            tmp = (-n/2.0f0) * log10(1.0f0-r_square)
            r[i,j] = tmp
        end
    end
    return r
end

"""
$(SIGNATURES)

# Arguments:
- `Y` : a matrix of phenotypes
- `G` : a matrix of genotypes
- `X` : a matrix of covariates
- `n` : the number of individuals
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 

# Output: 
returns the maximum LOD (Log of odds) score if `export_matrix` is false, or LOD score matrix otherwise.

"""

function cpurun_with_covar(Y::AbstractArray{<:Real,2}, G::AbstractArray{<:Real,2}, X::AbstractArray{<:Real,2}, n::Int, export_matrix::Bool)
    @info "Running genome scan with covariates..."
    px = calculate_px(X)
    # display(px)
    y_hat = LinearAlgebra.BLAS.gemm('N', 'N', px, Y)
    g_hat = LinearAlgebra.BLAS.gemm('N', 'N', px, G)
    y_tilda = Y .- y_hat
    g_tilda = G .- g_hat
    y_std = get_standardized_matrix(y_tilda)
    g_std = get_standardized_matrix(g_tilda)
    r = calculate_r(y_std, g_std)
    lod = lod_score_multithread(n, r)
    if !export_matrix 
        println("Calculating max lod")
        return find_max_idx_value(lod)
    else 
        println("Exporting matrix.")
        return lod
    end

end


function find_max_idx_value(lod::AbstractArray{<:Real,2})
    res = findmax(lod, dims=2)
    # get the first element, which is the max of the first dimension, and turn it into a column
    max = res[1]
    # get the second element, which is the cartisian index, and only get the first index of the tuple(cartisian index), and turn it into column
    maxidx = getindex.(res[2], 2)
    return hcat(maxidx, max)
end


##################### Running CPU Function ###################
"""
$(SIGNATURES)

# Arguments:
- `Y` : a matrix of phenotypes
- `G` : a matrix of genotypes
- `n` : the number of individuals
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 

# Output: 
returns the maximum LOD (Log of odds) score if `export_matrix` is false, or LOD score matrix otherwise.

"""
function cpurun(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2}, n::Int, export_matrix::Bool)
    @info "Running genome scan..."
    pheno_std = get_standardized_matrix(Y);
    geno_std = get_standardized_matrix(G);
    #step 2: calculate R, matrix of corelation coefficients
    r = calculate_r(pheno_std,geno_std);
    @info "Done calculating corelation coefficients."
    #step 3: calculate r square and lod score
    # lod = lod_score(n, r);
    lod = lod_score_multithread(n,r)
    @info "Done calculating LOD. "

    if !export_matrix 
        println("Calculating max lod")
        return find_max_idx_value(lod)
    else 
        println("Exporting matrix.")
        return lod
    end


end
