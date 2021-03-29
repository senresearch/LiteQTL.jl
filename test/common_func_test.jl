function get_standardized_matrix(mat::AbstractArray{<:Real,2})
    m = mat
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


function get_standardized_matrix_gpu(m::AbstractArray{<:Real,2})
    return (m .- mean(m, dims=1)) ./ std(m, corrected=false, dims=1) 
end

using Statistics
using Test

mat = rand(1000, 1000)

correct_std_mat = get_standardized_matrix(mat)

new_std_mat = get_standardized_matrix_gpu(mat)

compare_res = isapprox.(correct_std_mat, new_std_mat, atol=1e-5)

@test sum(compare_res) == prod(size(mat))
