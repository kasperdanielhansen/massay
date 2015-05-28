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
    .assertExperimentHub(object)
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

getTags <- function(object) {
    .assertExperimentHub(object)
    sapply(object@ehub, getTag)
}

subsetBySample <- function(object, j, drop = FALSE) {
    .assertExperimentHub(object)
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

selectAssays <- function(object, i) {
    .assertExperimentHub(object)
    if(is.character(i)) {
        i <- match(i, getTags(object))
    }
    ## FIXME: links needs to be subsetted
    ## FIXME: should we subset masterSampleData?
    new("ExperimentHub", hub = object@hub[i], links = object@links,
        metadata = object@metadata, masterSampleData = masterSampleData)
}

getAssay <- function(object, i) {
    .assertExperimentHub(object)
    if(is.character(i)) {
        i <- match(i, getTags(object))
    }
    .assertScalar(x)
    object@hub[[i]]@experiment
}
    
