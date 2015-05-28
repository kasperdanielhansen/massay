# An API for multassay containers

eHub is a multiassay container representing a number of assays with corresponding Bioconductor classes.

The first design attempt centers around encapsulating entire Bioconductor classes inside an eHub.  There are advantages to this (no coersion for example) and disadvantages (duplication of information).

The assays can be linked by samples or by features.

Insight: any feature linking we have discussed ultimately reduces to linking certain features of one assay to another.  We can represent this by a Hits object from IRanges.  I think this abstraction is general enough to cover most cases.  We have two possibilities
(1) The Hits object gets constructed on the fly
(2) The Hits object is stored inside eHub
We need to allow for (2).  Some assay linking (say proteins to genes or microRNA to genes) are too complicated to do on the fly.  However, this means the number of links in worst case scales as nAssays^2.


MAC is a multiassay container representing a number of assays with corresponding Bioconductor
classes.

These assays can be linked in multple dimensions. Links

  - linking by sample identifier. Relevant for all assays.
  - linking by genomic location.
  - linking by common feature, example: gene id.

Whenever two or more assays are linked, we can thinking about subsetting.

I propose to (at first, see below), only use the bracket notation for sample subsetting, like

	MAC[i]

with i being sample.

For more specialized linking we will use

	subsetByLocation(MAC)[gr]

This will subset all assays (for which this is relevant) by the GRanges.  One could think about
dimension 2 in different ways

	subsetByLocation(MAC[i])[gr]
	subsetByLocation(MAC)[gr,i]

But the second way is more alike current usage.

This design allows us to have multiple linking functions in play simultanously.

We also need
  - To subset only a specific assay, using the full range of subset methods for that assay.  Also
    relevant for samples: contrast "dropping sample i" vs "dropping expression values for sample
    i".
  - To select a set of assays, like methylation and expression.
One complication with the first one, is that we want to return the full dataset.  One solution is
    subsetByAssay(MAC, "exprs")[i,j]
which returns MAC, but with the exprs assay subsetted by i,j.

Brackets on speed: Once we have selectByXX implemented, we could use the first dimension in the bracket to be a search using the identifier across possible subsetByXX methods. This assumes that a
given identifier only is relevant for a single selectByXX.  This is slightly different from dispatching on class.  Consider

	MAC[aa,]

where aa is a string. It could represent gene id, or it could 

# API

    MAC : eHub

The following subsets are closures

	MAC[j] # subset by sample (j can be integer or name)
	selectByLocation(MAC)[gr,j] # subset by gr, sample j, for the assays where it makes sense
	selectAssasy(MAC, c("assay1", "assay2")) # selects assays 1, 2
	selectByAssay(MAC, "assay")[i,j] # subset using the relevant subset operater assay "assay"
	assay(MAC, "assay") # returns the actual assay with its original class
	linkByLocation(MAC, c("assay1", "assay2")) # returns a 'hit' matrix



# Questions

- Should our basic object be based on existing classes or a new rollout?  Pros and cons of both.  We
  would need class-specific glue for each of the existing classes, but it would make "what can we do
  with this object" much easier.
- We need pairwise Hits, and subsetting of these Hits, between assays.


# Implementation


