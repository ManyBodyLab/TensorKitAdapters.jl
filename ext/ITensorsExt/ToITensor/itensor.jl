const tk_tensor = Union{TensorMap, BraidingTensor}

function ITensors.ITensor(t::tk_tensor;
    tags::AbstractVector{<:AbstractString}=itensor_standard_tags(numind(t)),
    ids=itensor_standard_ids(numind(t)),
    plevs=itensor_standard_plevs(numind(t)),
    qn_names::Union{<:AbstractVector{<:AbstractString},Missing}=missing,
)::ITensor
    T = eltype(t)
    ## First we take t to be a tensor from a 0-dimensional codomain to a rank N-domain
    t = repartition(t, numind(t), 0)
    sp = TensorKit.space(t)
    indices = [[(isdual(V) ? dual(c) : c) => TensorKit.dim(V, c) for c in sectors(V)] for V in sp.codomain]
    direction = [isdual(V) ? ITensors.In : ITensors.Out for V in sp.codomain]
    direction_sign = [isdual(V) ? -1 : 1 for V in sp.codomain]
    if sectortype(sp) <: Trivial
        sizes = last.(last.(indices))
        index = map(eachindex(indices)) do i
            id = ids[i]
            dir = direction[i]
            tag = tags[i]
            plev = plevs[i]
            return Index(id, sizes[i], dir, tag, plev)
        end
        iten = ITensors.DenseTensor(T, undef, index)
        copyto!(iten.storage.data, t.data)
        return ITensors.itensor(iten)
    end
    isa_product = sectortype(sp) <: ProductSector
    if isa_product
        moduli = convert_to_modulus.(fieldtypes(sectortype(sp).parameters[1]))
    else
        moduli = convert_to_modulus.([sectortype(sp)])
    end

    ismissing(qn_names) && (qn_names=itensor_standard_qn_names(length(moduli)))

    all_u1s = findall(x -> x == 1, moduli)
    multiply_by_two=false
    for i in eachindex(indices)
        space = indices[i]
        for (c, _) in space
            for i in all_u1s
                charge = get_charge(isa_product ? c[i] : c; rescale=true)
                if mod(charge,2)!=0
                    multiply_by_two=true
                    break
                end
            end
            if multiply_by_two
                break
            end
        end
        if multiply_by_two
            break
        end
    end

    index_dict=[Dict{Sector, Int}() for _ in eachindex(indices)]

    indices = map(eachindex(indices)) do i
        space_tensorkit = indices[i]
        space = map(x->construct_QN(x[1],direction_sign[i],qn_names,moduli, multiply_by_two, isa_product)=>x[2], space_tensorkit)
        index_dict[i] = Dict(zip(first.(space_tensorkit),eachindex(space)))

        id = ids[i]
        dir = direction[i]
        tag = tags[i]
        plev = plevs[i]
        return Index(id, space, dir, tag, plev)
    end

    N=numind(t)

    all_blocks = ITensors.Block{N}[]
    for (f1,f2) in fusiontrees(t)
        push!(all_blocks, get_block(f1,f2,index_dict, Val(N)))
    end
    ITens = ITensors.BlockSparseTensor(T, undef, all_blocks, indices)
    for (f1, f2) in fusiontrees(t)
        b = get_block(f1,f2,index_dict, Val(N))
        ITensors.blockview(ITens, b) .= t[f1, f2]
    end
    ITens = ITensors.itensor(ITens)
    check_flux(ITens)
    return combineblocks_itensor(ITens)
end

function construct_QN(x::Sector, sign::Int, qn_names, moduli, multiply_by_two::Bool=false, isa_product::Bool=false)
    charges = map(eachindex(moduli)) do i
        #charg = sign*
        
        charg = get_charge(isa_product ? x[i] : x; rescale=multiply_by_two)
        if !isone(moduli[i])
            charg = mod(charg, moduli[i])
        end
        return charg
    end
    return QN(map(i->(qn_names[i],charges[i],moduli[i]),eachindex(moduli))...)
end

function get_block(f1::FusionTree, f2::FusionTree, index_dict::Vector{Dict{Sector,Int}},::Val{N}) where {N}
    charges= (
        (flag ? dual(c) : c for (flag, c) in zip(f1.isdual, f1.uncoupled))...,
        (flag ? dual(c) : c for (flag, c) in zip(f2.isdual, f2.uncoupled))...,
    )
    blockinds=ntuple(i-> index_dict[i][charges[i]], N)
    return ITensors.Block{N}(blockinds)
end

function convert_to_modulus(::Type{U1Irrep})
    return 1
end
function convert_to_modulus(::Type{ZNIrrep{N}}) where {N}
    return N
end
function get_charge(x::ZNIrrep{N}; rescale::Bool=false) where {N}
    return Int(x.n)
end
function get_charge(x::U1Irrep; rescale::Bool=false)
    if !rescale
        return Int(x.charge*1)
    else
        return Int(x.charge*2)
    end
end

function itensor_standard_ids(N::Int)
    return [rand(index_id_rng(), ITensors.IDType) for _ in 1:N]
end
function itensor_standard_plevs(N::Int)
    return fill(0, N)
end
function itensor_standard_tags(N::Int)
    return ["" for _ in 1:N]
end
function itensor_standard_qn_names(N::Int)
    return [string(Char('A' + i - 1)) for i in 1:N]
end
function check_flux(T::ITensor)
    if !iszero(T)
        @assert iszero(flux(T))
    end
end
