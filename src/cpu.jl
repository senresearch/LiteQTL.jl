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

function cpurun_with_covar(Y::AbstractArray{<:Real,2}, G::AbstractArray{<:Real,2}, X::AbstractArray{<:Real,2}, n)
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
    return lod
end


function find_max_idx_value(lod::AbstractArray{<:Real,2})
    max_array = Array{typeof(lod[1,1]),2}(undef, size(lod)[1], 2)
    # Threads.@threads for i in 1:size(lod)[1]
        for i in 1:size(lod)[1]
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
function cpurun(a::AbstractArray{<:Real, 2}, b::AbstractArray{<:Real, 2}, n::Int, maxlod::Bool)
    a_std = get_standardized_matrix(a);
    b_std = get_standardized_matrix(b);
    #step 2: calculate R, matrix of corelation coefficients
    r = calculate_r(a_std,b_std);
    #step 3: calculate r square and lod score
    # lod = lod_score(n, r);
    lod = lod_score_multithread(n,r)

    if maxlod 
        println("Calculating max lod")
        return find_max_idx_value(lod)
    else 
        println("exporting matrix.")
        return lod
    end


end
