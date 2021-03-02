function scan(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2}, n::Int; export_matrix::Bool=false, usegpu::Bool=false)
    if usegpu
        return LiteQTL.gpurun(Y, G, n)
    end

    return LiteQTL.cpurun(Y,G,n,export_matrix)


end

function scan(Y::AbstractArray{<:Real, 2}, G::AbstractArray{<:Real, 2},  X::AbstractArray{<:Real, 2}, n::Int; export_matrix::Bool=false, usegpu::Bool=false)
    if usegpu
        return LiteQTL.gpurun(Y, G, X, n)
    end

    return LiteQTL.cpurun(Y,G,X,n,export_matrix)


end