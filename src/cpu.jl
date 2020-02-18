
function lod_score_multithread(m,r::Array{Float64,2})
    n = convert(Float64,m)
    Threads.@threads for j in 1:size(r)[2]
    # for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square::Float64 = (r[i,j]/n)^2
            r[i,j]= -n/Float64(2.0) * log(Float64(1.0)-r_square)
        end
    end
    return r
end

function lod_score(n, r::Array{Float64,2})
    for j in 1:size(r)[2]
        for i in 1:size(r)[1]
            r_square::Float64 = (r[i,j]/n)^2
            r[i,j] = -n/Float64(2.0) * log(Float64(1.0)-r_square)
        end
    end
    return r
end


function cpurun_with_covar(Y::Array{Float64,2}, G::Array{Float64,2}, X::Array{Float64,2}, n)
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


function find_max_idx_value(lod::Array{Float64,2})
    max_array = Array{Float64,2}(undef, size(lod)[1], 2)
    Threads.@threads for i in 1:size(lod)[1]
        temp = lod[i,1]
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
    # println("CPU result size: $(size(max_array))")
    # display(max_array[1:10, 1:2])
    return max_array
end



##################### Running CPU Function ###################
function cpurun(a::Array, b::Array, n::Int, export_matrix::Bool)
    a_std = get_standardized_matrix(a);
    b_std = get_standardized_matrix(b);
    #step 2: calculate R, matrix of corelation coefficients
    r = calculate_r(a_std,b_std);
    #step 3: calculate r square and lod score
    # lod = lod_score(n, r);
    lod = lod_score_multithread(n,r)
    if export_matrix
        println("exporting matrix.")
        return lod
    end
    println("exporting max lod")
    return find_max_idx_value(lod)

end
