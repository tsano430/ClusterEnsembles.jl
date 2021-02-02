using LinearAlgebra
using Metis
using LightGraphs
using Test
using Clustering

base_clusters = 
label_true = 

# test mcla
label_mcla = cluster_ensembles()
nmi_mcla = mutualinfo(label_true, label_mcla, true)
@test nmi_mcla == 1.0

# test hbgf
label_hbgf = cluster_ensembles()
nmi_hbgf = mutualinfo(label_true, label_hbgf, true)
@test nmi_hbgf == 1.0