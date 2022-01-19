# Microbiome Modeling Toolbox version 2.0

## Efficient, tractable modelling of microbiome communities

### Authors: Almut Heinken and Ines Thiele

National University of Ireland Galway

This COBRA Toolbox extension enables the creation, simulation, and analysis of microbe-microbe interactions and personalized community models obtained through metagenomic data integration. The toolbox was designed to use a resource of genome-scale reconstructions of 773 human gut microbes, AGORA (Magnúsdóttir S, Heinken A, Kutt L, Ravcheev DA, et al, Nat Biotechnol. 35(1):81-89 (2017)). However, the implemented functions are in principle applicable to any resource of genome-scale reconstructions.

This is an updated version of the Microbiome Modeling Toolbox version 1.0, published by Baldini F, Heinken A, Heirendt L, Magnúsdóttir S, Fleming RMT, Thiele I., The Microbiome Modeling Toolbox: from microbial interactions to personalized microbial communities. Bioinformatics. 35(13):2332-2334 (2019). Compared with its predecessor, the computational efficiency of model generation and interrogation has been greatly increased , and additional functionalities have been added. Moreover, the input parameter have been simplified.

The folder [/pairwiseInteractionModeling](https://github.com/opencobra/cobratoolbox/tree/master/src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling)
contains functions for the analysis of microbe-microbe interactions, including the prediction of interaction types (e.g., commensalism, competition) and computation of all possible trade-offs between two microbes. A tutorial explaining the simulation of microbe-microbe interactions step by step is available at cobratoolbox/tutorials/analysis/microbeMicrobeInteractions/MicrobeMicrobeInteractions.mlx.

The folder [/mgPipe](https://github.com/opencobra/cobratoolbox/tree/master/src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe) contains functions for personalized modeling of microbiome communities. Relative abundances obtained from 16S rRNA or metagenomic sequencing data serve as the input data. If species-or genus-level data is the input, pan-models generated from the AGORA resource, rather than the AGORA reconstructions themselves, serve as the model-building resource. The mgPipe folder contains functions to translate and normalize abundance files and to build pan-models.
In its basic form, the mgPipe workflow results in the generation of personalized microbiome models and the computation of each microbiome's metabolite uptake and secretion potential.
The folder [/additionalAnalysis](https://github.com/opencobra/cobratoolbox/tree/master/src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis) contains additional functions that perform targeted analyses, visualize the simulation results in the form of violin plots, and run statistical analyses. A detailed tutorial of all the functions for microbiome modelling, simulation, and sample stratification contained in the toolbox is available at cobratoolbox/tutorials/analysis/microbiomeModelingToolbox/tutorial_mgPipe.mlx.

**Extensive documentation on the different folder content
and purpose of functions can be found in the `README file of each folder.**

## Funding
This study received funding from the Luxembourg National Research Fund(FNR), through the ATTRACT programme (FNR/A12/01), and the OPEN grant (FNR/O16/11402054), as well as the European Research Council(ERC) under the European Union's Horizon 2020 research and innovation programme (grant agreement No 757922), and from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (grant agreement No 757922), and by the National Institute on Aging grants (1RF1AG058942-01 and 1U19AG063744-01).
