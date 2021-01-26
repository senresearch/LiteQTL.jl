using LMGPU 
using CSV 
using DelimitedFiles
using DataFrames

pheno_file = "/export/xiaoqihu/git/tensorqtl/example/cleanpheno.csv"
geno_file = "/export/xiaoqihu/git/tensorqtl/example/cleangeno.csv"
export_matrix = false

@time pheno = LMGPU.get_pheno_data(pheno_file, Float64, transposed=true)
# 10.865656 seconds (47.21 M allocations: 1.625 GiB, 12.64% gc time)
@time geno = CSV.read(geno_file)
# 109.905806 seconds (41.48 M allocations: 46.943 GiB, 0.58% gc time)
# @time genomat = convert(Matrix{Float32}, geno[:, 3:end]) |> transpose |> collect
# geno = Nothing

# pick out chr1 genos 
genobychr = groupby(geno, :Column2)
onechr = genobychr[(Column2="9",)]
# Chr1: 5618644x447; 
# Chr2: 1738829; 
# Chr3: 919842; 
# Chr4: 944044; 
# Chr5: 820554; 
# Chr6: 849929
# Chr7: 762694
# Chr8: 719376
# Chr9: 558963
# ChrX: 436393

# It takes about 60 seconds to do this step. 
datatype = Float64
@time genomat = convert(Matrix{datatype}, onechr[:, 3:end]) |> transpose |> collect
pheno = convert(Matrix{datatype}, pheno)
# gc
genobychr = Nothing; 
geno = Nothing;
chr1geno = Nothing;

LMGPU.set_blas_threads(16);

G = genomat;
Y = pheno;

genomat = Nothing
pheno = Nothing 

n = size(Y,1)
m = size(Y,2)
p = size(G,2)
println("******* Indivuduals n: $n, Traits m: $m, Markers p: $p ****************");

@time lodc = LMGPU.cpurun(Y, G,n,export_matrix);
@time lodg = LMGPU.gpurun(Y, G,n)
