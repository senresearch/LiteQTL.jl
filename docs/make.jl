using Documenter, LMGPU

makedocs(;
    modules=[LMGPU],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/chelseatrotter/LMGPU.jl/blob/{commit}{path}#L{line}",
    sitename="LMGPU.jl",
    authors="Chelsea Trotter, Sen Research",
    assets=String[],
)

deploydocs(;
    repo="github.com/chelseatrotter/LMGPU.jl.git",
)
