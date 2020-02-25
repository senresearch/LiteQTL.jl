
function findfile(dir, name)
    for f in dir.files
        if f.name == name
            return f
        end
    end
    nothing
end


function get_geno_data(file)
    geno_data = readdlm(file, ',')
    geno_prob = convert(Array{Float64,2},geno_data[2:end,2:end])
    return geno_prob[:,1:2:end]
end

dir = ZipFile.Reader(joinpath(dirname(@__FILE__),"..", "data", "UTHSC_SPL_RMA_1210.zip"))

f = findfile(dir, "BXD_gmap.csv")
gmap = readdlm(f, ',')
