function _blocksparse_tensormap(tsrc::ITensors.ITensor)
    N = ndims(tsrc)
    T = eltype(tsrc)
    indices = map(index, inds(tsrc))
    allequal(Base.Fix2(getindex, 2), indices) || error("All QNs in the indices must have consistent symmetry types")
    allequal(Base.Fix2(getindex, 3), indices) || error("All QNs in the indices must have consistent QN names")

    symmetry = indices[1][2] 

    charge_and_dims = getindex.(indices, 1)
    directions = getindex.(indices, 4)
    all_spaces_axes = map((x, y) -> canonicalize_space(x, y; symmetry), charge_and_dims, directions)
    all_spaces = first.(all_spaces_axes)
    all_axes = last.(all_spaces_axes)

    tdst = zeros(T, prod(all_spaces))
    t_tensor = ITensors.tensor(tsrc)
    for b in eachnzblock(t_tensor)
        key = b.data .% Int
        block = Array(t_tensor[b])
        charges = ntuple(N) do i
            c = first(all_axes[i][key[i]])
            return isdual(all_spaces[i]) ? dual(c) : c
        end
        axs = ntuple(N) do i
            return last(all_axes[i][key[i]])
        end
        @assert isapprox(norm(tdst[charges][axs...]), 0; atol = 1.0e-10)
        tdst[charges][axs...] .= block
    end

    return tdst
end

# little bit of annoyance: ITensors allows repeated charges, so have to merge them here
# this helper function merges repeated charges and obtains the total space, while also
# returning the axes for each original charge
function canonicalize_space(inds, arrow; symmetry)
    # determine the locations of each entry
    axs = map(inds) do (label, dim)
        length(label) == 1 && return (convert(symmetry, label[1]) => 1:dim)
        return (convert(symmetry, label) => 1:dim)
    end
    for c in unique(first.(axs))
        firstid = true
        dlast = 0
        for j in findall(==(c), first.(axs))
            if firstid
                dlast = last(last(axs[j]))
                firstid = false
            else
                axs[j] = (c => (axs[j][2] .+ dlast))
                dlast = last(axs[j][2])
            end
        end
    end

    # combine everything
    combiner = Dict()
    for (label, dim) in inds
        label′ = length(label) == 1 ? convert(symmetry, label[1]) : convert(symmetry, label)
        combiner[label′] = get(combiner, label′, 0) + dim
    end
    V = Vect[symmetry](label => dim for (label, dim) in combiner; dual = (arrow == -1))

    return V, axs
end


