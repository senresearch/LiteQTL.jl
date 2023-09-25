"""
$(SIGNATURES)
Sets the number of threads that will be used by BLAS library. 
!Notes: Set the thread number with env JULIA_NUM_THREADS to your desired number of threads. 
For example: `JULIA_NUM_THREADS=16 julia`

# Arguments
- `nthread` : desired number of threads 

# Output: 
Shows number of threads set. 

"""
function set_blas_threads(nthread)
    LinearAlgebra.BLAS.set_num_threads(nthread)
    core_nums = BLAS.get_num_threads()
    println("Number of threads using: $core_nums")
end
