module ClusterEnsembles

    using LinearAlgebra
    using Metis
    using LightGraphs
    using Distances

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

    function create_hypergraph(base_clusters)
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

    # Meta-CLustering Algorithm
    function mcla(base_clusters, nclass)
        # Construct Meta-graph
        len_bcs, n_bcs = size(base_clusters)
        H = create_hypergraph(base_clusters)

        pair_dist_jac = pairwise(Jaccard(), H, H, dims=2)
        S = ones(size(pair_dist_jac)) - pair_dist_jac

        # Cluster Hyperedges
        membership = Metis.partition(Graph(S), nclass, alg=:RECURSIVE)

        # Collapse Meta-clusters
        meta_clusters = zeros(len_bcs, nclass)
        for (i, v) in enumerate(membership)
            for j in 1:len_bcs
                meta_clusters[j, v] += H[j, i]
            end
        end

        # Compete for Objects
        celabel = zeros(Int32, len_bcs)
        for i in 1:len_bcs
            v = view(meta_clusters, i, :)
            candidate = []
            max_v = maximum(v)
            for (idx_v, elem_v) in enumerate(v)
                if elem_v == max_v
                    push!(candidate, idx_v)
                end
            end
            celabel[i] = rand(candidate)
        end

        celabel = convert.(Int, celabel)
        return celabel
    end

    # Hybrid Bipartite Graph Formulation
    function hbgf(base_clusters, nclass)
        A = create_hypergraph(base_clusters)
        rowA, colA = size(A)

        W = [zeros(colA, colA) A'; A zeros(rowA, rowA)]
        membership = Metis.partition(Graph(W), nclass, alg=:RECURSIVE)
        celabel = convert.(Int, membership[colA+1:end])

        return celabel
    end

    function create_connectivity_matrix(base_clusters)
        len_bcs, n_bcs = size(base_clusters)
        M = zeros(len_bcs, len_bcs)
        m = zeros(len_bcs, len_bcs)

        for i in 1:n_bcs
            bc = view(base_clusters, :, i)
            for j in 1:len_bcs
                if ismissing(bc[j])
                    continue
                end
                for k in 1:len_bcs
                    if ismissing(bc[k])
                        continue
                    end
                    if bc[j] == bc[k]
                        m[j, k] = 1
                    end
                end
            end
            M += m
            fill!(m, 0)
        end
        M ./= n_bcs

        return M
    end

    function orthogonal_nmf_algorithm(W::Matrix{T}, nclass, maxiter) where T
        n = size(W)[1]
        Q = rand(n, nclass)
        S = diagm(rand(nclass))
        QS = Matrix{T}(undef, n, nclass)
        WQS = Matrix{T}(undef, n, nclass)
        QTQ = Matrix{T}(undef, nclass, nclass)

        for _ in 1:maxiter
            # Update Q
            mul!(QS, Q, S)
            mul!(WQS, W, QS)
            Q .*= sqrt.( WQS ./ (Q * Q' * WQS .+ 1e-8) )
            # Update S
            mul!(QTQ, Q', Q)
            S .*= sqrt.( (Q' * W * Q) ./ (QTQ * S * QTQ .+ 1e-8) )
        end

        return Q, S
    end

    # NMF-based consensus clustering
    function nmf(base_clusters, nclass; maxiter=200)
        len_bcs, n_bcs = size(base_clusters)

        M = create_connectivity_matrix(base_clusters)
        Q, S = orthogonal_nmf_algorithm(M, nclass, maxiter)
        tmp = Q * sqrt.(S)

        celabel = Array{Int}(undef, len_bcs)
        for i in 1:len_bcs
            celabel[i] = argmax(view(tmp, i, :))
        end

        return celabel
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
        elseif alg == :mcla
            consensus_clustering_label = mcla(base_clusters, nclass)
        elseif alg == :nmf
            consensus_clustering_label = nmf(base_clusters, nclass)
        else
            throw(ArgumentError("Invalid algorithm."))
        end

        return consensus_clustering_label
    end

end
