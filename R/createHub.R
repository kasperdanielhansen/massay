createHub <- function(masterpheno, objlist, drop=FALSE, samplemaps=NULL){
  ## samplemaps will be maps that rename samples in object list to names used in masterpheno.
  if(!is(masterpheno, "data.frame"))
     stop("masterpheno should be a data.frame of metadata for all samples")
  if(!is(objlist, "list"))
      stop("objlist should be a named list of data objects")
  ##-----------------------
  ##TODO: sample names mapping if samplemaps provided
  ##-----------------------
  ##Sample names checking:
  has.pheno <- lapply(objlist, function(x) colnames(x) %in% rownames(masterpheno))
  if(!drop){
      errmsg <- paste("Missing the following number of masterpheno entries for each data type: ",
                      paste(names(objlist), ":", sapply(has.pheno, function(x) sum(!x)), collapse=", "),
                      ". Set drop=TRUE to drop these observations, or add samples to masterpheno.")
      stop(errormsg)
  }else{
      message("Dropping the following samples:")
      for (i in 1:length(objlist)){
          if(all(has.pheno[[i]])) next
          message(paste(names(objlist)[i], ":", collapse=""))
          message(paste(colnames(objlist[[i]])[!has.pheno[[i]]], collapse=" "))
          message("\n ")
          objlist[[i]] <- objlist[[i]][, has.pheno[[i]]]
      }

  }
  exptlist <- lapply(1:length(objlist), function(i) new("expt",
     serType="in-memory", assayPath="", tag=names(objlist)[i]))
  hub <- new("ExperimentHub", hub=exptlist, masterSampleData=masterpheno)
  res <- new("LoadedExperimentHub", basehub=hub, elist=objlist)
}
