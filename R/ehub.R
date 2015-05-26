setClassUnion("ValidMassayClasses",
              c("eSet", "SummarizedExperiment"))

setClass("SerializedExperiment", representation(
    tag = "character",
    serType = "character",
    assayPath = "character",
    sampleDataPath = "character")) 

setClass("LoadedExperiment", representation(
    tag = "character",
    experiment = "ValidMassayClasses")) ## Should we keep serType, assayPath around so we can unload

loadExperiment <- function(object) {
    if(is(object, "LoadedExperiment"))
        return(object)
    stopifnot(is(object, "SerializedExperiment"))
    if(object@serType == "RData") {
        ## Here we assume that anything stored as RData can be loaded as is
        new("LoadedExperiment", tag = object@tag, experiment = get(load(object@assayPath)))
    }
}

.short_print_Experiment <- function(object, space = " ") {
    if(is(object, "SerializedExperiment")) {
        cat(sprintf("%s%s\n", space, object@tag))
        cat(sprintf("%s SerializedExperiment (%s)\n", space, object@assayPath))
        return()
    }
    if(is(object, "LoadedExperiment")) {
        cat(sprintf("%s%s\n", space, object@tag))
        cat(sprintf("%s LoadedExperiment (%s | %d x %d)\n",
                    space, class(object@experiment), nrow(object@experiment), ncol(object@experiment)))
        return()
    }
    stop("Unknown class")
}

setMethod("show", "SerializedExperiment", function(object) {
    cat("An object of class 'SerializedExperiment'\n")
    cat(" tag:", object@tag, "\n")
    cat(" serType:", object@serType, "\n")
    cat(" assayPath:", object@assayPath, "\n")
    cat(" sampleDataPath:", object@sampleDataPath, "\n")
})

setMethod("show", "LoadedExperiment", function(object) {
    cat("An object of class 'LoadedExperiment'\n")
    cat(" tag:", object@tag, "\n")
    cat(" class:", class(object@experiment), "\n")
    cat("-----\n")
    show(object@experiment)
})

setMethod("[", "LoadedExperiment", function(x, i, j, ..., drop = FALSE) {
    if(missing(i) && missing(j))
        x@experiment <- x@experiment[...,drop=drop]
    if(missing(i) && !missing(j))
        x@experiment <- x@experiment[, j, ...,drop=drop]
    if(!missing(i) && missing(j))
        x@experiment <- x@experiment[i,,...,drop=drop]
    if(!missing(i) && !missing(j))
        x@experiment <- x@experiment[i,j,...,drop=drop]
    x
})

setMethod("sampleNames", "LoadedExperiment", function(object) {
    if(hasMethod("sampleNames", class(object@experiment)))
        return(sampleNames(object@experiment))
    if(is(object, "SummarizedExperiment"))
        return(colnames(object@experiment))
})

## A hub is just a collection of experiments

setClass("ExperimentHub", representation(
    hub = "list",
    links = "list",
    metadata = "ANY", ## Not sure we need this
    masterSampleData = "DataFrame"))

setMethod("show", "ExperimentHub", function(object) {
    cat("ExperimentHub with", length(object@hub),
        "experiments.  User-defined tags:\n")
    for(ii in seq(along = object@hub)) {
        .short_print_Experiment(object@hub[[ii]]) 
    }
    pd <- pData(object)
    cat(sprintf("Sample level data is\n %d samples x %d covariates\n", nrow(pd), ncol(pd)))
})

loadHub <- function(hub) {
    stopifnot(is(hub, "ExperimentHub"))
    obj <- lapply(hub@hub, loadExperiment)
    names(obj) <- sapply(hub@hub, function(x) x@tag)
    hub@hub <- obj
    hub
}

setMethod("pData", "ExperimentHub", function(object)
    object@masterSampleData)

setMethod("sampleNames", "ExperimentHub", function(object) {
    rownames(pData(object))
})

subsetBySample <- function(object, j, drop = FALSE) {
    if(is.numeric(j)) {
        j <- sampleNames(object)[j]
    }
    object@hub <- lapply(object@hub, function(oo) {
        jj <- j[j %in% sampleNames(oo)]
        oo <- oo[,jj,drop = drop]
        oo
    })
    object@masterSampleData <- object@masterSampleData[j,]
    object
}






## setGeneric("featExtractor", function(x) standardGeneric("featExtractor"))
## setMethod("featExtractor", "ExpressionSet", function(x) featureNames(x))
## setMethod("featExtractor", "SummarizedExperiment", function(x) rownames(x))

## setMethod("show", "LoadedExperimentHub", function(object) {
##  cat("LoadedExperimentHub instance.\n")
##  dimmat = t(sapply(object@elist, dim))
##  colnames(dimmat) = c("Features", "Samples") # dim for eSet nicer than for SE!
##  featExemplars = lapply(object@elist, function(x) head(featExtractor(x),3))
##  featExemplars = sapply(featExemplars, paste, collapse=", ")
##  featExemplars = substr(featExemplars, 1, 25)
##  featExemplars = paste(featExemplars, "...")
##  dimmat = data.frame(dimmat, feats.=featExemplars)
##  print(dimmat)
## })

