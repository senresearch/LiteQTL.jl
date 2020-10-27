
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

function get_gmap_info(rqtl_file)

    # if passing in rqtl_file as a zip, extract gmap file.
    if extension(rqtl_file) == ".zip"
        dir = ZipFile.Reader(rqtl_file)
        f = findfile(dir, "gmap.csv")
        gmap = readdlm(f, ',')
        close(dir)
    # if passing in just gmap file.
    elseif extension(rqtl_file) == ".csv"
        if occursin("gmap.csv", rqtl_file)
            gmap = readdlm(rqtl_file, ',')
        else
            error("no gmap file found.")
        end
    else
        error("Tried to find gmap in zip file or csv file. NON FOUND. ")
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
