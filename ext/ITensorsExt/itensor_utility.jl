function index(ind::Index{T}) where {T<:Integer}
    direction = dir(ind) == ITensors.Out || dir(ind) == ITensors.Neither ? 1 : -1
    tag = itensor_tag(ind)
    return ind.space, direction, plev(ind), tag, ITensors.id(ind)
end

function index(ind::Index{<:AbstractVector{Pair{QN, T}}}) where {T<:Integer}
    space = ind.space
    blockdims = ITensors.blockdim.(space)
    qns = first.(space)
    qn_names = [[string(x[i].name) for i in eachindex(x)] for x in qns]
    qn_names = filter(x->x!="",unique(reduce(vcat,qn_names)))
    len = length(qn_names)
    qn_moduli = [[x[i].modulus for i in 1:len] for x in qns]
    qn_moduli = [filter(!iszero,unique(getindex.(qn_moduli,i))) for i in 1:len]
    qn_moduli = map(x->isempty(x) ? 1 : only(x), qn_moduli)
    index_output = [Tuple(x[j].val for j in 1:len)=>blockdims[i] for (i,x) in enumerate(qns)]

    symmetry = symmetry_type(Tuple(qn_moduli))
    direction = dir(ind)==ITensors.Out ? 1 : -1
    
    tag = itensor_tag(ind)
    ids = ITensors.id(ind)
    return index_output, symmetry, qn_names, direction, plev(ind), tag, ids
end

function itensor_tag(ind::Index)
    ind_tag = tags(ind)
    if string(ind_tag[1]) != ""
        ind_tag = join(string.(ind_tag), ",")
    else 
        ind_tag = ""
    end
    return ind_tag 
end

function symmetry_type(t::NTuple{N, Int}) where {N}
    factors = map(t) do sym
        sym == 1 && return U1Irrep
        return Irrep[TensorKit.ℤ{sym}]
    end

    if N == 1
        return factors[1]
    else
        return ⊠(factors...)
    end
end

function combineblocks_itensor(T::ITensor,inds_old=inds(T))
    for i in eachindex(inds_old)
        ind_old = inds_old[i]
        C = combiner(ind_old; tags=tags(ind_old))
        new_ind = uniqueind(C,T)
        if inds_old[i].space != new_ind.space
            inds_T = collect(inds(T))
            T *= C
            new_ind_old_id=Index(ITensors.id(ind_old), new_ind.space, dir(ind_old), tags(ind_old), plev(inds_old[i]))
            T *= delta(dag(new_ind),new_ind_old_id)
            inds_T[i] = new_ind_old_id
            T = ITensors.permute(T, inds_T; allow_alias = true)
        end
    end
    return T
end
