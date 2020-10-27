
function get_geno_data(file, datatype)

    geno_prob = convert(Array{datatype,2},readdlm(file, ','; skipstart=1))
    return geno_prob[:,1:2:end]
end

# function get_pheno_data(file, datatype)

#     #first column is individual ID such as : BXD1
#     pheno = readdlm(file, ','; skipstart=1)
#     return convert(Array{datatype,2}, pheno)
# end

function try_string2num(num)
    return tryparse(Float64,num) != nothing
end

function get_gmap_file(dir::String, gmap_file_name::String)
    searchdir(dir,gmap_file_name) = filter(x->occursin(gmap_file_name,x), readdir(dir))

    search_result = searchdir(dir, gmap_file_name)

    if length(search_result) == 0 
        error("No gmap file named $gmap_file_name found in $dir. ")
    elseif length(search_result) == 1
        # extracting the string from 1-element Array{String,1}:
        return abspath(dir)*only(search_result)
    else
        error("Too many gmap file found. Please combine them into one file. \n $search_result")
    end

end


function get_pheno_data(file, datatype; transposed=true)

    #first column is individual ID such as : BXD1
    pheno = readdlm(file, ','; skipstart=1)[:,2:end]
    pheno = convert(Array{datatype,2}, pheno)
    # pheno = convert2float.(pheno, datatype)
    if !isa(pheno[1,1], Number) && !try_string2num(pheno[1,1])
        @info "Removing row names of phenotype. "
        pheno = pheno[:, 2:end]
    end

    if transposed 
        return transpose(pheno) |> collect
    else 
        return pheno
    end

end

function convert2float(a, datatype)
    if a == "NA"
        return missing 
    else 
        return convert(datatype, a)
    end
end

