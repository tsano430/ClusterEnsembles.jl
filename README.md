# ClusterEnsembles

Cluster ensembles generate a single consensus cluster using base clusters obtained from multiple clustering algorithms. The consensus cluster stably achieves a high clustering performance. 

Installation
------------

```
]add ClusterEnsembles
```

Usage
-----

```julia
julia> using ClusterEnsembles

julia> celabel = cluster_ensembles(base_clusters, 10, 'hbgf')
```

- `nclass`: Number of classes in a consensus cluster
- `solver`: {'mcla', 'hbgf'}
    
    `mcla`: Meta-CLustering Algorithm [1]
    
    `hbgf`: Hybrid Bipartite Graph Formulation [2]


References
----------

[1] A. Strehl and J. Ghosh, 
"Cluster ensembles -- a knowledge reuse framework for combining multiple partitions,"
Journal of Machine Learning Research, vol. 3, pp. 583-617, 2002.

[2] X. Z. Fern and C. E. Brodley, 
"Solving cluster ensemble problems by bipartite graph partitioning,"
In Proceedings of the Twenty-First International Conference on Machine Learning, p. 36, 2004.

