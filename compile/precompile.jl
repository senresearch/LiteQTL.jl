# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.4'
#       jupytext_version: 1.2.4
#   kernelspec:
#     display_name: Julia 1.2.0
#     language: julia
#     name: julia-1.2
# ---

# +
using SnoopCompile

SnoopCompile.@snoopc "/tmp/lm_gpu_compiles.log" begin
    include("test.jl")
end

packages = SnoopCompile.read("/tmp/lm_gpu_compiles.log")
parcels = SnoopCompile.parcel(reverse!(packages[2]))
SnoopCompile.write("/tmp/precompile", parcels)
# install packages if they are not in ~/.julia/packages/, this will create a "PACKAGE_NAME" folder under that directory
# because we will need to copy precompile function in package src folder
install_packages(parcels)




# +
# io = open("test.txt")
# lines = readlines(io)
# deleteat!(lines, length(lines))
# newlines = vcat(lines, ["F"])
# write(io, newlines)
# close(io)


(tmppath, tmpio) = mktemp()
open("test.txt") do io
    for line in eachline(io)
        if eof(io)
            line = "FFF\n"
        end
        write(tmpio, line)
    end
end
close(tmpio)
mv(tmppath, "test2.txt", force=true)

# +

function cp_precompiled_file(packageName::String)
    precompile_file = "precompile_" * packageName * ".jl"
    dir = dirname(Base.find_package(packageName))
    Base.Filesystem.cp("/tmp/precompile/$precompile_file", "$dir/precompile.jl",force=true)
end

function check_precompiled(package)
    # read in the second to last line
    prevline = open(readlines, Base.find_package(package))[end-1]
    # check if precompiled line exists in the module.
    compiled = occursin("_precompile_", prevline)
    if compiled
        println("Precompile code already inserted, no need to insert again!")
    end
    reutrn compiled
end

function add_precompile_to_package(packageName::String)
    mode = 666 # file access mode, 666 is read write for all user
    filename = Base.find_package(packageName)
    Base.Filesystem.chmod(filename, mode)
    (tmppath, tmpio) = mktemp()


    readline(filename)
end

```
This function first checks if the package is already installed, then installs it if not installed.

```
function install_packages(parcels::Dict)
    installed = Dict{}
    for (package, funcs) in parcels
        p = String(package)
        if(haskey(Pkg.installed(), p))
            println("✅$p is Installed")
            installed[package] = true
        else
            println("$p is Not Installed")
            try
                println("Installing $p...")
                Pkg.add(p)
                println("✅$p is Installed")
                installed[package] = true
            catch e
                println("Can't install package $p !")
                installed[package] = false
            end
        end
    end
    return installed
end

# Install all necessary package if such package exists in precompile function
pkg_status = install_packages(parcels)
for (package, installed) in pkg_status
    if(installed)
        # Check if precompile code is already inserted, if not, continue
        if (check_precompiled(package))
            # Copy precompiled functions to package's src location
            cp_precompiled_file(p)
            # Add the two lines of code to the src/PACKAGE.jl file.
            add_precompile_to_package(package)
        end
    end


# Get a list of packages that has precompile functions in.
# insert precompile file into each package src file.
            # add precompile functions to src code.

    # check if precompile code is there

    # if not, insert it.


# -

src_file = open(Base.find_package("Compat"))
seekend(src_file)
read(src_file, String)

test_file = open("./test.jl")
countlines(test_file)

using Pkg
haskey(Pkg.installed(),"TextWrap")

s = open("test.txt", "a+")
write(s, "B\n")
write(s, "C\n")
println(position(s))
seekend(s)
println(position(s))
write(s, "D\n")
close(s)

# find end of line
s = open(Base.find_package("Compat"), "r")
prevline = readline(s)
x = readline(s)
while !eof(s)
#     println(x)
    prevline = x
    x = readline(s)
end
close(s)


x
