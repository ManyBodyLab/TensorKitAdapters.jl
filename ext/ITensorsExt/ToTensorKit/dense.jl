function _dense_tensormap(tsrc::ITensors.ITensor)
    indices = map(index, inds(tsrc))

    dims = getindex.(indices, 1)
    directions = getindex.(indices, 4)
    all_spaces = map(dims, directions) do dim, arrow
        ComplexSpace(dim; dual = (arrow == -1))
    end

    tdest = zeros(eltype(tsrc), prod(all_spaces))
    copyto!(tdest.data, ITensors.tensor(tsrc).storage.data)
    return tdest
end
