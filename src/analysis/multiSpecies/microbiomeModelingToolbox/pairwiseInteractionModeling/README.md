# Microbiome Modeling Toolbox

## A COBRA Toolbox extension enabling the interrogation and analysis of microbial communities

### Authors: Federico Baldini, Almut Heinken, and Ines Thiele

Luxembourg Centre for Systems Biomedicine, University of Luxembourg

This enables the simulation of microbial pairwise interactions with COBRA
Toolbox functions.  To simulate the interactions between two reconstructed
microbes, it is necessary to build a joint matrix of the two individual
genome-scale reconstructions. The joint matrix enables the two joined
reconstructions to freely exchange metabolites with each other as well as
access some defined nutrient input via a shared compartment. Unless the modeler
imposes additional constraints on the transport reactions between the
individual reconstructions and the shared compartment, each reconstruction can
access every metabolite it can transport from the shared compartment.
Constraints implementing the nutrient conditions are set on the exchange
reactions on the shared compartment.

The function `createMultipleSpeciesModel` can
be used to join any desired number of reconstructions. Note that the
prerequisite for simulating multi-species interactions is that the nomenclature
for reactions and metabolites matches for any joined
genome-scale-reconstructions. It is the responsibility of the user to ensure
uniform nomenclature. There are six possible interactions between bacteria
that can be predicted with the present method:

* competition
* parasitism
* amensalism
* neutralism
* commensalism
* mutualism

Please see the if taxon information is missing for at least one microbe in the
pairwise interactions input file function `simulatePairwiseInteractions` for a
brief description of these interactions. Note that the predicted interaction
depends on the reactions and metabolites encoded in each individual
genome-scale reconstruction as well as on the imposed constraints. For one
pairwise model, different interactions may be predicted on different simulated
nutrient conditions.

This method was used to join the AGORA resource, consisting of 773 gut
microbial metabolic reconstructions, in every possible combination (~300,000
total) and predict the interactions between each pair on two diets in
the absence and presence of oxygen. Please see [Magnusdottir, Heinken et al.,
Nat Biotechnol. 2017 35(1):81-89
(PMID:27893703)](https://www.ncbi.nlm.nih.gov/pubmed/27893703)
for a detailed description of the simulation results.

The LiveScripts `MicrobeMicrobeInteractions.mlx` and `HostMicrobeInteractions.mlx`
located in the `/tutorials` folder provide examples application using the AGORA
resource (PMID:27893703).

This study received funding from the Luxembourg National Research Fund(FNR), through the ATTRACT programme (FNR/A12/01), and the OPEN
grant (FNR/O16/11402054), as well as the European Research Council(ERC) under the European Union’s Horizon 2020 research and innovation
programme (grant agreement No 757922).
