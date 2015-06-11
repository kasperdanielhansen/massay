## A hub is just a collection of experiments

setClass("MultiAssayExperiment", representation(
    experiments = "list",
    links = "list",
    metadata = "ANY", ## Not sure we need this
    sampleData = "DataFrame"))

getExperiments <- function(object) {
    .assertMultiAssayExperiment(object)
    object@experiments
}

getLinks <- function(object) {
    .assertMultiAssayExperiment(object)
    object@links
}

setMethod("show", "MultiAssayExperiment", function(object) {
    cat("MultiAssayExperiment with", length(getExperiments(object)),
        "experiments.  User-defined tags:\n")
    for(ii in seq(along = getExperiments(object))) {
        .short_print_Experiment(getExperiments(object)[[ii]]) 
    }
    cat(sprintf("Sample level data is\n %d samples x %d covariates\n", ncol(object), ncol(colData(object))))
})

setMethod("colData", "MultiAssayExperiment", function(x) {
    x@sampleData
})

getSampleData <- function(object) {
    object@sampleData
}
              
setMethod("ncol", "MultiAssayExperiment", function(x) {
    nrow(colData(x))
})

setMethod("sampleNames", "MultiAssayExperiment", function(object) {
    rownames(colData(object))
})

setMethod("getTag", "MultiAssayExperiment", function(object, i) {
    if(missing(i))
        sapply(getExperiments(object), slot, "tag")
    else
        getTag(getExperiments(object)[[i]])
})

loadExperiments <- function(mAexp) {
    .assertMultiAssayExperiment(mAexp)
    obj <- lapply(getExperiments(mAexp), loadExperiment)
    names(obj) <- getTag(mAexp)
    mAexp@experiments <- obj
    mAexp
}


## Subsetting / Selecting      
          
subsetBySample <- function(object, j, drop = FALSE) {
    .assertMultiAssayExperiment(object)
    if(is.numeric(j)) {
        j <- sampleNames(object)[j]
    }
    object@experiments <- lapply(getExperiments(object), function(oo) {
        jj <- j[j %in% sampleNames(oo)]
        oo <- oo[,jj,drop = drop]
        oo
    })
    object@masterSampleData <- object@masterSampleData[j,]
    object
}

selectAssays <- function(object, i) {
    .assertMultiAssayExperiment(object)
    if(is.character(i)) {
        i <- match(i, getTags(object))
    }
    ## FIXME: links needs to be subsetted
    ## FIXME: should we subset masterSampleData?
    new("MultiAssayExperiment", experiments = getExperiments(object)[i], links = object@links,
        metadata = object@metadata, masterSampleData = masterSampleData)
}

getAssay <- function(object, i) {
    .assertMultiAssayExperiment(object)
    if(is.character(i)) {
        i <- match(i, getTags(object))
    }
    .assertScalar(x)
    getExperiment(getExperiments(object)[[i]])
}
    
