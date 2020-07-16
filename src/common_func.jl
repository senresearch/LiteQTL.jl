
function get_standardized_matrix(m)
    for col in 1:size(m)[2]
        summ::Float64 = 0.0
        rows = size(m)[1]
        for row in 1:rows
            summ += m[row, col]
        end
        mean = summ/rows
        sums::Float64 = 0.0
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

function calculate_px(x::Array{<:Real,2})
    XtX = transpose(x)*x
    result = X*inv(XtX)*transpose(x)
    # display(result)
    return result
end
