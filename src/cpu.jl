function calculate_r(a::AbstractArray{<:Real,2},b::AbstractArray{<:Real, 2})
    return LinearAlgebra.BLAS.gemm('T', 'N', a,b) ./ size(a, 1);
end

function is_corr_in_range(r, min, max)
    function inRange(n, min, max)
        if n >= min && n <= max
            return true
        else
            return false
        end
    end

    if sum( inRange.(r, min,max) ) < prod(size(r))
        error("Correlation matrix is not in range($min, $max). Check your r matrix again. ")
    end

end
function lod_score_multithread(m,r::AbstractArray{Float64, 2})
    n = m 
    Threads.@threads for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square = (r[i,j])^2
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
            r_square = (r[i,j])^2
            tmp = (-n/2.0f0) * log10(1.0f0-r_square)
            r[i,j] = tmp
        end
    end
    return r
end

function lod2p(lod)
    return 1-cdf(Chisq(1),2*log(10)*lod)
end

function pval_calc(corr, dof)
    t = corr .* sqrt.(dof ./ (1 .- corr .^2))
    pval = 2 .* cdf(TDist(dof), .-abs.(t))
    return pval
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
function cpurun(Y::AbstractArray{<:Real,2}, G::AbstractArray{<:Real,2}, X::AbstractArray{<:Real,2}, n::Int, export_matrix::Bool,lod_or_pval::String, debug::Bool=true)
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
    if debug
        is_corr_in_range(r, -1,1)
    end
    if lod_or_pval == "lod"
        lod = lod_score_multithread(n, r)
        if !export_matrix 
            println("Calculating max lod")
            return find_max_idx_value(lod)
        else 
            println("Exporting matrix.")
            return lod
        end
    elseif lod_or_pval == "pval"
        return pval_calc(r, n-2)
    else
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end
end

# function pval_calc(corr, dof)
#     t = corr .* sqrt.(dof ./ (1 .- corr .^2))
#     pval = 2 .* cdf(TDist(dof), .-abs.(t))
#     return pval
# end

# function find_max_idx_value(lod::AbstractArray{<:Real,2})
#     res = findmax(lod, dims=2)
#     # get the first element, which is the max of the first dimension, and turn it into a column
#     max = res[1]
#     # get the second element, which is the cartisian index, and only get the first index of the tuple(cartisian index), and turn it into column
#     maxidx = getindex.(res[2], 2)
#     return hcat(maxidx, max)
# end

function find_max_idx_value(lod::AbstractArray{<:Real,2})
    max_array = Array{typeof(lod[1,1]),2}(undef, size(lod)[1], 2)
    Threads.@threads for i in 1:size(lod)[1]
        # for i in 1:size(lod)[1]
        temp = lod[i, 1]
        idx = 1
        for j in 2:size(lod)[2]
            if temp < lod[i,j]
                temp = lod[i,j]
                idx = j
            end
        end
        max_array[i,1] = idx
        max_array[i,2] = temp
    end
    return max_array
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
function cpurun(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2}, n::Int, export_matrix::Bool, lod_or_pval::String, debug::Bool=true)
    @info "Running genome scan..."
    pheno_std = get_standardized_matrix(Y);
    geno_std = get_standardized_matrix(G);
    #step 2: calculate R, matrix of corelation coefficients
    r = calculate_r(pheno_std,geno_std);
    if debug
        is_corr_in_range(r, -1,1)
    end
    @info "Done calculating corelation coefficients."
    #step 3: calculate r square and lod score
    if lod_or_pval == "lod"
        lod = lod_score_multithread(n,r)
        @info "Done calculating LOD. "

        if !export_matrix 
            println("Calculating max lod")
            return find_max_idx_value(lod)
        else 
            println("Exporting matrix.")
            return lod
        end
    elseif lod_or_pval == "pval"
        return pval_calc(r, n-2)
    else 
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end

end
