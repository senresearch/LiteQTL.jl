
function findfile(dir, name)
    for f in dir.files
        if occursin(name,f.name)
            return f
        end
    end
    error("Can't find $name file")
end

function extension(url::String)
    try
        match(r"\.[A-Za-z0-9]+$", url).match
    catch
        ""
    end
end

function get_gmap_info(rqtl_file, gmap_file)

    if extension(rqtl_file) == ".zip"
        dir = ZipFile.Reader(rqtl_file)
        f = findfile(dir, gmap_file)
        gmap = readdlm(f, ',')
        close(dir)
    else
        error("Rqtl file is not passed in as a zip, need to handle this.")
    end
    return gmap

end

function match_gmap(idx::Array{Int64,1}, gmap)
    tmp=Array{Any}(undef, size(idx)[1], size(gmap)[2])
    for i in 1:size(idx)[1]
        tmp[i,:] = gmap[idx[i],:]
    end
    return tmp
end

# rqtl_file = joinpath(@__DIR__, "..", "data", "UTHSC_SPL_RMA_1210.zip")
# gmap = LMGPU.get_gmap_info(rqtl_file, "gmap.csv")
# dir = ZipFile.Reader(rqtl_file)
# f = findfile(dir, "gmap.csv")
# gmap = readdlm(f, ',')
# @show gmap
