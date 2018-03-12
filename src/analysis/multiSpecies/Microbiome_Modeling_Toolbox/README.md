%%% Microbiome Modeling Toolbox-a COBRA Toolbox extension enabling the interrogation and analysis of microbial communities %%%
Authors: Federico Baldini, Almut Heinken, and Ines Thiele

Luxembourg Centre for Systems Biomedicine, University of Luxembourg



The module Microbiome Modeling Toolbox/PairwiseInteractionModeling enables the simulation of microbial pairwise interactions with COBRA Toolbox functions. 
To simulate the interactions between two reconstructed microbes, it is necessary to build a joint matrix of the two individual genome-scale reconstructions. The joint matrix enables the two joined reconstructions to freely exchange metabolites with each other as well as access some defined nutrient input via a shared compartment. Unless the modeler imposes additional constraints on the transport reactions between the individual reconstructions and the shared compartment, each reconstruction can access every metabolite it can transport from the shared compartment. Constraints implementing the nutrient conditions are set on the exchange reactions on the shared compartment.The function createMultipleSpeciesModel can be used to join any desired number of reconstructions. Note that the prerequisite for simulating multi-species interactions is that the nomenclature for reactions and metabolites matches for any joined genome-scale-reconstructions. It is the responsibility of the user to ensure uniform nomenclature.
There are six possible interactions between bacteria that can be predicted with the present method: competition, parasitism, amensalism, neutralism, commensalism, and mutualism. Please see the function simulatePairwiseInteractions for a brief description of these interactions. Note that the predicted interaction depends on the reactions and metabolites encoded in each individual genome-scale reconstruction as well as on the imposed constraints. For one pairwise model, different interactions may be predicted on different simulated nutrient conditions.

This method was used to join the AGORA resource, consisting of 773 gut microbial metabolic reconstructions, in every possible combination (~300,000 total) and predict the interactions between each pair on two diets in the absence and presence of oxygen. Please see Magnusdottir, Heinken et al., Nat Biotechnol. 2017 35(1):81-89 (PMID:27893703) for a detailed description of the simulation results.

The LiveScript runMicrobeInteractionAnalysis.mlx located in the Tutorials folder provides an example application using the AGORA resource (PMID:27893703). The script may be adapted to users' own genome-scale reconstructions and/or simulation conditions as convenient.The tutorial consists of three steps:
1. Creation of pairwise microbe models in all possible combinations from a given list of microbe reconstructions.
2. Simulation of the pairwise interactions for the created microbe-microbe models on four dietary conditions.
3. Visualization of interactions displayed in total and on the genus, family, order, class, and phylum level.
