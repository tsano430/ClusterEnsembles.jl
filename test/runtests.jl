# runtests.jl

using Test
using Clustering
using ClusterEnsembles
using Random
using CSV
using DataFrames

Random.seed!(5678)

println("Tests for ClusterEnsembles.jl")

# Load test data1
base_cluster1 = [1 1 1 2 2 3 3]
base_cluster2 = [2 2 2 3 3 1 1]
base_cluster3 = [1 1 2 2 3 3 3]
base_cluster4 = [1 2 missing 1 2 missing missing]
base_clusters = [base_cluster1' base_cluster2' base_cluster3' base_cluster4']
label_true = [1 1 1 2 2 3 3]

# Load test data2
# - https://github.com/tsano430/ClusterEnsembles/blob/main/ClusterEnsembles/tests/data/create_test_data.py
base_clusters2 = convert(Matrix, DataFrame(CSV.File("./data/base_clusters.csv", header=false)))
label_true2 = vec(convert(Matrix, DataFrame(CSV.File("./data/label_true.csv", header=false))))

# Test set_nclass
print("* set_nclass -- ")
tmp = cluster_ensembles(base_clusters)
@test length(unique(tmp)) == 3
println("OK")

# Test alg
for alg in [:hbgf, :nmf, :cspa, :mcla]
    print("* ", alg, " -- ")
    label_pred = cluster_ensembles(base_clusters, nclass=3, alg=alg)
    @test mutualinfo(label_true, label_pred, normed=true) == 1.0
    label_pred2 = cluster_ensembles(base_clusters2, alg=alg)
    @test mutualinfo(label_true2, label_pred2, normed=true) == 1.0
    println("OK")
end
