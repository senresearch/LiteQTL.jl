library(mice)
# library(lattice)
library(parallel)
library(qtl2)
library(tidyverse)

getdata<-function(url){
  return(read_cross2(url))
  # print("hello")
}
#keepidx<-which(rowSums(is.na(bxd$pheno))<1000798)

keep_row_idx<-function(pheno, droprate){
  rs = rowSums(is.na(pheno)) 
  keepidx <- which(rs/ncol(pheno) <= droprate)
  return(keepidx)
}

keep_col_idx<-function(pheno, droprate){

  cs = colSums(is.na(pheno))
  keepidx <- which(cs/nrow(pheno) <= droprate)
  return(keepidx)
}

calc_gprob_update_gmap<-function(gmap_file, cross, ncore=1, error_prob=0.002, step=0, pseudomarker=FALSE){

  #insert pseudomarker
  map = cross$gmap
  if(pseudomarker){
    map <- insert_pseudomarkers(map, step=step)
    write.csv(map, file=gmap_file, row.names = FALSE)
  }
  
  pr <- calc_genoprob(cross, map, error_prob=error_prob, cores=ncore)
  return(pr)
}

# intersect(phenotype, genotype, 
            # selected_pheno = "ProbeSet", 
            # selected_geno = one_of("Locus","Chr","cM","Mb"), 
            # match_name="BXD")

#get whole genotype prob file
getGenopr<-function(x){
  temp<<-NULL
  m=length(attributes(x)$names)
  cnames<-attributes(x)$names
  for (i in 1:m) {
    d<-eval(parse(text=paste(c('dim(x$\'', cnames[i] ,'\')'),collapse='')))
    nam<-eval(parse(text=paste(c('dimnames(x$\'',cnames[i],'\')[[2]]'),collapse = '')))
    cnam<-rep(nam,d[3])
    p_chr<-paste(c('array(x$\'',cnames[i],'\',dim=c(d[1],d[2]*d[3]))'),collapse='')
    prob<-eval(parse(text = p_chr))
    temp<-cbind(temp,prob)
  }
  return(temp)
}


# url : data url
# indi_droprate: droprate in percentage, ie: 10 percent
# trait_droprate : droprate in percentage, ie: 10 percent
# ncores: default detectCores()
clean_and_write<-function(url, geno_output_file="geno_prob.csv", pheno_output_file="pheno.csv", new_gmap_file="gmap.csv", 
                          indi_droprate=0.0, trait_droprate=0.0, nseed=100, ncores=1, error_prob=0.002, stepsize=1){  
  # url = "/Users/xiaoqihu/Documents/hg/genome-scan-data-cleaning/data/UTHSC_SPL_RMA_1210.zip"
  # geno_output_file="geno_prob.csv"
  # pheno_output_file="pheno.csv"
  # indi_droprate = 0.0
  # trait_droprate = 0.0
  # trait_droprate=0.0
  # nseed=100
  # ncores=1
  # error_prob=0.002
  # stepsize=1
  
  bxd = getdata(url)
  print("got data from url")

  # intersect 
  # pick out shared bxd ids in geno and pheno 
  bxd_ids <- ind_ids_gnp(bxd)
  joint_bxd <- subset(bxd, ind = bxd_ids)
  # pick out the ones with no missing data
  filled_ids <- ind_ids(joint_bxd)[complete.cases(joint_bxd$pheno)]
  filled_bxd = subset(joint_bxd, ind = filled_ids)
  
  # process pheno
  # trait = bxd$pheno
  # row_idx = keep_row_idx(trait, indi_droprate)
  # trait<-trait[row_idx,]
  # col_idx = keep_col_idx(trait, trait_droprate)
  # trait<-trait[,col_idx]
  # print("processing pheno done")
  
  #imputation
  # temp_imp = mice(trait,m=1, method = "norm", seed = nseed)
  #col_idx = keep_col_idx(trait, trait_droprate)
  #pheno[,col_idx]print("mice done")
  #imp = complete(temp_imp)
  #print("complete imputation done")
  
  # calculate genotype probablity
  pr = calc_gprob_update_gmap(new_gmap_file, filled_bxd, ncores, error_prob, step)
  prob1 = getGenopr(pr)
  print("calculating geno prob done")
  
  write.csv(filled_bxd$pheno, file = pheno_output_file)
  write.csv(prob1, file = geno_output_file)
  print("writing out pheno and geno done")

}

args = commandArgs(trailingOnly=TRUE)
clean_and_write(args[1])

