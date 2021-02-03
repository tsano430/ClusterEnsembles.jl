module ClusterEnsembles

    using LinearAlgebra
    using Metis
    using LightGraphs

    export cluster_ensembles

    function create_hepergraph(base_clusters)
        H = nothing
        bc_len, ncluster = size(base_clusters)

        for i in 1:ncluster
            base_cluster = base_clusters[:, i]
            bc_types = filter(x -> !ismissing(x), unique(base_cluster))
            bc_types_len = length(bc_types)
            bc2id = Dict(zip(bc_types, 1:bc_types_len))
            h = zeros(bc_len, bc_types_len)
            for (i, bc_elem) in enumerate(base_cluster)
                if ismissing(bc_elem) == false
                    h[i, bc2id[bc_elem]] = 1.0
                end
            end
            H = H === nothing ? h : [H h]
        end

        return H
    end

    # Hybrid Bipartite Graph Formulation
    function hbgf(base_clusters, nclass)
        A = create_hepergraph(base_clusters)
        rowA, colA = size(A)

        W = [zeros(colA, colA) A'; A zeros(rowA, rowA)]
        membership = Metis.partition(Graph(W), nclass, alg = :RECURSIVE)
        return membership[colA+1:end]
    end

    function cluster_ensembles(base_clusters::Array{Union{Int, Missing}}; nclass::Union{Int, Nothing}=nothing) 
        if nclass === nothing
            nclass = length(filter(x -> !ismissing(x), unique(base_clusters)))
        end

        eltype(nclass) <: Number || nclass > 0 || throw(ArgumentError("nclass must be positive."))

        return hbgf(base_clusters, nclass)
    end

end
