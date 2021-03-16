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

function testfloop!(n, r)

    @floop for (j, i) in zip(1:size(r)[2], 1:size(r)[1])
        tmpr = r[i,j]
        @reduce( r[i,j] = (-n/2.0) * log10(1.0- ((tmpr/n)^2)) )
    end
    return r
end

function floop_map!(f, n, inputs, ex = ThreadedEx())
    @floop ex for i in eachindex(inputs)
        @inbounds inputs[i] = f(n,inputs[i])
    end
    return inputs
end

function updater(n,r)
    return (-n/2.0) * log10(1.0- ((r/n)^2))
end


function test(n, r::AbstractArray{Float32, 2})
    myi = 0 
    myj = 0
    try
        Threads.@threads for j in 1:size(r)[2]
            for i in 1:size(r)[1]
                myi = i
                myj = j 
                r_square = (r[i,j]/n)^2
                tmp = (-n/2.0) * log10(1.0-r_square)
                r[i,j] = tmp
            end
        end
    catch 
        println("Myi: $myi, Myj: $myj")
    end
    return r
end


function testshort(n, r)
    @. r = (-n/2.0) * log10(1.0- (r/n)^2)
end
