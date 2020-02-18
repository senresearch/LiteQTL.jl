using LMGPU
using Test


@test LMGPU.get_geno_data() == 1
@test LMGPU.get_pheno_data() == 0
