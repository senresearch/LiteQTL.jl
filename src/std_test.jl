function julia_std(a)
    m = mean(a, dims=1)
    s = std(a, dims=1)

    for col in 1:size(a)[2]
        a[:, col] = (a[:, col] .- m[col]) / s[col]
    end

    return a 
end 

# Works
function new_std(a)
    return a = (a .- mean(a)) ./ std(a)
end

function gpu_std(a::CuArray)
    
end
function get_standardized_matrix(m::AbstractArray{<:Real,2})
    Threads.@threads for col in 1:size(m)[2]
        summ = 0.0f0
        rows = size(m)[1]
        for row in 1:rows
            summ += m[row, col]
        end
        mean = summ/rows
        sums = 0.0f0
        for row in 1:rows
            sums += (m[row,col] - mean)^2
        end
        std = sqrt(sums/rows)
        for row in 1:rows
            m[row,col] = (m[row,col]-mean)/std
        end
    end
    return m
end

isapprox(my_std, j_std, atol=0.0001)
# true

using CUDA 
using StatsBase
using Statistics

a = rand(10000, 50000)
d_a = CuArray(a)
@elapsed j_std = julia_std(a)
CUDA.@elapsed j_std = julia_std(d_a)


@time my_std = get_standardized_matrix(a)
# 0.18 seconds CPU 400%
@time j_std = julia_std(a)
# 1.0 seconds CPU 100%
