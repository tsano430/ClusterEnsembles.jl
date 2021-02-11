module ClusterEnsembles

    using LinearAlgebra
    using Metis
    using LightGraphs

    export cluster_ensembles

    function set_nclass(base_clusters)
        nclass = -1
        n_bcs = size(base_clusters)[2]

        for i in 1:n_bcs
            bc = view(base_clusters, :, i)
            unique_bc = filter(x -> !ismissing(x), unique(bc))
            len_unique_bc = length(unique_bc)
            nclass = max(nclass, len_unique_bc)
        end
        return nclass
    end

    function create_hepergraph(base_clusters)
        H = nothing
        len_bcs, n_bcs = size(base_clusters)

        for i in 1:n_bcs
            bc = view(base_clusters, :, i)
            unique_bc = filter(x -> !ismissing(x), unique(bc))
            len_unique_bc = length(unique_bc)
            bc2id = Dict(zip(unique_bc, 1:len_unique_bc))
            h = zeros(len_bcs, len_unique_bc)
            for (i, elem_bc) in enumerate(bc)
                if ismissing(elem_bc) == false
                    h[i, bc2id[elem_bc]] = 1.0
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
        membership = Metis.partition(Graph(W), nclass, alg=:RECURSIVE)
        return membership[colA+1:end]
    end

    """
    `cluster_ensembles` generate a single consensus cluster using base clusters obtained 
    from multiple clustering algorithms.
    
    # Arguments
    - `base_clusters`: The given label set of base clusters. Each column is a base cluster's label.
    - `nclass`: Number of classes in consensus clustering label.
    - `alg`: Algorithms for cluster ensembles.
    """
    function cluster_ensembles(base_clusters::Array{Union{Int, Missing}}; nclass::Union{Int, Nothing}=nothing, alg::Symbol=:hbgf)
        if nclass === nothing
            nclass = set_nclass(base_clusters)
        end

        eltype(nclass) <: Number || nclass > 0 || throw(ArgumentError("nclass must be positive."))

        if alg == :hbgf
            consensus_clustering_label = hbgf(base_clusters, nclass)
        else
            throw(ArgumentError("Invalid algorithm."))
        end

        return consensus_clustering_label
    end

end
