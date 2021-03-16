function get_standardized_matrix_gpu(m::AbstractArray{<:Real,2})
    return (m .- mean(m, dims=1)) ./ std(m, corrected=false, dims=1) 
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

# function new_std_matrix(m::AbstractArray{<:Real,2})
#     rownum = size(m)[1]
#     summ = sum(m, dims=1)
#     means = summ ./ rownum 
#     sums = zeros(size(m[2]))
#     for col in 1:size(m)[2]
#         sumscol = @. (m[:,col] - means)^2
#         sums[col] = sum(sumscol)
#     end
    
#     std = @. sqrt(sums / rownum)
#     for col in 1:size(m)[2] 
#         m[:,col] = @. (m[:,col] - means )/std
#     end
#     return m 
# end

function calculate_px(x::AbstractArray{<:Real,2})
    XtX = transpose(x)*x
    result = x*inv(XtX)*transpose(x)
    # display(result)
    return result
end
