using Documenter, LMGPU

const src = "https://github.com/ChelseaTrotter/LMGPU.jl"
const dst = "https://ChelseaTrotter.github.io/LMGPU.jl/stable"

function main()
    ci = get(ENV, "CI", "") == "true"
    @info "Generating Documenter.jl site"
    DocMeta.setdocmeta!(LMGPU, :DocTestSetup, :(using LMGPU); recursive=true)

    makedocs(
        # Must have the following args: 
        sitename = "LMGPU.jl",
        authors = "Chelsea Trotter, Saunak Sen",
        repo = "$src/blob/{commit}{path}#{line}",
        format = Documenter.HTML(
            # Use clean URLs on CI
            prettyurls = ci,
            canonical = dst,
            analytics = "UA-154489943-2",
        ),
        modules = [LMGPU],
        pages = Any[
            "Home" => "index.md",
        ],

        # Additional, not must-haves. 
        doctest = ("doctest=only" in ARGS) ? :only : true,
        strict = !("strict=false" in ARGS),
    )

    if ci
        @info "Deploying to GitHub"
        deploydocs(
            # Must have the following args: 
            repo = "github.com/ChelseaTrotter/LMGPU.jl.git",
            devurl = "dev",
            versions = ["stable" => "v^", "v#.#"],
            push_preview = true
        )
    end

end

isinteractive() || main()

# makedocs(;
#     modules=[LMGPU],
#     format=Documenter.HTML(),
#     pages=[
#         "Home" => "index.md",
#     ],
#     repo="/blob/{commit}{path}#L{line}",
#     sitename="LMGPU.jl",
#     authors="Chelsea Trotter, Sen Research",
#     assets=String[],
# )

# deploydocs(;
#     repo="github.com/chelseatrotter/LMGPU.jl.git",
#     devurl = "dev",
#     versions = ["stable" => "v^", "v#.#"],
# )
