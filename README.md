# ClusterEnsembles.jl

[![Build Status](https://travis-ci.org/tsano430/ClusterEnsembles.jl.svg?branch=main)](https://travis-ci.org/tsano430/ClusterEnsembles.jl)
[![Coverage Status](https://coveralls.io/repos/github/tsano430/ClusterEnsembles.jl/badge.svg?branch=main)](https://coveralls.io/github/tsano430/ClusterEnsembles.jl?branch=main)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Julia package for cluster ensembles. Cluster ensembles generate a single consensus cluster using base clusters obtained from multiple clustering algorithms. The consensus cluster stably achieves a high clustering performance.

<p align="center">
  <img width="600" src="https://user-images.githubusercontent.com/60049342/107722358-17c47a00-6d22-11eb-9040-b13b92f97ba1.png">
</p>

Installation
------------

```
Pkg.add("ClusterEnsembles")
```

Usage
-----

Simple example of cluster ensembles in the reference [1]

```julia
julia> using ClusterEnsembles

julia> base_cluster1 = [1 1 1 2 2 3 3];

julia> base_cluster2 = [2 2 2 3 3 1 1];

julia> base_cluster3 = [1 1 2 2 3 3 3];

julia> base_cluster4 = [1 2 missing 1 2 missing missing];

julia> base_clusters = [base_cluster1' base_cluster2' base_cluster3' base_cluster4']
7×4 Array{Union{Missing, Int64},2}:
 1  2  1  1
 1  2  1  2
 1  2  2   missing
 2  3  2  1
 2  3  3  2
 3  1  3   missing
 3  1  3   missing

julia> cluster_ensembles(base_clusters, nclass=3, alg=:hbgf)
7-element Array{Int64,1}:
 1
 1
 1
 3
 3
 2
 2
```

- `nclass`: Number of classes in a consensus cluster.

- `random_state`: Used for 'mcla' and 'nmf'. Pass a nonnegative integer for reproducible results.

- `alg`: {`:cspa`, `:mcla`, `:hbgf`, `:nmf`, `:all`}

    `:cspa`: Cluster-based Similarity Partitioning Algorithm [1].
    
    `:mcla`: Meta-CLustering Algorithm [1].
    
    `:hbgf`: Hybrid Bipartite Graph Formulation [2].

    `:nmf`: NMF-based consensus clustering [4].

    `:all`: Use all solvers, and then return the consensus clustering label with the largest objective function value [1].
    
    <p align="center">
      <img width="600" src="https://user-images.githubusercontent.com/60049342/110207481-14f31a00-7ec7-11eb-96cf-4e03a6ad8990.png">
    </p>
    
    **Note:** Please use `:hbgf` for large-scale `base_clusters`.


References
----------

[1] A. Strehl and J. Ghosh, 
"Cluster ensembles -- a knowledge reuse framework for combining multiple partitions,"
Journal of Machine Learning Research, vol. 3, pp. 583-617, 2002.

[2] X. Z. Fern and C. E. Brodley, 
"Solving cluster ensemble problems by bipartite graph partitioning,"
In Proceedings of the Twenty-First International Conference on Machine Learning, p. 36, 2004.

[3] J. Ghosh and A. Acharya, 
"Cluster ensembles," 
Wiley Interdisciplinary Reviews: Data Mining and Knowledge Discovery, vol. 1, no. 4, pp. 305-315, 2011. 

[4] T. Li, C. Ding, and M. I. Jordan, 
"Solving consensus and semi-supervised clustering problems using nonnegative matrix factorization," 
In Proceedings of the Seventh IEEE International Conference on Data Mining, pp. 577-582, 2007.
