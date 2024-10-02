# AGORA release 12/2017

#### 1. Strain name changes and strain removal

  - The reconstruction "Bacillus timonensis JC401" has been renamed to "Bacillus timonensis 10403023".
This was done in to correspond with the organism's name listed in [KBase](https://narrative.kbase.us/#/dataview/KBasePublicGenomesV5/kb%7Cg.23344) and [NCBI Taxonomy](https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=1033734).
  - The reconstruction "Bifidobacterium stercoris ATCC 43183" has been renamed to "Bifidobacterium stercoris 24849". This was done to correspond with the organism name listed in [PATRIC](https://www.patricbrc.org/view/Genome/592977.3#view_tab=overview). The [KBase entry](https://narrative.kbase.us/#/dataview/KBasePublicGenomesV5/kb%7Cg.239977) for this organism lists only the species name "Bifidobacterium stercoris", but notes the source ID "592977.3", which corresponds with the PATRIC entry linked above.
  - The reconstruction "Proteus mirabilis ATCC 35198" has been renamed to "Proteus penneri ATCC 35198". This was done in to correspond with the organism's name listed in [KBase](https://narrative.kbase.us/#/dataview/KBasePublicGenomesV5/kb%7Cg.1703).
  - The change listed in 3) resulted in two AGORA reconstructions of the same strain "Proteus penneri ATCC 35198". Because the previously named "Proteus mirabilis ATCC 35198" reconstruction is based on a more recent genome (kb|g.1703), the older version of the "Proteus penneri ATCC 35198" reconstruction has been removed.

#### 2. Addition of newly reconstructed strains

A total of 46 strains have been reconstructed (see list in Table 1) and published in [BioArxiv](https://www.biorxiv.org/content/early/2017/12/04/229138). The strains were reconstructed followed the pipeline established in Magnusdottir et al., Nature Biotechnology 2017. The total number of reconstructed strains contained in AGORA 12/2017 is 818.

#### 3.	Expansion of AGORA by a bile acid deconjugation and transformation module

The reconstruction of bile acid deconjugation and transformation pathways is described in this [reference](https://www.biorxiv.org/content/early/2017/12/04/229138). In total, 217 AGORA models were supplemented with the appropriate bile acid metabolism metabolites and reactions. The bile acid module consists of 39 metabolites and 82 reactions (see lists in Table 2).

#### 4.	Correction of gene-protein-reaction associations

Certain AGORA models contained incorrect gene-protein-reaction (GPRs) with missing Boolean rules for reactions associated with more than one gene. These cases were corrected by inserting the Boolean rules.

#### 5.	Implementation of an Average European diet

An Average European diet supplemented with conjugated primary bile acids was defined for simulations described in this [reference](https://www.biorxiv.org/content/early/2017/12/04/229138). In AGORA release 12/2017, the models constrained with the Average European diet and conjugated primary bile acids are provided. Note that the diet was defined for microbiome models and will thus lead to high growth rates in the single models.
