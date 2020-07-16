
function calculate_r(a::CuArray,b::CuArray)
    return CuArrays.CUBLAS.gemm('T', 'N', a,b);
end

function get_pheno_block_size(n::Int, m::Int, p::Int, datatype::DataType)
    total_data_size = (n*m + n*p + m*p) * sizeof(datatype) # get the number of bytes in total
    # gpu_mem = get_gpu_mem_size()*0.9 # can not use all of gpu memory, need to leave some for intermediate result.
    # CUDAdrv.available_memory()
    gpu_mem = 16914055168 * 0.9 # can not use all of gpu memory, need to leave some for intermediate result.
    #if m is too big for gpu memory, I need to seperate m into several blocks to process
    block_size = Int(ceil((gpu_mem - (n*p))/((n+p) * sizeof(datatype))))
    num_block = Int(ceil(m/block_size))
    return (num_block, block_size)
end

function gpurun(Y::Array{<:Real,2}, G::Array{<:Real,2},n,m,p)
    (num_block, block_size) = get_pheno_block_size(n,m,p, typeof(Y[1,1]))
    # println("seperated into $num_block blocks, containing $block_size individual per block. ")

    g_std = get_standardized_matrix(G);
    lod = convert(typeof(Y[1,1]) ,zeros(0,2))
    d_g = CuArray(g_std);
    for i = 1:num_block
        # i = 1
        begining = block_size * (i-1) +1
        ending = i * block_size
        if (i == num_block)
            ending = size(Y)[2]
        end
        # println("processing $begining to $ending...")

        y_block = Y[:, begining : ending]
        y_std = get_standardized_matrix(y_block);

        d_y = CuArray(y_std);
        d_r = calculate_r(d_y,d_g);
        actual_block_size = ending - begining + 1 #it is only different from block size at the last loop since we are calculating the left over block not a whole block.
        gpu_square_lod(d_r,n,actual_block_size,p)

        lod = vcat(lod, collect(d_r[:, 1:2]))
        # println("finished $i")
    end
    # println("GPU result size: $(size(lod))")
    return lod
end

function gpu_square_lod(d_r::CuArray{<:Real,2},n,m,p)
    #Get total number of threads
    ndrange = prod(size(d_r))
    #Get maximum number of threads per block
    dev = device()
    threads = attribute(dev, CUDAdrv.WARP_SIZE)
    blocks = min(Int(ceil(ndrange/threads)), attribute(dev, CUDAdrv.MAX_GRID_DIM_X))
    @cuda blocks=blocks threads=threads lod_kernel(d_r, ndrange,n)
    return @cuda blocks=blocks threads=threads reduce_kernel(d_r,m,p)

end

################
## GPU kernel ##
################
function lod_kernel(input, MAX,n)
    # TODO: n, 1, 2, do they need to be converted to correct data type for better performance?
    tid = (blockIdx().x-1) * blockDim().x + threadIdx().x
    if(tid < MAX+1)
        r_square = (input[tid]/n)^2
        input[tid] = (-n/2.0) * CUDAnative.log10(1.0-r_square)
        # TODO: NEED to capture sign of r[i,j]
    end
    return
end

function reduce_kernel(input, rows, cols)
    tid = (blockIdx().x-1) * blockDim().x + threadIdx().x

    # Trying for simplest kernel
    if(tid <= rows)
        temp_max = input[tid, 1]
        max_idx = 1
        for i in 1:cols
            if temp_max < input[tid,i]
                temp_max = input[tid,i]
                max_idx = i
            end
        end
        input[tid,1] = max_idx
        input[tid,2] = temp_max
    end

    return
end
