setMethod("pData", "SummarizedExperiment", function(object) {
    as.data.frame(colData(object))
})

setMethod("colData", "ExpressionSet", function(object) {
    as(pData(object), "DataFrame")
})

setMethod("sampleNames", "SummarizedExperiment", function(object) {
    colnames(object)
})
