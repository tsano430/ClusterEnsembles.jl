# ClusterEnsembles

A Julia package for cluster ensembles. 

[![Build Status](https://travis-ci.org/tsano430/ClusterEnsembles.jl.svg?branch=main)](https://travis-ci.org/tsano430/ClusterEnsembles.jl)

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
		2 3 2 1; 2 3 3 2; 
		3 1 3 missing; 
		3 1 3 missing]

julia> celabel = cluster_ensembles(base_clusters, 10)
```

References
----------

[1] A. Strehl and J. Ghosh, 
"Cluster ensembles -- a knowledge reuse framework for combining multiple partitions,"
Journal of Machine Learning Research, vol. 3, pp. 583-617, 2002.

[2] X. Z. Fern and C. E. Brodley, 
"Solving cluster ensemble problems by bipartite graph partitioning,"
In Proceedings of the Twenty-First International Conference on Machine Learning, p. 36, 2004.

