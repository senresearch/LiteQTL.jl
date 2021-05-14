"""
$(SIGNATURES)
Computes correlation matrix (R) * n on GPU with cuBLAS library. n is not removed because of performance choice. 

# Arguments
- `a` : standardized phenotype matrix
- `b` : standardized genotype matrix

# Output: 
returns correlation matrix R on GPU device (of type CuArray). 

"""
function calculate_nr(a::CuArray,b::CuArray)
    return CUDA.CUBLAS.gemm('T', 'N', a,b);
end

"""
$(SIGNATURES)
Computes the number of blocks for chuncking large phenotype matrix, to fit into GPU memory. 

# Arguments
- `n` : number of individuals
- `m` : number of phenotypes 
- `p` : number of genotype markers
- datatype: datatype of phenotype. (Float32, or Float64)

# Output: 
returns
- `num_block` : number of blocks to disect phenotype
- `block_size` : size of each block. 
"""
function get_pheno_block_size(n::Int, m::Int, p::Int, datatype::DataType)
    total_data_size = (n*m + n*p + m*p) * sizeof(datatype) # get the number of bytes in total
    gpu_mem = CUDA.available_memory() * 0.89 # can not use all of gpu memory, need to leave some for intermediate result.
    #if m is too big for gpu memory, I need to seperate m into several blocks to process
    block_size = Int(ceil((gpu_mem - (n*p))/((n+p) * sizeof(datatype))))
    num_block = Int(ceil(m/block_size))
    return (num_block, block_size)
end

"""
$(SIGNATURES)
Sets up GPU environment and calls GPU kernels. 

# Arguments
- `d_nr` : Output matrix (correlation matrix) in CuArray format
- `n` : number of individuals
- `m` : number of phenotypes 
- `p` : number of genotype markers
- `export_matrix` : boolean value to indicate user desire output

# Output: 
returns correlation matrix R, or maximum of R if `export_matrix` is set to false

"""
function gpu_square_lod(d_nr::CuArray{<:Real,2},n,m,p, export_matrix::Bool)
    #Get total number of threads
    ndrange = prod(size(d_nr))
    #Get maximum number of threads per block
    dev = CUDA.device()
    threads = CUDA.warpsize(dev)
    blocks = min(Int(ceil(ndrange/threads)), attribute(dev, CUDA.CU_DEVICE_ATTRIBUTE_MAX_GRID_DIM_X))
    @cuda blocks=blocks threads=threads lod_kernel(d_nr, ndrange,n)
    if !export_matrix 
        @cuda blocks=blocks threads=threads reduce_kernel(d_nr,m,p)
    end
    return 
end

################
## GPU kernel ##
################
"""
$(SIGNATURES)
GPU kernel that computes LOD scores. 

# Arguments
- `nr` : correlation matrix. will be updated with output results. (Type CuArray)
- `MAX` : number of total GPU threads, also called ndrange. 
- `n` : number of individuals


# Output: 
Results written back to input matrix `nr`. Returns the LOD scores. 

"""
function lod_kernel(nr, MAX,n)
    # TODO: n, 1, 2, do they need to be converted to correct data type for better performance?
    tid = (blockIdx().x-1) * blockDim().x + threadIdx().x
    if(tid < MAX+1)
        r_square = (nr[tid]/n)^2
        nr[tid] = (-n/2.0) * CUDA.log10(1.0-r_square)
    end
    return
end

"""
$(SIGNATURES)
Computes the maximum LOD score of each row. Results written back to the first two columns.

# Arguments
- `input` : LOD score
- `rows` : number of rows for `input`
- `cols` : number of cols for `input`

# Output: 
Output is written to the `input` matrix, first column of `input` matrix is the index of maximum, and second column is the maximum value of that row. 

"""
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

"""
$(SIGNATURES)

# Arguments:
- `Y` : a matrix of phenotypes.
- `G` : a matrix of genotypes.
- `X` : a matrix of covariates. Default is `nothing`. If `nothing`, scan is run without covariates. 
- `maf_threshold`: a floating point number to indicate the maf_threshold. Default is 0.05. Set to 0 if no maf filtering should be done. 
- `export_matrix` : a boolean value that determines whether the result should be the maximum value of LOD score of each phenotype and its corresponding index, or the whole LOD score matrix. 
- `lod_or_pval`: a string value of either `lod` or `pval` to indicate the desired output. 
- `timing_file`: a string that indicates the file location for the timing outputs. Default is nothing. 
# Output: 
returns LOD score, in vector or matrix format depending on value of `export_matrix`. P value for GPU is not currently implementated. 
"""
function gpurun(pheno::Array{<:Real,2}, geno::Array{<:Real,2}, X::Union{Array{<:Real, 2}, Nothing}=nothing; maf_threshold=0.05, export_matrix=false, timing_file="")
    start = time_ns()
    Y = pheno
    G = geno
    if maf_threshold > 0  
        G = filter_maf(geno, maf_threshold=maf_threshold)
    end
    m = size(Y,2)
    p = size(G,2)
    n = size(G,1)
    (num_block, block_size) = get_pheno_block_size(n,m,p, typeof(Y[1,1]))
    println("Seperated into $num_block blocks")

    data_transfer_time = 0.0
    result_reorg_time =0.0
    compute_time = 0.0 
    pval_time = 0.0

    # Output array:
    if export_matrix 
        result_dim = p
    else 
        result_dim = 2
    end
    result_reorg_time += @elapsed lod = convert(Array{typeof(Y[1,1]), 2},zeros(0,result_dim))
    # Transfer Genotype array to GPU
    data_transfer_time += CUDA.@elapsed d_g = CuArray(G);

    if !isnothing(X) 
        # Calculate px matrix for covar (X) on GPU
        data_transfer_time += CUDA.@elapsed d_px = CuArray(calculate_px(X))
        # Calculate g hat on GPU
        compute_time += CUDA.@elapsed d_g_hat = CUDA.CUBLAS.gemm('N', 'N', d_px, d_g)
        # Calculate tilda on GPU
        compute_time += CUDA.@elapsed d_g = d_g .- d_g_hat 
    end
    # Standardizing matrix on GPU
    compute_time += CUDA.@elapsed d_g_std = get_standardized_matrix_gpu(d_g)

    for i = 1:num_block
        # i = 1
        begining = block_size * (i-1) +1
        ending = i * block_size
        if (i == num_block)
            ending = size(Y)[2]
        end
        # println("processing $begining to $ending...")

        data_transfer_time += @elapsed y_block = Y[:, begining : ending]
        # Transfer phenotype array to GPU
        data_transfer_time += CUDA.@elapsed d_y = CuArray(y_block)

        compute_time += CUDA.@elapsed begin 
            if !isnothing(X) 
                # Calulate y hat on GPU 
                d_y_hat = CUDA.CUBLAS.gemm('N', 'N', d_px, d_y)
                # Calculate y tilda on GPU
                d_y = d_y .- d_y_hat
            end
            d_y_std = get_standardized_matrix_gpu(d_y)

            # calculate correlation matrix
            d_nr = calculate_nr(d_y_std,d_g_std);
            actual_block_size = ending - begining + 1 #it is only different from block size at the last loop since we are calculating the left over block not a whole block.
            gpu_square_lod(d_nr,n,actual_block_size,p, export_matrix)
        end

        if export_matrix
            data_transfer_time += CUDA.@elapsed res = collect(d_nr)
        else 
            data_transfer_time += CUDA.@elapsed res = collect(d_nr[:, 1:2])
        end
        result_reorg_time += @elapsed lod = vcat(lod, res)
    end
    stop = time_ns()
    elapsed_total = (stop - start) * 1e-9

    if timing_file != ""
        open(timing_file, "a") do io
            write(io, "$(now()),GPU,$data_transfer_time,$(compute_time),$(result_reorg_time),$(pval_time),$(elapsed_total)\n")
        end   
    end
    return lod

end