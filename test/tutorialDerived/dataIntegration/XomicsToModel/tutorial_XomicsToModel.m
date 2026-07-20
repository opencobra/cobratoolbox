%% Extraction of context-specific models via XomicsToModel
%% Author: German Preciat, Analytical BioSciences, Leiden University
%% *Reviewer(s): Ronan M.T. Fleming, School of Medicine, University of Galway*
%% INTRODUCTION
% The |XomicsToModel| pipeline${\;}^1$ of the COBRA Toolbox v3.4${\;}^2$, facilitates 
% the generation a thermodynamic-flux-consistent, context-specific, genome-scale 
% metabolic model in a single command by combining a generic model with bibliomic, 
% transcriptomic, proteomic, and metabolomic data. To ensure the network's quality, 
% several thermodynamic consistency checks are implemented within the function. 
% To generate a thermodynamic-flux-consistent, context-specific, genome-scale 
% metabolic model, the function requires three inputs: a generic COBRA model and 
% two variables containing the context-specific data and technical information 
% defined by the user. 
% 
% This tutorial shows how to extract a context-specific genome-scale model of 
% a dopaminergic neuron (_iDopaNeuroC_${\;}^3$) from the human generic model Recon3D${\;}^4$ 
% . The _iDopaNeuroC_${\;}^3$ model is extracted using data from manual curation 
% of a dopaminergic neuron to identify active and inactive genes, reactions, and 
% metabolites, as well as information from in vitro experiments such as exometabolomic 
% quantification and transcriptomic sequencing of a cell culture of pluripotent 
% stem cell-derived dopaminergic neurons.
%% PROCEDURE
%% 
% Install MATLAB and then the COBRA Toolbox as described here: <https://opencobra.github.io/cobratoolbox/stable/installation.html 
% https://opencobra.github.io/cobratoolbox/stable/installation.html>
% 
% Select a solver suitable for solving linear (LP) and quadratic (QP) optimisation 
% problems, e.g., mosek, gurobi, ibm_cplex, etc.

[~, ~] = changeCobraSolver('mosek', 'all', 0);
% Generic model
% The COBRA model Recon3D${\;}^4$, representing human metabolic reconstruction, 
% a can be found in a file with the extension ".mat". Recon3D${\;}^1$ , which 
% is found in the <https://www.vmh.life/#downloadview VMH> database${\;}^2$, can 
% be used as a generic model for human metabolism. The thermodynamic consistent 
% human metabolic reconstruction Recon3D${\;}^4$.

inputFolder = ['~' filesep 'work' filesep 'sbgCloud' filesep 'programExperimental' ...
    filesep 'projects' filesep 'xomics' filesep 'data' filesep 'Recon3D_301'];
genericModelName = 'Recon3DModel_301_xomics_input.mat';
load([inputFolder filesep genericModelName])
% Context-specific data
% This type of information represents the biological system's phenotype and 
% can be obtained through a review of the literature or experimental data derived 
% from the biological system. The context-specific data can be loaded from a spreadsheet 
% or added manually. 
% Automated data integration
% Tables or multiple data sets can be inserted in an external worksheet document 
% so that the |preprocessingOmicsModel| function can include them in the |options| 
% variable. The name of the sheet corresponding to the options field must be the 
% same as those specified above and in the manuscript, or they will be omitted.
% 
% *Bibliomic* *data.* It is derived from manual reconstruction following a review 
% of the literature. This includes data on the activation or inactivation of genes, 
% reactions, or metabolites. Another example is the addition of coupled reactions 
% or the constraints of different reactions based on phenotypic observations. 
%% 
% * |*specificData.activeGenes:*| List of Entrez ID of genes that are known 
% to be active based on the bibliomic data (Default: empty).
% * |*specificData.addCoupledRxns:*| Logical, should the coupled constraints 
% be added (Default: |true|).
% * |*specificData.coupledRxns:*| Logical, indicates whether curated data should 
% take priority over omics data (Default: false).
% * |*specificData.essentialAA:*| List exchange reactions of essential amino 
% acid (Default: empty).
% * |*specificData.inactiveGenes:*| List of Entrez ID of genes known to be inactive 
% based on the bibliomics data (Default: empty).
% * |*specificData.presentMetabolites:*| List of metabolites known to be active 
% based on the bibliomics data (Default: empty).
% * |*specificData.rxns2add:*| Table containing the identifier of the reaction 
% to be added, its name, the reaction formula, the metabolic pathway to which 
% it belongs, the gene rules to which the reaction is subject, and the references. 
% (Default: empty).
% * |*specificData.rxns2constrain:*| Table containing the reaction identifier, 
% the updated lower bound, the updated upper bound, a description for the constraint 
% and notes such as references or special cases (Default: empty).
%% 
% Manually curated data. To read the table and prepare the variable |specificData| 
% it is used the function |preprocessingOmicsModel|. In this tutorial the bibliomic 
% data is contained in the file _'bibliomicData.xlsx'_.

dataFolder = [fileparts(which('tutorial_XomicsToModel.mlx')) filesep 'iDopaNeuro' filesep 'data' filesep];
bibliomicData = 'bibliomicData.xlsx';
specificData = preprocessingOmicsModel([dataFolder bibliomicData], 1, 1);
%% 
% *Metabolomic data.* Differences in measured concentrations of metabolites 
% within cells, biofluids, tissues, or organisms are translated into flux units 
% of flux ($\mu \textrm{mol}/\textrm{gDW}/h$).
%% 
% * |*specificData.cellCultureData:*| Table containing the cell culture data 
% used to calculate the uptake flux. Includes well volume ($L$), time interval 
% cultured ($\textrm{hr}$), average protein concentration ($g/L$), assay volume 
% ($L$), protein fraction ($g/g\;\textrm{dry}\;\textrm{weight}$) , and the sign 
% for uptakes (Default: -1).
% * |*specificData.exoMet:*| Table with the fluxes obtained from exometabolomics 
% experiments. It includes the reaction identifier, the reaction name, the measured 
% mean flux, standard deviation of the measured flux, the flux units, and the 
% platform used to measure it.
% * |*specificData.mediaData:*| Table containing the initial media concentrations. 
% Contains the reaction identifier, the maxiumum uptake ($\mu \textrm{mol}/\textrm{gDW}/h$) 
% based on the concentration of the metabolite and the concentration ($\mu \textrm{mol}$; 
% Default: empty). 
%% 
% In this tutorial the exometabolomic data is saved in the table 'exoMet'.

specificData.exoMet = readtable([dataFolder 'exometabolomicData.txt']);
%% 
% *Proteomic data.* This information indicates the level of expression of the 
% proteome. 
%% 
% * |*specificData.proteomics:*| Table with a column with Entrez ID's and a 
% column for the corresponding protein levels (Default: empty).
%% 
% For this tutorial no proteomic data was used.
% 
% *Transcriptomic data.* Indicates the level of transcriptome expression and 
% can also be used to calculate reaction expression. Transcriptomic data can be 
% analysed in FPKM.
%% 
% * |*specificData.transcriptomicData:*| Table with a column with Entrez ID's 
% and a column for the corresponding transcriptomics expresion value (Default: 
% empty).
%% 
% In this tutorial the transcriptomic analysis is saved in the table 'transcriptomicData'.

specificData.transcriptomicData = readtable([dataFolder 'transcriptomicData.txt']);
specificData.transcriptomicData.genes = string(specificData.transcriptomicData.genes);
% *Technical parameters*
% With these options, technical constraints can be added to the model, as well 
% as setting the parameters for model extraction or debugging.
% 
% *Bounds.* They are the instructions that will be set in the boundaries.
%% 
% * |*param.boundPrecisionLimit:*| Precision of flux estimate, if the absolute 
% value of the lower bound (|model.lb|) or the upper bound (|model.ub|) are lower 
% than |options.boundPrecisionLimit| but higher than 0 the value will be set to 
% the boundPrecisionLimit (Default: primal feasibility tolerance).
% * |*param.TolMaxBoundary:*| The reaction boundary's maximum value (Default: 
% $1\textrm{e3}$).
% * |*param.TolMinBoundary:*| The reaction boundary's minimum value (Default: 
% $-1\textrm{e3}$).
% * |*param.relaxOptions:*| A structure array with the relaxation options (Default: 
% |param.relaxOptions.steadyStateRelax = 0|). 

param.TolMinBoundary = -1e4;
param.TolMaxBoundary =  1e4;
feasTol = getCobraSolverParams('LP', 'feasTol');
param.boundPrecisionLimit = feasTol * 10;
%% 
% *Exchange reactions.* They are the instructions for the exchange, demand, 
% and sink reactions.
%% 
% * |*param.addSinksexoMet:*| Logical, should sink reactions be added for metabolites 
% measured in the media but without existing exchange reaction (Default: false). 
% * |*param.closeIons:*| Logical, it determines whether or not ion exchange 
% reactions are closed. (Default: false). 
% * |*param.closeUptakes:*| Logical, decide whether or not all of the uptakes 
% in the generic model will be closed (Default: false).
% * |*param.nonCoreSinksDemands:*| The type of sink or demand reaction to close 
% is indicated by a string (Possible options: |'closeReversible'|,  |'closeForward'|,  
% |'closeReverse'|, |'closeAll'| and |'closeNone'|; Default: |'closeNone'|).

param.closeIons = true; 
param.closeUptakes = true;
param.nonCoreSinksDemands = 'closeAll';
param.sinkDMinactive = true;
%% 
% *Extraction options.* The solver and parameters for extracting the context-specific 
% model.
%% 
% * |*param.activeGenesApproach:*| String with the name of the active genes 
% approach will be used (Possible options: |'oneRxnsPerActiveGene'| or |'deletModelGenes'|; 
% Default: |'oneRxnsPerActiveGene'|).
% * |*param.fluxCCmethod:*| String with thee name of the algorithm to be used 
% for the flux consistency check (Possible options: |'swiftcc'|, |'fastcc'| or 
% |'dc'|, Default: |'fastcc'|).
% * |*param.fluxEpsilon:*| Minimum non-zero flux value accepted for tolerance 
% (Default: Primal feasibility tolerance). 
% * |*param.thermoFluxEpsilon:*| Flux epsilon used in |'thermoKernel'| (Default: 
% feasibility tolerance).
% * |*param.tissueSpecificSolver:*| The name of the solver to be used to extract 
% the context-specific model (Possible options: |'thermoKernel'| and |'fastcore'|; 
% Default: |'thermoKernel'|). 

param.activeGenesApproach = 'oneRxnPerActiveGene';
param.tissueSpecificSolver = 'thermoKernel'; 
param.fluxEpsilon = feasTol * 10;
param.fluxCCmethod = 'fastcc';
%% 
% *Data-specific parameters.* Parameters that define the minimum level of transcript/protein 
% to be considered as present in the network (treshold) and weather the transcripts 
% below the set treshold should be removed from the model.
%% 
% * |*param.addCoupledRxns:*| Logical, should the coupled constraints be added 
% (Default: false). *! CAUTION* If it is TRUE and the table coupledRxns is empty, 
% the step is not performed.
% * |*param.curationOverOmics:*| Logical, indicates whether curated data should 
% take priority over omics data (Default: false).
% * |*param.inactiveGenesTranscriptomics:*| Logical, indicate if inactive genes 
% in the transcriptomic analysis should be added to the list of inactive genes 
% (Default: true).
% * |*param.metabolomicWeights:*| String indicating the type of weights to be 
% applied for metabolomics fitting (Possible options: |'SD'|, |'mean'| and |'RSD'|; 
% Default: |'SD'|).
% * |*param.setObjective:*| Linear objective function to optimise (Default: 
% empty).
% * |*param.tresholdP:*| The proteomic cutoff threshold (in linear scale) for 
% determining whether or not a gene is active (Default: $0$).
% * |*param.transcriptomicThreshold:*| The transcriptomic cutoff threshold (in 
% logarithmic scale) for determining whether or not a gene is active (Default: 
% $0$)
% * |*param.weightsFromOmics:*| Should gene weights be assigned based on the 
% omics data (Default: 0).

param.addCoupledRxns = 1;
param.curationOverOmics = false;
param.inactiveGenesTranscriptomics = true; 
param.metabolomicWeights='mean';
param.transcriptomicThreshold = 2; 
param.weightsFromOmics = true;
%% 
% *Debugging options.* The user can specify the function's verbosity level as 
% well as save the results of the various blocks of the function for debugging.
%% 
% * |*param.debug:*| Logical, should the function save its progress for debugging 
% (Default: false).
% * |*param.diaryFilename:*| Location where the output be printed in a diary 
% file (Default: 0).
% * |*param.printLevel:*| Level of verbose that should be printed (Default: 
% 0).

param.printLevel = 1;
param.debug = true;
if isunix()
    name = getenv('USER');
else
    name = getenv('username');
end
param.diaryFilename = [pwd filesep datestr(now,30) '_' name '_diary.txt'];
% XomicsToModel function

[iDopaNeuro1, modelGenerationReport] = XomicsToModel(model, specificData, param);
%% Examining when active metabolites, reactions and genes were added or removed during the model generation process

debugXomicsToModel(model, pwd, modelGenerationReport)
%% TIMING
% TIMING: 15 minutes to hours (computation) - days (interpretation)
%% Bibliography
%% 
% # Preciat, G., Wegrzyn, A. B., Luo, X., Thiele, I., Hankemeier, T., & Fleming, 
% R. M. T. (2025). XomicsToModel: omics data integration and generation of thermodynamically 
% consistent metabolic models. Nature Protocols. <https://doi.org/10.1038/s41596-025-01288-9 
% https://doi.org/10.1038/s41596-025-01288-9> 
% # Laurent Heirendt, Sylvain Arreckx, Thomas Pfau, et al., "Creation and analysis 
% of biochemical constraint-based models using the COBRA Toolbox v. 3.0", _Nature 
% protocols_ (*2019*).
% # German Preciat, Edinson Lucumi Moreno, Agnieszka B. Wegrzyn, et al., "Mechanistic 
% model-driven exometabolomic characterisation of human dopaminergic neuronal 
% metabolism", _bioRxiv_ (*2021*)
% # Elizabeth Brunk, Swagatika Sahoo, Daniel C. Zielinski, et al., "Recon3D 
% enables a three-dimensional view of gene variation in human metabolism", _Nature 
% biotechnology_ (*2018*)