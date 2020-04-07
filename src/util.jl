
function set_blas_threads(nthread)
    LinearAlgebra.BLAS.set_num_threads(nthread)
    core_nums = ccall((:openblas_get_num_threads64_, Base.libblas_name), Cint, ())
    println("Number of threads using: $core_nums")
end
