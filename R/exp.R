setClassUnion("ValidExperimentClasses",
              c("eSet", "SummarizedExperiment"))

####################################################
### SerializedExperiment
####################################################

setClass("SerializedExperiment", representation(
    tag = "character",
    serType = "character",
    assayPath = "character",
    sampleDataPath = "character")) 

setMethod("show", "SerializedExperiment", function(object) {
    cat("An object of class 'SerializedExperiment'\n")
    cat(" tag:", getTag(object), "\n")
    cat(" serType:", object@serType, "\n")
    cat(" assayPath:", object@assayPath, "\n")
    cat(" sampleDataPath:", object@sampleDataPath, "\n")
})

setMethod("getTag", "SerializedExperiment",
          function(object, ...) {
              object@tag
          })

loadExperiment <- function(object) {
    if(is(object, "LoadedExperiment"))
        return(object)
    stopifnot(is(object, "SerializedExperiment"))
    if(object@serType == "RData") {
        ## Here we assume that anything stored as RData can be loaded as is
        new("LoadedExperiment", tag = getTag(object), experiment = get(load(object@assayPath)))
    }
}


####################################################
### LoadedExperiment
####################################################

setClass("LoadedExperiment", representation(
    tag = "character",
    experiment = "ValidExperimentClasses"))
## FIXME: Should we keep serType, assayPath around so we can unload?

setMethod("show", "LoadedExperiment", function(object) {
    cat("An object of class 'LoadedExperiment'\n")
    cat(" tag:", getTag(object), "\n")
    cat(" class:", class(getExperiment(object)), "\n")
    cat("-----\n")
    show(getExperiment(object))
    })
          
setMethod("getTag", "LoadedExperiment",
          function(object, ...) {
              object@tag
          })

setMethod("getExperiment", "LoadedExperiment",
          function(object, ...) {
              object@experiment
          })

setMethod("[", "LoadedExperiment", function(x, i, j, ..., drop = FALSE) {
    if(missing(i) && missing(j))
        x@experiment <- getExperiment(x)[...,drop=drop]
    if(missing(i) && !missing(j))
        x@experiment <- getExperiment(x)[, j, ...,drop=drop]
    if(!missing(i) && missing(j))
        x@experiment <- getExperiment(x)[i,,...,drop=drop]
    if(!missing(i) && !missing(j))
        x@experiment <- getExperiment(x)[i,j,...,drop=drop]
    x
})

setMethod("sampleNames", "LoadedExperiment", function(object) {
    sampleNames(getExperiment(object))
})


setMethod("pData", "LoadedExperiment", function(object) {
    pData(getExperiment(object))
})

setMethod("colData", "LoadedExperiment", function(x) {
    colData(getExperiment(x))
})

setMethod("ncol", "LoadedExperiment", function(x) {
    ncol(getExperiment(x))
})

setMethod("nrow", "LoadedExperiment", function(x) {
    nrow(getExperiment(x))
})

.short_print_Experiment <- function(object, space = " ") {
    if(is(object, "SerializedExperiment")) {
        cat(sprintf("%s%s\n", space, getTag(object)))
        cat(sprintf("%s SerializedExperiment (%s)\n", space, object@assayPath))
        return()
    }
    if(is(object, "LoadedExperiment")) {
        cat(sprintf("%s%s\n", space, getTag(object)))
        cat(sprintf("%s LoadedExperiment (%s | %d x %d)\n",
                    space, class(getExperiment(object)),
                    nrow(object), ncol(object)))
        return()
    }
    stop("Unknown class")
}

