using PackageCompiler
function build_bin(file)
    bin_path = joinpath(@__DIR__, "..", "bin")
    build_executable(file, builddir = bin_path)
end

file = joinpath(@__DIR__, "test.jl")
build_bin(file)
