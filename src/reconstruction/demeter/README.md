# DEMETER (Data-drivEn METabolic nEtwork Refinement)

## A COBRA Toolbox extension for efficient simultaneous curation and data-driven refinement of automated draft reconstructions

### Authors: Almut Heinken, Stefanía Magnúsdóttir, Ronan M.T. Fleming, and Ines Thiele

The COBRA Toolbox extension DEMETER enables the simultaneous refinement of many reconstructions at once based on comparative genomics and experimental data. DEMETER was previously used to reconstruct 818 human gut microbial reconstructions, AGORA (Magnúsdóttir, Heinken et al, Nat Biotech 2017), and its expansion, AGORA2, accounting for 7,206 strains (Heinken et al, preprint on bioRxiv). The starting point is a draft reconstruction generated through the KBase framework (kbase.us/). A template Narrative (https://narrative.kbase.us/narrative/81207) illustrates the process to retrieve draft reconstructions for your organisms. The prerequisite is a sequenced genome for each strain to reconstruct.

Steps performed by DEMETER include the translation from KBase to VMH (https://www.vmh.life/) nomenclature, gap filling and constraining to ensure anaerobic growth and thermodynamic consistency, and refinement based on experimental data for carbon sources, fermentation products, and growth requirements. Data for over 1,000 species is available that is propagated to new strains of these species by the DEMETER pipeline. Comparative genomics analyses provided in PubSEED spreadsheet format also serves as input data to expand and refine genome-scale reconstructions. A comprehensive test and debugging suite ensures that the resulting models are thermodynamically consistent and agree with known traits of the organism. DEMETER is computationally efficient and has been successfully run for thousands of genome-scale reconstructions.

Besides tools for reconstruction refinement and testing, DEMETER also contains functions for computing and comparing various properties of refined genome-scale reconstructions. For instance, the metabolite and reaction presence across all reconstructed strains can be computed and subsequently clustered by similarity.

The LiveScript tutorial_demeter.mlx located in the tutorials/reconstruction/demeter folder of the COBRA Toolbox demonstrates how to run DEMETER for 10 example draft reconstructions. The tutorial also provides an example of how to apply the computations of model properties to AGORA and cluster strains by the similarity of reconstructed features.

## Funding

This study received funding from the Luxembourg National Research Fund(FNR) through the ATTRACT programme (FNR/A12/01), from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (grant agreement No 757922) to IT, and by the National Institute on Aging grants (1RF1AG058942-01 and 1U19AG063744-01).
