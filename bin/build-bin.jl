using PackageCompiler

app_dir = joinpath(@__DIR__, "MyApp")
compile_dir = joinpath(@__DIR__, "MyAppCompiled")
precompile_file = joinpath(app_dir,"precompile_app.jl")
create_app(app_dir, compile_dir, force=true,incremental=false,precompile_execution_file=precompile_file)
