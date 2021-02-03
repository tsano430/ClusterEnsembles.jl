using Test
using Clustering
using ClusterEnsembles

base_cluster1 = [1 1 1 2 2 3 3]
base_cluster2 = [2 2 2 3 3 1 1]
base_cluster3 = [1 1 2 2 3 3 3]
base_cluster4 = [1 2 missing 1 2 missing missing]
base_clusters = [base_cluster1' base_cluster2' base_cluster3' base_cluster4']

label_true = [1 1 1 2 2 3 3]

# test 1
label_pred = cluster_ensembles(base_clusters, nclass=3)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0

# test 2
label_pred = cluster_ensembles(base_clusters)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0
