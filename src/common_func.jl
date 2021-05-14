
"""
$(SIGNATURES)

Computes standardized matrix on GPU. Theoretically this function 
works with CPU as well. But it is not as fast as the 
`get_standardized_matrix` function, which utilizes multi threads on CPU. 

# Arguments
- `m` : a matrix to be standardized

# Output: 
returns the standardized matrix of `m`

"""
function get_standardized_matrix_gpu(m::AbstractArray{<:Real,2})
    return (m .- mean(m, dims=1)) ./ std(m, corrected=false, dims=1) 
end

"""
$(SIGNATURES)
Computes standardized matrix on CPU utilizing multi-threads. 

# Arguments
- `m` : a matrix to be standardized

# Output: 
returns the standardized matrix of `m`

"""
function get_standardized_matrix(mat::AbstractArray{<:Real,2})
    m = copy(mat)
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

"""
$(SIGNATURES)

# Arguments
- `x` : input matrix

# Output: 
returns px

"""
function calculate_px(x::AbstractArray{<:Real,2})
    XtX = transpose(x)*x
    result = x*inv(XtX)*transpose(x)
    # display(result)
    return result
end
