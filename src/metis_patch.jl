# Note: metis_patch.jl should be removed when Metis.jl#PR37 is merged.

# The following code is in metis_h.jl.
# - https://github.com/JuliaSparse/Metis.jl/blob/master/src/metis_h.jl
const idx_t = Cint
const METIS_NOPTIONS = 40
const METIS_OPTION_NUMBERING = 18

# The following code is in Metis.jl#PR37.
# - https://github.com/JuliaSparse/Metis.jl/pull/37
const options = fill(Cint(-1), METIS_NOPTIONS)
options[METIS_OPTION_NUMBERING] = 1

struct SWGraph
    nvtxs::idx_t
    xadj::Vector{idx_t}
    adjncy::Vector{idx_t}
    vwgt::Vector{idx_t}
    adjwgt::Vector{idx_t}
    SWGraph(nvtxs, xadj, adjncy, vwgt, adjwgt) = new(nvtxs, xadj, adjncy, vwgt, adjwgt)
end

function graph(G::SimpleWeightedGraphs.AbstractSimpleWeightedGraph)
    N = SimpleWeightedGraphs.nv(G)
    xadj = Vector{idx_t}(undef, N+1)
    xadj[1] = 1
    adjncy = Vector{idx_t}(undef, 2*(SimpleWeightedGraphs.ne(G)+N))
    vwgt = ones(idx_t, N)
    adjwgt = Vector{idx_t}(undef, 2*(SimpleWeightedGraphs.ne(G)+N))
    adjncy_i = 0
    for j in 1:N
        ne = 0
        for i in SimpleWeightedGraphs.outneighbors(G, j)
            ne += 1
            adjncy_i += 1
            adjncy[adjncy_i] = i
            edgeweight = SimpleWeightedGraphs.get_weight(G, j, i)
            if isinteger(edgeweight) && edgeweight > 0
                adjwgt[adjncy_i] = idx_t(edgeweight)
            else
                throw(ErrorException("edge weight should be a positive integer (edge ($j, $i) with weight $edgeweight)"))
            end
        end
        xadj[j+1] = xadj[j] + ne
    end
    resize!(adjncy, adjncy_i)
    return SWGraph(idx_t(N), xadj, adjncy, vwgt, adjwgt)
end

partition(G, nparts; alg = :KWAY) = partition(graph(G), nparts, alg = alg)

function partition(G::SWGraph, nparts::Integer; alg = :KWAY)
    part = Vector{idx_t}(undef, G.nvtxs)
    vwgt = isdefined(G, :vwgt) ? G.vwgt : C_NULL
    adjwgt = isdefined(G, :adjwgt) ? G.adjwgt : C_NULL
    edgecut = fill(idx_t(0), 1)
    if alg === :RECURSIVE
        Metis.METIS_PartGraphRecursive(G.nvtxs, idx_t(1), G.xadj, G.adjncy, vwgt, C_NULL, adjwgt,
                                 idx_t(nparts), C_NULL, C_NULL, options, edgecut, part)
    elseif alg === :KWAY
        Metis.METIS_PartGraphKway(G.nvtxs, idx_t(1), G.xadj, G.adjncy, vwgt, C_NULL, adjwgt,
                            idx_t(nparts), C_NULL, C_NULL, options, edgecut, part)
    else
        throw(ArgumentError("unknown algorithm $(repr(alg))"))
    end
    return part
end
