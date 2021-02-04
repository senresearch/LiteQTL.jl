bxd_geno = "http://genenetwork.org/api/v_pre1/genotypes/BXD.geno"
spleen_pheno="http://datafiles.genenetwork.org/download/GN283/GN283_MeanDataAnnotated_rev081815.txt"

download(bxd_geno, joinpath(@__DIR__,"..", "data", "rawdata", "bxd.geno"))
download(spleen_pheno, joinpath(@__DIR__,"..", "data", "rawdata", "bxdspleen.txt"))
