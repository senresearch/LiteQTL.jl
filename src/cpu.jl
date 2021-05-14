"""
$(SIGNATURES)
Computes correlation matrix (R) * n. n is not removed because of performance choice. 

# Arguments
- `a` : standardized phenotype matrix
- `b` : standardized genotype matrix

# Output: 
returns correlation matrix R 

"""
function calculate_nr(a::AbstractArray{<:Real,2},b::AbstractArray{<:Real, 2})
    return LinearAlgebra.BLAS.gemm('T', 'N', a,b);
end

"""
$(SIGNATURES)
Checks whether correlation matrix is in range. Only runs if DEBUG flag is turned on from julia commandline. 

# Arguments
- `r` : a matrix to be standardized
- min : minimum value of range 
- max : maximum value of range 

# Output: 
errors message will show if correlation matrix is not in range. 

"""
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

"""
$(SIGNATURES)
Computes log of odds (LOD) score. Optimized for correlation matrix type is Float64 (double precision).

!Notes: Set the thread number with env JULIA_NUM_THREADS to your desired number of threads. 
For example: `$ JULIA_NUM_THREADS=16 julia`

# Arguments
- `m` : number of individuals. 
- `nr` : correlation matrix R times n. N will be removed during this step. 

# Output: 
returns LOD score. 

"""
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

"""
$(SIGNATURES)
Computes log of odds (LOD) score. Optimized for correlation matrix type is Float32 (single precision).

!Notes: Set the thread number with env JULIA_NUM_THREADS to your desired number of threads. 
For example: `$ JULIA_NUM_THREADS=16 julia`

# Arguments
- `m` : number of individuals. 
- `nr` : correlation matrix R times n. N will be removed during this step. 

# Output: 
returns LOD score. 

"""
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

"""
$(SIGNATURES)
Computes p-value based on log of odds score. 

# Arguments
- `lod` : LOD matrix

# Output: 
returns p-value. 

"""
function lod2p(lod)
    return 1 .- cdf(Chisq(1),2*log(10)*lod)
end

"""
$(SIGNATURES)
Computes the index of maximum, and maximum value of each row of a matrix. 
Optimized with multi-threading. 

!Notes: Set the thread number with env JULIA_NUM_THREADS to your desired number of threads. 
For example: `$ JULIA_NUM_THREADS=16 julia`

# Arguments
- `lod` : input matrix. 

# Output: 
returns a matrix with two columns, first column is the index of maximum, second column is 
the maximum value. 

"""
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
- `Y` : a matrix of phenotypes.
- `G` : a matrix of genotypes.
- `X` : a matrix of covariates. Default is `nothing`. If `nothing`, scan is run without covariates. 
- `maf_threshold`: a floating point number to indicate the maf_threshold. Default is 0.05. Set to 0 if no maf filtering should be done. 
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 
- `lod_or_pval`: a string value of either `lod` or `pval` to indicate the desired output. 
- `timing_file`: a string that indicates the file location for the timing outputs. Default is nothing. 
# Output: 
returns LOD score or pval, in vector or matrix format depending on value of `export_matrix`. 
"""
function cpurun(pheno::AbstractArray{<:Real,2}, geno::AbstractArray{<:Real,2}, X::Union{AbstractArray{<:Real, 2}, Nothing}=nothing; maf_threshold=0.05, export_matrix=false, lod_or_pval="lod",timing_file="")
    @debug begin 
        "size(Y) = $(size(Y)), size(G) = $(size(G)). Number of indvidual should be size(Y, 1), or size(G, 1). "
    end
    pval_time = 0.0 
    compute_time = 0.0 
    result_reorg_time = 0.0 
    data_transfer_time = 0.0 

    total_start = time_ns()
    data_transfer_time += @elapsed G = geno
    data_transfer_time += @elapsed Y = pheno
    
    compute_time += @elapsed begin 
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
    end 

    @debug begin 
        test_r_in_range = is_corr_in_range(nr./n, -1,1)
        "R is in range (-1, 1): $test_r_in_range"
    end

    if lod_or_pval == "lod"
        compute_time += @elapsed lod = lod_score_multithread(n,nr)

        if !export_matrix 
            compute_time += @elapsed lod = find_max_idx_value(lod)
        end
    elseif lod_or_pval == "pval"
        pval_time += @elapsed pval = pval_calc(nr ./ n, n-2)
    else 
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end 

    total_stop = time_ns()
    elapsed_total = (total_stop - total_start) * 1e-9

    
    if timing_file != ""
        open("/home/xiaoqihu/git/LiteQTL-G3-supplement/code/tensorqtl/liteqtl_timing_report.txt", "a") do io
            write(io, "$(now()),CPU,$(data_transfer_time),$(compute_time),$(result_reorg_time),$(pval_time),$(elapsed_total)\n")
        end   
    end 

    if lod_or_pval == "lod" 
        return lod
    elseif lod_or_pval == "pval"
        return pval 
    else 
        error("Must specify `lod_or_pval`, choose between `lod`, or `pval`")
    end

end