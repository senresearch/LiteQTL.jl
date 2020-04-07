using Pkg

Pkg.activate(".")
Pkg.instantiate(; verbose = false)
Pkg.activate("./bin/MyApp")
Pkg.instantiate(; verbose = false)
