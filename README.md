# ClusterEnsembles.jl

[![Build Status](https://travis-ci.org/tsano430/ClusterEnsembles.jl.svg?branch=main)](https://travis-ci.org/tsano430/ClusterEnsembles.jl)
[![Coverage Status](https://coveralls.io/repos/github/tsano430/ClusterEnsembles.jl/badge.svg?branch=main)](https://coveralls.io/github/tsano430/ClusterEnsembles.jl?branch=main)

A Julia package for cluster ensembles. Cluster ensembles generate a single consensus cluster using base clusters obtained from multiple clustering algorithms. The consensus cluster stably achieves a high clustering performance.

Installation
------------

```
]add ClusterEnsembles
```

Usage
-----

```julia
julia> using ClusterEnsembles

julia> base_clusters = [
		1 2 1 1;
		1 2 1 2; 
		1 2 2 missing; 
		2 3 2 1; 
		2 3 3 2; 
		3 1 3 missing; 
		3 1 3 missing]

julia> cluster_ensembles(base_clusters, 3)

```

Reference
---------

[1] X. Z. Fern and C. E. Brodley, 
"Solving cluster ensemble problems by bipartite graph partitioning,"
In Proceedings of the Twenty-First International Conference on Machine Learning, p. 36, 2004.

