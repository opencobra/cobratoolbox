clc
%% %%% Configuration file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This configuration file contains all information needed for running 
% runPersephone.m. This file is loaded by runPersephone(configFilePath) 
% when calling the function. Please carefully go through this file and make
% changes to the configurations where needed. Any variable indicated with 
% *REQUIRED* must be filled in. 
%
% INDEX:
% 0.  Set required inputs: For the full pipeline to run you MUST provide a
%     path to your results folder. Variable inputs that are used for more 
%     than one part of the pipeline
% 1.0 SeqC: Bioinformatic processing of metagenomic sequencing files
% 2.0 MARS: map your relative abundances to the AGORA2 or APOLLO database 
% 3.0 MgPipe: create microbiome models from your mapped relative abundances
% 4.0 WBM personalisation: where metadata is available, personalise the 
%     germ-free WBM models
% 5.0 mWBM creation: combine your microbiome models with WBM models 
% 6.0 Flux analysis: Simulate metabolism in your models, obtain flux values
% 7.0 Statistical Analysis: Statistically analyse your flux values

%% %%% 0. Set required inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Full path where you would like your results stored.  *REQUIRED*
resultPath = ''; 

% Diet for constraining models (microbiome, personalized WBMs or mWBM-WBMs)
paths.General.diet = 'EUAverageDiet';

% Path to metadata
paths.General.metadataPath = '';

% Choose your solver
paths.General.solver = '';

% Numeric value, amount of workers that are to be used for creation of
% microbiome models and mWBMs (we recommend using 80% of possible number of 
% available workers here) 
paths.General.numWorkersCreation = round(feature('numCores')*0.8);

% Numeric value, amount of workers that are to be used for optimisation of
% microbiome models, iWBMs, mWBMs and/or miWBMs
paths.General.numWorkersOptimisation = 1;

%% %%% 1. SeqC Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Additional parameters related to MARS are inherited from the MARS 
% subsection.

% Logical variable indicating if bioinformatic processing of sequencing 
% data is performed by SeqC
paths.seqC.flagSeqC = false;

% *REQUIRED*. Full path to the directory where the SeqC repository is 
% located.
paths.seqC.repoPathSeqC = '';

% Full path to the directory where the final output of SeqC is stored.
paths.seqC.outputPathSeqC = fullfile(resultPath,'ResultSeqC');

% *REQUIRED*. Full path to the file containing sample IDs for FASTQ files 
% (e.g., sample_id.txt).
paths.seqC.fileIDSeqC = '';

% Logical variable indicating if intermediary outputs are retained 
% (e.g., post-QC FASTQ). False results in only the final MARS output being 
% kept, and deletion of intermediary content.
paths.seqC.procKeepSeqC = false;  

% Numeric value defining the maximum amount of memory allowed in gigabytes.
paths.seqC.maxMemSeqC = 20;

% Numeric value defining the maximum number of CPU threads allowed.
paths.seqC.maxCpuSeqC = round(feature('numCores')*0.8);

% Numeric value defining the maximum number of processes allowed.
paths.seqC.maxProcSeqC = 1;
% Logical
paths.seqC.debugSeqC = false;

% Logical variable indicating if Apptainer/singularity
paths.seqC.runApptainer = false;

%% %%% 2. MARS Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Logical variable indicating if taxonomic mapping by MARS 
% is performed independently of SeqC.
paths.Mars.flagMars = true;

% *REQUIRED*. Character array variable with path to the microbiome taxonomy 
% and read abundance file.
paths.Mars.readsTablePath = '';

% Character array variable to the folder where the output of MARS is stored.
paths.Mars.outputPathMars = fullfile(resultPath,'ResultMars');

% Numeric value for total read counts per sample under which samples are
% excluded from analysis. Only applies when readsTable contains absolute
% read counts (not relative abundances). Defaults to 1, with a minimum of 1.
paths.Mars.sampleReadCountCutoff = 1;

% Numeric value under which relative abundances are considered to be zero.
paths.Mars.cutoffMars = 0.000001;

% String to the file where OTUs are matched to taxonomic assignments.
% OPTIONAL if the taxonomic assignments are already in the readsTable. 
% REQUIRED if not.
paths.Mars.taxaTablePath = string(missing);

% A boolean to indicate if the genus name is in the name of the species e.g.
% Prevotella copri. If genus name is in species name, set to false. 
% Otherwise, set to true. OPTIONAL, defaults to false.
paths.Mars.flagLoneSpecies = false;

% The delimiter used to separate taxonomic levels.
paths.Mars.taxaDelimiter = ';';

% A boolean specifying if one wants to remove clade name extensions from
% all taxonomic levels of microbiome taxa. If set to false, MARS might find
% significantly fewer models in AGORA2, as clade extensions are not 
% included there.
paths.Mars.removeClade = true;

% A string defining if AGORA2, APOLLO, a combination of both, or a user-
% defined database should be used as the model database to check presence 
% in.  Allowed Input (case-insensitive): "AGORA2", "APOLLO", "full_db", 
% "user_db".
paths.Mars.reconstructionDb = 'full_db';


% A string containing the full path to the user-defined database,
% which should be in .csv, .txt, .parquet, or .xlsx format and
% have column names = taxonomic levels. Only required if whichModelDatabase
% is set to "user_db".
paths.Mars.userDbPath ="";

% Boolean to indicate if Bray Curtis should be calculated for microbiome
% samples. Defaults to false.
paths.Mars.calculateBrayCurtis = false;

% Boolean; specifies is the reads table is compounded or not. Compounded 
% here means that the reads for a specific taxonomic level are taking into 
% account the taxonomic level above it
paths.Mars.compoundedDatabase = false;
%% %%%% 3. MgPipe Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boolean, indicates if Part 3 of the pipeline MgPipe/microbiome model 
% creation should be run.
paths.mgPipe.flagMgPipe = true; 

% Path to relative abundance file. Defaults to MARS output, update if not 
% using MARS.
paths.mgPipe.relAbunFilePath = fullfile(paths.Mars.outputPathMars,...
    'renormalized_mapped_forModelling',...
    'renormalized_mapped_forModelling_species.csv');

% Assign directory for mgPipe results
paths.mgPipe.outputPathMgPipe = fullfile(resultPath,'resultMgPipe');

% Set path to pan models (pan models are available to download using the 
% links listed)...
% AGORA2 pan-species reconstructions: https://doi.org/10.7910/DVN/LAO2XM
% APOLLO pan-species reconstructions: https://doi.org/10.7910/DVN/PIZCBI
% AGORA2+APOLLO pan-species reconstructions: https://doi.org/10.7910/DVN/JAXTWY
paths.mgPipe.microbeReconstructionPath = '';

% Boolean, indicates if netSecretion and netUptake are calculated for the 
% microbiome models via fastFVA. OPTIONAL, defaults to false
paths.mgPipe.computeProfiles = false;


%%  %%% 4. WBM personalisation inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boolean, indicates if Part 3 of the pipeline: WBM personalisation should 
% be run. OPTIONAL, defaults to false.
paths.persWBM.flagPersonalise = true;

% Path in which to store personalized WBMs and overview of
% personalization
paths.persWBM.outputPathPersonalisation = fullfile(resultPath, ...
    'personalisedWBMs');

% WBM as struct, OPTIONAL - default Harvey and Harvetta, WBMs found in the
% cobratoolbox will be used.
paths.persWBM.maleWBMPath = '';
paths.persWBM.femaleWBMPath = '';

% Define the exact columns of the metadata that you would like used in the
% personalisation of WBMs
paths.persWBM.persPhysiology = {};

% Define the metabolites that you would like to be used in the
% personalisation of WBMs which should match columns of the metadata
% provided
paths.persWBM.persMetabolites = {};

%% %%% 5. mWBM creation inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boolean, indicates if Part 4 of the pipeline: mWBM creation and 
% descriptive statistics should be run. OPTIONAL, defaults to true
paths.mWBM.flagMWBMCreation = true; 

% The path where the mWBM models will be stored.
paths.mWBM.outputPathMWBM = fullfile(resultPath, 'mWBMmodels');

% Boolean, if set to true the metadata provided (where parameters are 
% suitable) will be used to personalise the germfree WBM before combining 
% with the microbiome models. 
paths.mWBM.usePersonalisedWBM = true;

% Path to the models that you want to be combined with the microbiome
% models. Default path is to those created in step 3 if run, otherwise
% specify path below
paths.mWBM.alteredWBMPath = paths.persWBM.outputPathPersonalisation;

%% %%% 6. Flux analysis inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Boolean, indicates if Part 6 of the pipeline: FBA should be run.
paths.fba.flagFBA = true; 

% String with the path where the flux results should be stored.
paths.fba.outputPathFluxResult = fullfile(resultPath,'resultFlux');

% String with the path where the analyses of the flux results are stored.
paths.fba.outputPathFluxAnalysis = fullfile(...
    paths.fba.outputPathFluxResult,'fluxAnalysis');

% Boolean, indicates if the complete .v, .y., and .w vectors are stored in
% the result. OPTIONAL, defaults to true. It is recommended to set 
% saveFullRes.
paths.fba.saveFullRes = true;

% *REQUIRED.* Character array containing reaction IDs for reactions that 
% are to be optimised. If the user wants to solve non-existing demand 
% reactions, simply add DM_ in front of the desired metabolite and add to 
% the rxnList variable.
paths.fba.rxnList = {};

% Choose the sense of the objectives when solved FBA, default is max. User
% can choose one sense for all: max/min. Or provide a cell array in equal
% length to the rxnList with one sense for each reaction. 
paths.fba.rxnSense = {};

% Analyse germ-free models. If true, runs an additional FBA with microbiome 
% exchange blocked. Generates one germ-free model per subject 
% (if personalised) or per sex (if not). Can greatly increase runtime for 
% large datasets where personalisation is performed. Consider setting to 
% false in these scenarios.
paths.fba.analyseGF = true;

% Set flux processing parameters

% .NumericalRounding defines how much the predicted flux values are
% rounded. A defined value of 1e-6 means that a flux value of
% 2 + 2.3e-8 is rounded to 2. A flux value of 0 + 1e-15 would be rounded to
% exactly zero. This rounding factor will also be applied to the shadow 
% price values. If microbiome relative abundance data is provided, the same
% rounding factor will be applied to the relative abundance data.
paths.fba.paramFluxProcessing.numericalRounding = 1.00E-06;

% .RxnRemovalCutoff defines the minimal number of samples for which a
% unique reaction flux could be obtained, before removing the reaction for 
% further analysis. This parameter can be expressed as 
% * fraction:  the fraction of samples with unique values, 
% * SD: the standard deviation across samples, and
% * count: the counted number of unique values. If microbiome relative 
% abundance data is provided, the same removal cutoff factor will be 
% applied to the relative abundance data.
paths.fba.paramFluxProcessing.rxnRemovalCutoff = {'fraction', 0.1};
%% %%% 7. Statistical Analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Logical variable indicating if a statistical analysis should be run on 
% the obtained fluxes and relative taxon abundances against a user-defined
% response variable.
paths.stats.flagStatistics = true; 

% String with the path where the results of the statistical analyses and 
% the figures should be saved.
paths.stats.outputPathStatistics = fullfile(resultPath,'resultStatistics');

% *REQUIRED* A character or string array with variables found in the 
% metadata file that the user wants to use as response for statistical 
% analysis.
paths.stats.response = {};

% A character or string array with variables found in the metadata file 
% that are used as confounders in the statistical analyses.
paths.stats.confounders = {};