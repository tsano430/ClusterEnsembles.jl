using Test
using Clustering
using ClusterEnsembles
using Random

Random.seed!(5678)

base_cluster1 = [1 1 1 2 2 3 3]
base_cluster2 = [2 2 2 3 3 1 1]
base_cluster3 = [1 1 2 2 3 3 3]
base_cluster4 = [1 2 missing 1 2 missing missing]
base_clusters = [base_cluster1' base_cluster2' base_cluster3' base_cluster4']

label_true = [1 1 1 2 2 3 3]

# test set_nclass
label_pred = cluster_ensembles(base_clusters)
@test length(unique(label_pred)) == 3

# test hbgf
label_pred = cluster_ensembles(base_clusters, nclass=3, alg=:hbgf)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0

# test mcla
label_pred = cluster_ensembles(base_clusters, nclass=3, alg=:mcla)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0

# test nmf
label_pred = cluster_ensembles(base_clusters, nclass=3, alg=:nmf)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0

# test cspa
label_pred = cluster_ensembles(base_clusters, nclass=3, alg=:cspa)
@test mutualinfo(label_true, label_pred, normed=true) == 1.0