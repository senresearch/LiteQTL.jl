"""
$(SIGNATURES)
Sets the number of threads that will be used by BLAS library. 
!Notes: Set the thread number with env JULIA_NUM_THREADS to your desired number of threads. 
For example: `$ JULIA_NUM_THREADS=16 julia`

# Arguments
- `nthread` : desired number of threads 

# Output: 
Shows number of threads set. 

"""
function set_blas_threads(nthread)
    LinearAlgebra.BLAS.set_num_threads(nthread)
    core_nums = ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ())
    println("Number of threads using: $core_nums")
end
