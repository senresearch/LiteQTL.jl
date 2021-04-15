function calculate_nr(a::AbstractArray{<:Real,2},b::AbstractArray{<:Real, 2})
    return LinearAlgebra.BLAS.gemm('T', 'N', a,b);
end

function is_corr_in_range(r, min, max)
    function inRange(n, min, max)
        if n >= min && n <= max
            return true
        else
            return false
        end
    end

    if all( inRange.(r, min,max) )
        error("Correlation matrix is not in range($min, $max). Check your r matrix again. ")
    end

end
function lod_score_multithread(m,nr::AbstractArray{Float64, 2})
    n = m 
    Threads.@threads for j in 1:size(nr)[2]
        for i in 1:size(nr)[1]
            r_square = (nr[i,j] / n)^2
            tmp = (-n/2.0) * log10(1.0-r_square)
            nr[i,j] = tmp
        end
    end
    return nr
end

function lod_score_multithread(m,nr::AbstractArray{Float32,2})
    n = m 
    Threads.@threads for j in 1:size(nr)[2]
        for i in 1:size(nr)[1]
            r_square = (nr[i,j] / n)^2
            tmp = (-n/2.0f0) * log10(1.0f0-r_square)
            nr[i,j] = tmp
        end
    end
    return nr
end

function lod2p(lod)
    return 1-cdf(Chisq(1),2*log(10)*lod)
end

function pval_calc(corr, dof)
    t = corr .* sqrt.(dof ./ (1 .- corr .^2))
    pval = 2 .* cdf(TDist(dof), .-abs.(t))
    return pval
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
function cpurun(pheno::AbstractArray{<:Real,2}, geno::AbstractArray{<:Real,2}, X::Union{AbstractArray{<:Real, 2}, Nothing}=nothing; maf_threshold=0.05, export_matrix=false, lod_or_pval="lod",timing_file="")
    @debug begin 
        "size(Y) = $(size(Y)), size(G) = $(size(G)). Number of indvidual should be size(Y, 1), or size(G, 1). "
    end
    pval_time = 0.0 
    compute_time = 0.0 
    result_reorg_time = 0.0 
    
    total_start = time_ns()
    start = time_ns()
    G = geno
    Y = pheno
    if maf_threshold > 0 
        println("Filtering MAF")
        G = filter_maf(geno, maf_threshold=maf_threshold)
    end

    n = size(G,1)

    if !isnothing(X) # X is not empty. 
        px = calculate_px(X)
        y_hat = LinearAlgebra.BLAS.gemm('N', 'N', px, Y)
        g_hat = LinearAlgebra.BLAS.gemm('N', 'N', px, G)
        Y = Y .- y_hat
        G = G .- g_hat
    end
    y_std = get_standardized_matrix(Y) 
    g_std = get_standardized_matrix(G)

    nr = calculate_nr(y_std,g_std);
    @debug begin 
        test_r_in_range = is_corr_in_range(nr./n, -1,1)
        "R is in range (-1, 1): $test_r_in_range"
    end
    stop = time_ns()
    compute_time = (stop - start) * 1e-9

    if lod_or_pval == "lod"
        lod = lod_score_multithread(n,nr)
        stop = time_ns()
        compute_time = (stop -start) * 1e-9
        if !export_matrix 
            start = time_ns()
            max = find_max_idx_value(lod)
            stop = time_ns()
            result_reorg_time = (stop - start) * 1e-9
            # return max
        else 
            # return lod
        end
    elseif lod_or_pval == "pval"
        start = time_ns()
        pval = pval_calc(nr ./ n, n-2)
        stop = time_ns()
        pval_time = (stop - start) * 1e-9
        # return pval
    else 
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end 

    total_stop = time_ns()
    elapsed_total = (total_stop - total_start) * 1e-9

    if timing_file != ""
        open("/home/xiaoqihu/git/LiteQTL-G3-supplement/code/tensorqtl/liteqtl_timing_report.txt", "a") do io
            write(io, "$(now()),CPU,NA,$(compute_time),$(result_reorg_time),$(pval_time),$(elapsed_total)\n")
        end   
    end 

    if lod_or_pval == "lod" 
        if export_matrix 
            return lod 
        else 
            return max 
        end
    elseif lod_or_pval == "pval"
        return pval 
    else 
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end

end