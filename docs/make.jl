using Documenter, LMGPU

const src = "https://github.com/ChelseaTrotter/LMGPU.jl"
const dst = "https://ChelseaTrotter.github.io/LMGPU.jl/stable"

function main()
    ci = get(ENV, "CI", "") == "true"
    @info "Generating Documenter.jl site"
    DocMeta.setdocmeta!(LMGPU, :DocTestSetup, :(using LMGPU); recursive=true)

    makedocs(
        sitename = "LMGPU.jl",
        authors = "Chelsea Trotter, Saunak Sen",
        repo = "$src/blob/{commit}{path}#{line}",
        format = Documenter.HTML(
            # Use clean URLs on CI
            prettyurls = ci,
            canonical = dst,
            # assets = ["assets/favicon.ico"],
            analytics = "UA-154489943-2",
        ),
        doctest = ("doctest=only" in ARGS) ? :only : true,
        strict = !("strict=false" in ARGS),
        modules = [LMGPU],
        pages = Any[
            "Home" => "index.md",
            # "Tutorials" => Any[
            #     "tutorials/introduction.md",
            # ],
            # "Installation" => Any[
            #     "installation/overview.md",
            #     "installation/conditional.md",
            #     "installation/troubleshooting.md",
            # ],
            # "Usage" => Any[
            #     "usage/overview.md",
            #     "usage/workflow.md",
            #     "usage/array.md",
            #     "usage/memory.md",
            #     "usage/multigpu.md",
            # ],
            # "Development" => Any[
            #     "development/profiling.md",
            #     "development/troubleshooting.md",
            # ],
            # "API reference" => Any[
            #     "api/essentials.md",
            #     "api/compiler.md",
            #     "api/kernel.md",
            #     "api/array.md",
            # ],
            # "Library reference" => Any[
            #     "lib/driver.md",
            # ],
            # "FAQ" => "faq.md",
        ]
    )

    if ci
        @info "Deploying to GitHub"
        deploydocs(
            repo = "github.com/ChelseaTrotter/LMGPU.jl.git",
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
