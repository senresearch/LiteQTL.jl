
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

function get_gmap_info(gmap_file)
    gmap = readdlm(gmap_file, ',', header=true)
    return gmap

end

function match_gmap(idx::Array{Int64,1}, gmap)
    tmp=Array{Any}(undef, size(idx)[1], size(gmap)[2])
    for i in 1:size(idx)[1]
        tmp[i,:] = gmap[idx[i],:]
    end
    return tmp
end
