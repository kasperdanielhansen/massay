setMethod("pData", "SummarizedExperiment", function(object) {
    as.data.frame(colData(object))
})

setMethod("colData", "ExpressionSet", function(x) {
    as(pData(x), "DataFrame")
})

setMethod("sampleNames", "SummarizedExperiment", function(object) {
    colnames(object)
})
