massay
------

## Decisions

1. Should we operate on (many) basic Bioc objects like `ExpressionSet` and `SummarizedExperiment` and others, and basically store these objects inside our multi assay container.

	list(assay1 = "ExpressionSet", assay2 = "SummarizedExperiment")

In this way we need to do tons of book keeping, 



with associated metadata and friends. Or should this be limited to a small set of basic classes, with a single shared `pData` object?

2. I want to store links between elements as 
