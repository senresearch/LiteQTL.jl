library(mice)
library(parallel)
library(qtl2)
library(tidyverse)
library(tictoc)

getdata<-function(url){
  return(read_cross2(url))
}

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
    cat("++++++++ writing out to +++++++++++++ ", gmap_file)
    write.csv(map, file = gmap_file,row.names = FALSE)
  }
  pr <- calc_genoprob(cross, map, error_prob=error_prob, cores=ncore)
  return(pr)
}

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

clean_and_write<-function(url, geno_output_file="geno_prob.csv", pheno_output_file="pheno.csv", new_gmap_file="gmap.csv",
                          scan=FALSE,result_file="rqtl_result.csv",
                          indi_droprate=0.0, trait_droprate=0.0, nseed=100, ncores=1, error_prob=0.002, stepsize=0){

  bxd = getdata(url)
  print("got data from url")


  # innerjoin
  # pick out shared bxd ids in geno and pheno
  bxd_ids <- ind_ids_gnp(bxd)
  cat("dimention of bxd_ids:", dim(bxd_ids))
  joint_bxd <- subset(bxd, ind = bxd_ids)

  # pick out the ones with no missing data
  filled_ids <- ind_ids(joint_bxd)[complete.cases(joint_bxd$pheno)]
  cat("dimention of filled_ids :", dim(filled_ids))
  filled_bxd = subset(joint_bxd, ind = filled_ids)

  # calculate genotype probablity
  pr = calc_gprob_update_gmap(new_gmap_file, filled_bxd, ncores, error_prob, stepsize, FALSE)
  prob1 = getGenopr(pr)
  print("calculating geno prob done")
  cat("dimention of geno :", dim(prob1))

  write.csv(filled_bxd$pheno, file = pheno_output_file)
  write.csv(prob1, file = geno_output_file)
  print("writing out pheno and geno done")

  if(scan){
    print("Doing genome scan")
    tic()
    out = scan1(pr, filled_bxd$pheno, cores=32)
    toc()
    print("writing out result file.")
    write.csv(out,file=result_file)
  }
}

args = commandArgs(trailingOnly=TRUE)
clean_and_write(args[1], args[2], args[3], args[4], args[5])
