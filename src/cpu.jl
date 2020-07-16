
function calculate_r(a::Array{<:Real,2},b::Array{<:Real, 2})
    return LinearAlgebra.BLAS.gemm('T', 'N', a,b);
end

# parameter `signed` is a hack to save storage while preserving the sign of r[i,j].
# Because the sign will be lost when squaring, and we need to preserve the sign,
# since the LOD score is r_square, and is always going to be positive, we put the sign back to r_square.
# This will save storage and output time.
function lod_score_multithread(m,r::Array{<:Real,2}, signed=false)
    n = m
    Threads.@threads for j in 1:size(r)[2]
    # for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square = (r[i,j]/n)^2
            tmp = -n/2.0 * log10(1.0-r_square)
            sign = (signbit(r[i,j]) && signed) ? -1 : 1
            r[i,j] = tmp * sign
        end
    end
    return r
end

function cpurun_with_covar(Y::Array{<:Real,2}, G::Array{<:Real,2}, X::Array{<:Real,2}, n)
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


function find_max_idx_value(lod::Array{<:Real,2}, signed=false)
    max_array = Array{typeof(lod[1,1]),2}(undef, size(lod)[1], 2)
    Threads.@threads for i in 1:size(lod)[1]
        temp = abs(lod[i,1])
        idx = 1
        r_signbit = false
        # checking negative sign is a hack to preserve the sign of r after being squred.
        for j in 2:size(lod)[2]
            if temp < abs(lod[i,j])
                temp = abs(lod[i,j])
                idx = j
                r_signbit = signbit(lod[i,j]) && signed
            end
        end
        max_array[i,1] = idx
        sign = (r_signbit && signed) ? -1 : 1
        max_array[i,2] = temp*sign
    end
    # println("CPU result size: $(size(max_array))")
    # display(max_array[1:10, 1:2])
    return max_array
end


##################### Running CPU Function ###################
function cpurun(a::Array{<:Real, 2}, b::Array{<:Real, 2}, n::Int, export_matrix::Bool, r_sign::Bool)
    a_std = get_standardized_matrix(a);
    b_std = get_standardized_matrix(b);
    #step 2: calculate R, matrix of corelation coefficients
    r = calculate_r(a_std,b_std);
    #step 3: calculate r square and lod score
    # lod = lod_score(n, r);
    lod = lod_score_multithread(n,r,r_sign)

    if export_matrix
        println("exporting matrix.")
        return lod
    end
    println("exporting max lod")
    return find_max_idx_value(lod,r_sign)

end
