using Test
using Clustering
using ClusterEnsembles

base_clusters = [1 1 1 2 2 3 3; 2 2 2 3 3 1 1; 1 1 2 2 3 3 3; 1 2 missing 1 2 missing missing]
label_true = [1 1 1 2 2 3 3]

label_pred = cluster_ensembles(Array(base_clusters'), 3)

@test mutualinfo(label_true, label_pred, normed=true) == 1.0

