setClassUnion("ValidMassayClasses",
              c("eSet", "SummarizedExperiment"))

setClass("SerializedExperiment", representation(
    tag = "character",
    serType = "character",
    assayPath = "character",
    sampleDataPath = "character")) 

setMethod("show", "SerializedExperiment", function(object) {
    cat("An object of class 'SerializedExperiment'\n")
    cat(" tag:", object@tag, "\n")
    cat(" serType:", object@serType, "\n")
    cat(" assayPath:", object@assayPath, "\n")
    cat(" sampleDataPath:", object@sampleDataPath, "\n")
})

setClass("LoadedExperiment", representation(
    tag = "character",
    experiment = "ValidMassayClasses"))
## FIXME: Should we keep serType, assayPath around so we can unload?

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

getTag <- function(object) {
    .assertExperiment(object)
    object@tag
}

