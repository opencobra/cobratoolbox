# MOOMIN
MOOMIN (Mathematical explOration of Omics data on a MetabolIc Network) is a tool for analysing differential expression data. It takes as its input a metabolic network and the results of a DE analysis: a posterior probability of differential expression and a (logarithm of a) fold change for a list of genes.
It then forms a hypothesis of a metabolic shift, determining for each reaction its status as "increased flux",
"decreased flux", or "no change". These are expressed as colours: red for an increase, blue for a decrease, and grey for no
change. See the paper for full details: https://doi.org/10.1093/bioinformatics/btz584

# Dependencies
MOOMIN runs in Matlab (developed in R2016a) and relies on the COBRA Toolbox (developed with v2.0, tested with v3.0). Additionally, a MILP-solver compatible with
COBRA is needed (currently only IBM CPLEX is supported).

# Usage
In order to use MOOMIN, you need DE results obtained using Bayesian methods. In other words, a posterior probability of differential expression (PPDE) is needed instead of the more common p-value.
You also need a metabolic network of the organism under study. You can read an SBML-file (.xml) using the COBRA-function
"readSBML" or you can download a Matlab-structure containing a COBRA model directly if one is available.

# Citation
If you use MOOMIN, please cite the original paper:
Taneli Pusa, Mariana Galvão Ferrarini, Ricardo Andrade, Arnaud Mary, Alberto Marchetti-Spaccamela, Leen Stougie, Marie-France Sagot, MOOMIN – Mathematical explOration of ’Omics data on a MetabolIc Network, Bioinformatics, btz584, https://doi.org/10.1093/bioinformatics/btz584