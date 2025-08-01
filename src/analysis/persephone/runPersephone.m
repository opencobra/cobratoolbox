function [progress] = runPersephone(configPath)
% This pipeline runs throught the entire process of mapping taxonomy
% assigned reads to AGORA2/APOLLO models to create relative abundance files
% through the MARS pipeline. The relative panSpecies abundance file is then
% used to create microbiome models through mgpipe (Microbiome Modelling
% Toolbox PMID:xx). Before HM models are created there is an option to
% personalise the WBMs with physiological or metabolomic data through the
% xx function. The HM creation can then either connect the microbiomes with
% base-WBMs based on the sex associated with the sample ID in the metadata
% file or connect it with a personalised WBM. Based on a list of reactions,
% the HM models will be solved and the flux results will be processed and
% various analyses such as shadow price and regression are performed. Then
% based on the make-up of the study used to run this pipeline,
% mixed-effect linear regression modelling can be used for various response
% variables while taking into account the effect of predictors. All
% response and predictor variables need to be present in the metadata file.
% By default the code will do perform two runs where in one flux data is
% added as an additional predictor and in the other the relative abundance
% of panSpecies models. Finally the results are visualised in various
% plots. The user can indicate which parts of the pipeline should be run
% with various "flags" described in the input variables below. If the code
% or matlab stops unexpectedly, parts of pipeline that are already
% performed will be skipped. If the entire pipeline should be rerun -
% delete the progress.mat file. If only certain parts of the pipeline
% should be rerun, open the progress.mat file and alter change the value of
% the relevant flags to false or 0.
%
% Most of the inputs are optional as the pipeline is designed that parts of
% the analysis could be skipped. This however means that some of the
% optional variables are actually required variables in order to run a
% certain part of the pipeline. Behind the input description indication if
% the variable is required is given.
%
% Updated: 2025.07.01 wbarton
%
% Usage:
%     fullPipeline()
%
% Inputs:
% Required inputs:
%     resultPath:      A string with the path to the directory where all
%                      results should be stored
%     metadataPath:    A string with the path to the metadata file.
%
% Optional inputs:
%     solver:          String, indicates which solver is to be used for solving WBMs.
%                      OPTIONAL, defaults to GLPK. It is highly recommended to use gurobi or cplex
% SeqC:
%     paths.seqC.flagSeqC:       Logical variable indicating if bioinformatic processing
%                                of sequencing data is performed by SeqC.
%     paths.seqC.repoPathSeqC:   *REQUIRED*. String specifying the directory where the
%                                SeqC repository is located.
%     paths.seqC.outputPathSeqC: String specifying the folder where the final output
%                                of SeqC is stored.
%     paths.seqC.fileIDSeqC:     *REQUIRED*. String specifying the file name containing
%                                sample IDs for FASTQ files (e.g., sample_id.txt).
%     paths.seqC.procKeepSeqC:   Logical variable indicating if intermediary outputs are
%                                retained (e.g., post-QC FASTQ). If false, only the final
%                                MARS output is kept, and all intermediary content is deleted
%                                once SeqC completes.
%     paths.seqC.maxMemSeqC:     Numeric value specifying the maximum amount of memory
%                                allowed in gigabytes.
%     paths.seqC.maxCpuSeqC:     Numeric value specifying the maximum number of CPU threads
%                                allowed for processing.
%     paths.seqC.maxProcSeqC:    Numeric value specifying the maximum number of parallel
%                                processes allowed.
%     paths.seqC.debugSeqC:      Logical variable indicating if additional debugging
%                                messages should be included in the log.
%     paths.seqC.runApptainer:   Logical variable indicating if Apptainer/singularity
%                                wrapper should be used.
% MARS:
%     paths.Mars.flagMars:             Boolean, indicates if Part 2 of the pipeline
%                           MARS should be run. OPTIONAL, Defaults to true
%     marsRepoPath:         String to the directory where the mars-pipeline
%                           repository is stored. REQUIRED
%     pythonPath:           String to the python.exe file. How to obtain
%                           the path is described in .txt. REQUIRED
%     OTUTable:             String to the file where OTUs are matched to
%                           taxonomic assignments. OPTIONAL if the
%                           taxonomic assignments are already in the
%                           readsTablePath. REQUIRED if not.
%     readsTablePath:       String to the file where the reads are assigned
%                           to either OTUs or taxonomic assignments.
%                           REQUIRED
%     outputPathMARS:       String to the directory where MARS should store
%                           the results. OPTIONAL, defaults to [resultPath,
%                           filesep, 'ResultMARS'].
%     cutoff:               Numeric value under which relative abundances
%                           are considered 0. OPTIONAL, defaults to 1e-6.
%     outputExtensionMARS:  String with the desired file extension of the
%                           saved outputs. OPTIONAL, defaults to 'csv'.
%     flagLoneSpecies:      A boolean to indicate if the genus name is in
%                           the name of the species e.g. Prevotella copri.
%                           If genus name is in species name set to false.
%                           Otherwise set to true. OPTIONAL, defaults to
%                           false.
%     taxaSplit:            String with the delimiter used to separate
%                           taxonomic levels. OPTIONAL, defaults to '; '.
%
% MARS analysis
%     marsStats:            Boolean indicates if Part 2.5 of the pipeline
%                           MARS descriptive statistics should be run.
%                           OPTIONAL, defaults to true
%     microbiomePath:       String with the path to the file where the
%                           reads and taxonomic assignments are combined.
%                           Could be the same file as readsTablePath. OPTIONAL,
%                           default to [Ask TIMHuls to Create].
%     relAbunFilePath:      String with the path to the relative abundance
%                           species file, an output from MARS. OPTIONAL,
%                           defaults to [outputPathMARS, filesep,
%                           'present', filesep, 'present_species.',
%                           outputExtensionMARS] if MARS is run with this
%                           pipeline. If run online, the path needs to be
%                           specified explicitly.
%     analysisDirMARS:      Strin with the path where the descriptive
%                           statistics of the MARS output should be stored.
%                           OPTIONAL, default to [outputPathMARS, filesep,
%                           'Analysis'].
% MgPipe:
%     paths.mgPipe.flagMgPipe: Boolean, indicates if Part 3 of the pipeline:
%                           MgPipe/microbiome model creation should be run.
%                           Defaults to true. OPTIONAL, defaults to true
%     panModelsPath:        String with path to the directory with the
%                           panSpecies models. REQUIRED
%     relAbunFilePath:      String with the path to the relative abundance
%                           species file, an output from MARS. OPTIONAL,
%                           defaults to [outputPathMARS, filesep,
%                           'present', filesep, 'present_species.',
%                           outputExtensionMARS] if MARS is run with this
%                           pipeline. If run online, the path needs to be
%                           specified explicitly.
%     computeProfiles:      Boolean, indicates of netSecretion and
%                           netUptake are calculated for the microbiome
%                           models via fastFVA. OPTIONAL, defaults to false
%     numWorkersCreation:   Numeric value, amount of workers that are to be
%                           used to create microbiome models. OPTIONAL,
%                           default to use all available cores.
%     mgpipeDir:            String with the path to where the results of
%                           MgPipe should be saved. OPTIONAL, defaults to
%                           [resultPath, filesep, 'ResultMgPipe'];
% WBM Personalisation:
%     paths.persWBM.flagPersonalize :     Boolean, indicates if Part 4 of the pipeline:
%                           WBM personalisation should be run. OPTIONAL,
%                           defaults to false.
%     personalisedWBMDir:   String with the path to the location where the
%                           personalised WBM are stored. OPTIONAL, defaults
%                           to [resultPath, filesep, 'personalisedWBMs'].
%     diet:                 String or nx2 character array defining the diet
%                           to constrain WBM models with. OPTIONAL, defaults
%                           to EUAverageDiet.
% HM Creation:
%     paths.mWBM.flagMWBMCreation:       Boolean, indicates if Part 5 of the pipeline:
%                           HM creation and descriptive statistics should
%                           be run. OPTIONAL, defaults to true
%     mgpipeDir:        String with the path to the location where the
%                           community microbiome models generated from
%                           MgPipe are stored. OPTIONAL, if this pipeline
%                           is used to run MgPipe it defaults to
%                           [mgpipeDir, filesep, 'Diet']. If MgPipe was
%                           used outside of this function state the path
%                           explicitly.
%     hmDir:                The path where the HM models will be stored.
%                           OPTIONAL, defaults to [resultPath, filesep,
%                           'HMmodels'].
%     diet:                 String or nx2 character array defining the diet
%                           to constrain HM models with. OPTIONAL, defaults
%                           to EUAverageDiet.
%     numWorkersCreation:   Numeric value, amount of workers that are to be
%                           used to create HM WBMs. OPTIONAL,
%                           default to use all available cores.
% Flux balance analysis:
%     paths.fba.flagFBA:    Boolean, indicates if Part 6 of the pipeline:
%                           FBA should be run. OPTIONAL, defaults to true
%     hmDir:                String with the path to the directory with the
%                           models to use. OPTIONAL, if HM models were made
%                           it defaults to hmDirectory used in part 4. If
%                           HM models were created outside this function,
%                           the path has to be explicitly stated.
%     fluxDir:              String with the path where the flux results
%                           should be stored. OPTIONAL, defaults to
%                           [resultPath, filesep, 'fluxResults'].
%     rxnList:              Character array containing reaction IDs for
%                           reactions that are to be optimised. If the user
%                           wants to solve non-existing demand reactions,
%                           simply add DM_ infront of the desired
%                           metabolite and add to the rxnList variable.
%                           REQUIRED.
%     rxnSense:             Character array containing either 'max' or 'min'
%                           to specificy the sense of the objective. Option
%                           to specifcy for each objective- character array 
%                           should then be exact length of rxnList.
%                           (OPTIONAL, Default = 'max').
%     mgpipeDir:            String with the path to the relative abundance
%                           species file, an output from MARS. OPTIONAL,
%                           defaults to [outputPathMARS, filesep,
%                           'present', filesep, 'present_species.',
%                           outputExtensionMARS] if MARS is run with this
%                           pipeline. If run online, the path needs to be
%                           specified explicitly.
%     thresholds:           1x3 numerical vector. OPTIONAL, defaults to
%                           [90, 90, 0.999]
%
%                           - thresholds(1): "metabolite removal threshold"
%                           This threshold indicates the maximum allowable
%                           number of duplicate flux results between
%                           samples expressed in the percentage of total
%                           samples. Reactions that exceed this threshold
%                           will be removed.
%
%                           - thresholds(2): "Microbe presence threshold"
%                           This threshold indicates the maximum allowable
%                           number of samples where a microbe is absent
%                           expressed by the percentage of total samples.
%                           Microbes that exceed this threshold will be
%                           removed from the analysis.
%
%                           - thresholds(3): "Reaction grouping threshold"
%                           This threshold indicates the minimal pairwise
%                           Spearman correlation between fluxes across the
%                           population where reactions are grouped and
%                           handled as one result.
%                           ADD TEXT 4th input for std dev.
%   numWorkersOptmisation:  Numeric value, amount of workers that are to be
%                           used to solve the WBM models. OPTIONAL,
%                           default to 1.
%     saveFullRes:          Boolean, indicates if the complete .v, .y., and
%                           .w vectors are stored in the result. OPTIONAL,
%                           defaults to true. It is recommended to set
%                           saveFullRes.
%     fluxAnlsysDir:        String with the path where the analyses of the
%                           flux results are stored. OPTIONAL, defaults to
%                           [fluxDir, filesep, 'fluxAnalysis']
% Statistical analysis:
%     paths.stats.flagStatistics:       Boolean, indicates if Part 7 of the pipeline:
%                           statistical analysis should be run. OPTIONAL,
%                           defaults to true
%     statDir:              String with the path where the results of the
%                           statistical analyses and the figures should be
%                           saved. OPTIONAL, defaults to [resultPath,
%                           filesep, 'statisticsResults'].
%     fluxDir:              String with the path to the location of the
%                           analysed flux results. OPTIONAL, defaults to
%                           [resultPath, filesep, 'fluxResults', filesep,
%                           'fluxAnalysis'].
%     microbiomePath:       String with the path to the relative abundance
%                           panSpecies file generated by MARS. OPTIONAL,
%                           defaults to [resultPath, filesep, resultMars,
%                           filesep, present,filesep, 'present_species.csv']
%     response:             A character or string array with variables
%                           found in the metdata file that the user wants
%                           to use as response for statistical analysis.
%                           REQUIRED
%     confounders:          A character or string sarray with variables
%                           found in the metadata file that are used as
%                           confounders in the statistical analyses.
%                           OPTIONAL, defaults to an empty cell array.
%     moderationAnalysis:   Boolean that indicates if a moderation analysis
%                           will be performed. A moderation analysis can
%                           only be performed if confounders. OPTIOANL,
%                           defaults to false.
%     microbeCutoff:        Numeric value, threshold for the number of
%                           samples a microbe needs to present in to be to
%                           be analysed. The same variable as thresholds(2)
%                           OPTIONAL, defaults to 0.1
%     threshold:            Numeric value used to find the correct instance
%                           of the 'processed_fluxes_Thr_x_xxx file, where
%                           the threshold value is x_xxx. The same value as
%                           thresholds (3). OPTIONAL, defaults to 0.999.
% Outputs:
%
% Example (minimal required input to run all sections):
%   fullPipeline(resultPath,metadataPath,'marsRepoPath', marsRepoPath,...
%   'pythonPath', pythonPath, 'OTUTable', OTUTable, 'readsTablePath' readsTablePath,...
%   'panModelsPath', panModelsPath, 'rxnList', rxnList, 'response', response)
%
% Example (MARS is run online and is skipped in the this pipeline):


%%%%%%%%%%%%%%%%%%%%%%% PERSEPHONE INITIALISATION %%%%%%%%%%%%%%%%%%%%%%%%%

% Start timer
tic;
% Load all variables defined in the configPersephone.m
run(configPath);
resultPath
% Do not run MARS if seqC was run.
if paths.seqC.flagSeqC == true
    paths.Mars.paths.Mars.flagMars = false;
end

% Assign each variable in the workspace to the wks structure
% persephoneInputs = cell2struct(cellfun(@eval, who, 'UniformOutput', false), who, 1);

% Validate the set workspace variables and give descriptive errors on which
% variables were not set correctly.
resultPath
validatePersephoneInputs(paths,resultPath);

% Create log file on the pipeline setup
resultPath
diary(fullfile(resultPath, 'logFile_initialisation.txt'))

% Initialise PERSEPHONE
[~, statToolboxInstalled, updatedMetadataPath] = initPersephone(resultPath, paths);
paths.General.metadataPath = updatedMetadataPath;

% Validate the path to the given diet.
paths.General.dietPath = validateDietPath(paths.General.diet, paths.mgPipe.outputPathMgPipe);

% Create or load a structure variable that will store which parts of the
% pipeline it has already succesfully completed. In an event of a crash the
% user can just rerun the same code and the parts already computed will be
% skipped.

if exist([resultPath, filesep, 'progress.mat'], 'file')
    load([resultPath, filesep, 'progress.mat'], 'progress');
else
    progress = struct();
end
part0 = toc; % Initialised for debugging purposes
progress.setup = [true, toc];

save([resultPath, filesep, 'progress.mat'], 'progress');
diary('off') % Close diary and save to resultPath

%% Part 1:
%%%%%%%%%%%%%%%%%%%%% SEQUENCING DATA PROCESSING (SeqC) %%%%%%%%%%%%%%%%%%%%%%%%%%
% Create log file on the pipeline setup
logFileSeqC = fullfile(resultPath, 'logFile_SeqC.txt');
diary(logFileSeqC);
% Check if SeqC results have already been generated
if isfield(progress, 'seqc') && progress.seqc(1)
    paths.seqC.flagSeqC = false;
end
% Run if true
if paths.seqC.flagSeqC
    % Start timing
    tic;
    % Messaging
    disp(' > Bioinformatic processing with SeqC.');
    % Submit seqc run
    statusSeqC = runSeqC(...
        paths.seqC.repoPathSeqC, ...
        paths.seqC.outputPathSeqC, ...
        paths.seqC.fileIDSeqC, ...
        paths.seqC.procKeepSeqC, ...
        paths.seqC.maxMemSeqC, ...
        paths.seqC.maxCpuSeqC, ...
        paths.seqC.maxProcSeqC, ...
        paths.seqC.debugSeqC, ...
        paths.seqC.runApptainer, ...
        paths.Mars.readsTablePath, ...
        paths.Mars.outputPathMars, ...
        paths.Mars.outputExtensionMars, ...
        paths.Mars.relAbunFilePath, ...
        paths.Mars.sample_read_counts_cutoff, ...
        paths.Mars.cutoffMars, ...
        paths.Mars.taxaTable, ...
        paths.Mars.flagLoneSpecies, ...
        paths.Mars.taxaDelimiter, ...
        paths.Mars.removeClade, ...
        paths.Mars.reconstructionDb, ...
        paths.Mars.userDbPath, ...
        string(missing) ... % hardcode for outdated input variable.
        );
    % Save progress that SeqC has run.
    % SeqC status 0 means SeqC has run succesfully. Counterintuitive.
    if statusSeqC == 0
        part1_seqc = toc;
        progress.seqc = [true, part1_seqc];
        % Display execution time
        fprintf(' > SeqC completed in %.2f seconds.\n', part1_seqc);
        save([resultPath, filesep, 'progress.mat'], 'progress');
    else
        % Error messaging
        error('ERROR: SeqC processing failed');
    end
else
    disp(' > Bioinformatic processing with SeqC skipped.')
end
diary('off') % Save SeqC logfile
%End of SeqC
%%
%%%%%%%%%%%%%%%%%%%%% METAGENOMIC MAPPING (MARS) %%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% Create log file on the pipeline setup
diary([resultPath filesep 'logFile_MARS.txt'])

% Check if MARS results have already been generated
if isfield(progress, 'mars')
    if progress.mars(1)
        % it could be present but empty so I don't think this should be
        % here
        paths.Mars.flagMars = false;
    end
end

if paths.Mars.flagMars
    % Messaging
    disp(' > Perform metagenomic mapping using MARS.');
    disp(' > Initialise python environment.');
    % Perform metagenomic mapping
    runMars(paths.Mars.pythonPath, ...
        paths.Mars.marsRepoPath, ...
        paths.Mars.cutoffMars, ...
        paths.Mars.outputExtensionMars, ...
        paths.Mars.flagLoneSpecies, ...
        paths.Mars.taxaDelimiter, ...
        paths.Mars.removeClade, ...
        paths.Mars.reconstructionDb, ...
        paths.Mars.userDbPath, ...
        paths.Mars.sample_read_counts_cutoff, ...
        paths.Mars.readsTablePath, ...
        paths.Mars.taxaTable, ...
        paths.Mars.outputPathMars)

    % Save progress that MARS has run.
    part1 = toc;
    progress.mars = [true, part1];
    
    save([resultPath, filesep, 'progress.mat'], 'progress');
    
else
    disp(' > Calculation of relative abundances with MARS is skipped')
end
diary('off'); % Save MARS logfile
% %% Adjust metadata to remove any potential missing samples compared to the microbiome sample.
% % Remove samples in the metadata that are not in the microbiome data
% if ~isempty(paths.Mars.relAbunFilePath)
% 
%     % Load microbiome data
%     relAbunFile = readtable(paths.Mars.relAbunFilePath,'VariableNamingRule','preserve');
% 
%     % Check if the microbiome table is empty
%     validateattributes(relAbunFile, {'table'}, {'nonempty'}, mfilename, 'readsTable')
% 
%     % Check if a column named Taxon exists
%     if ~ismember('Taxon', relAbunFile.Properties.VariableNames)
%         error('COBRA:BadInput', 'Microbiome read table must contain an Taxon column')
%     end
% 
%     % Read in the metadata
%     metadata = readMetadataForPersephone(paths.General.metadataPath);
% 
%     % Find the intersection of samples between the readsTable and the
%     % metadata table
%     [~,ia] = intersect(metadata.ID, ...
%         relAbunFile.Properties.VariableNames(2:end)','stable');
%     % Perform checks
%     if isempty(ia)
%         error('COBRA:BadInput', 'No overlapping samples could be found between the reads table and the metadata table.')
%     else
%         numRemovedSamples = size(metadata,1)-numel(ia);
%         if numRemovedSamples>0
%             disp(strcat("> Removed ", string(numRemovedSamples), " samples in the metadata that were not present in the reads table."))
%         end
%         metadata = metadata(ia,:);
%     end
% 
%     % Remove all samples in the metadata that are not in the readsTable
%     disp(strcat("> ", string(size(metadata,1)), " samples were included in this study."))
%     writetable(metadata,paths.General.metadataPath);
% end

%% Part 2:
%%%%%%%%%%%%%%%%%%%%%%% Create microbiome models %%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% Open new log file
diary([resultPath filesep 'logFile_mgPipe.txt']) 

% Check if MgPipe has already run
if isfield(progress, 'mgpipe')
    if progress.mgpipe(1)
        paths.mgPipe.flagMgPipe = false;
    end
end

% Run MgPipe if the user wants to or if it has not yet been done.
if paths.mgPipe.flagMgPipe
    disp(' > Generate microbiome community models.')
    initMgPipe( ...
        paths.mgPipe.microbeReconstructionPath, ...
        paths.Mars.relAbunFilePath, ...
        paths.mgPipe.computeProfiles,... 
        'solver', paths.General.solver, ...
        'numWorkers',paths.General.numWorkersCreation, ...
        'resPath', paths.mgPipe.outputPathMgPipe, ...
        'Diet', paths.General.dietPath);

    % Save progress that microbiome models have been created.
    part2 = toc;
    progress.mgpipe = [true, part2];
    save([resultPath, filesep, 'progress.mat'], 'progress');
else
    disp(' > Community microbiome model generation is skipped.')
end

% Close diary and save log to resultPath
diary('off') 

%% Part 3: 
%%%%%%%%%%%%%%%%%%%%%%% Personalisation of WBMs %%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% Open new log file
diary([resultPath filesep 'logFile_WBM_personalisation.txt'])

% check if personalisation is already complete
if isfield(progress, 'personalisation')
    if progress.personalisation(1)
        paths.persWBM.flagPersonalise = false;
    end
end

% if paths.persWBM.flagPersonalize is still true, personalize models
if paths.persWBM.flagPersonalise

    [iWBM, iWBMcontrol_female, iWBMcontrol_male, persParameters] = persWBM(...
    paths.General.metadataPath, ...
    'persPhysiology', paths.persWBM.persPhysiology, ...
    'resPath', paths.persWBM.outputPathPersonalisation, ...
    'persMetabolites', paths.persWBM.persMetabolites, ...
    'solver', paths.General.solver);

    % ensure personalized models are used in HM creation
    part3 = toc;
    progress.personalisation = [true, part3];
    
    save([resultPath, filesep, 'progress.mat'], 'progress');
else
    disp('Personalisation of WBMs is skipped')
end

diary('off') % Close diary and save to resultPath

%% Part 4: 
%%%%%%%%%%%%%%% Creation of Human-Microbiome models %%%%%%%%%%%%%%%%%%%%%%%
tic;
% Check if the human-microbiome models have already been created
if isfield(progress, 'mWBMCreation')
    if progress.mWBMCreation(1)
        paths.mWBM.flagMWBMCreation = false;
    end
end

% Create new log file
diary([resultPath filesep 'logFile_mWBM_creation.txt']) 

% Create human-microbiome models if so specified.
if paths.mWBM.flagMWBMCreation   
    if paths.mWBM.usePersonalisedWBM
        disp(' > Create host-microbiome WBMs (miWBMs) from personalised WBMs and microbiome community models.')
        createBatchMWBM(paths.mgPipe.outputPathMgPipe, ...
            paths.mWBM.outputPathMWBM, ...
            paths.General.metadataPath,...
            'solver', paths.General.solver,...
            'wbmDirectory', paths.mWBM.alteredWBMPath,...
            'Diet', paths.General.diet,...
            'numWorkersCreation',paths.General.numWorkersCreation,...
            'numWorkersOptimisation',paths.General.numWorkersOptimisation)
    else

        disp(' > Create host-microbiome WBMs (mWBMs) from unpersonalised WBMs and microbiome community models.')

        createBatchMWBM(paths.mgPipe.outputPathMgPipe, ...
            paths.mWBM.outputPathMWBM, ...
            paths.General.metadataPath,...
            'solver', paths.General.solver,...
            'Diet', paths.General.diet,...
            'numWorkersCreation',paths.General.numWorkersCreation,...
            'numWorkersOptimisation',paths.General.numWorkersOptimisation)
    end


    % Save progress that human-microbiome models have been created.
    part4 = toc;
    progress.mWBMCreation = [true, part4];    
    save([resultPath, filesep, 'progress.mat'], 'progress');

else
    disp('Human-microbiome model creation is skipped as per user request')
end

diary('off') % Close diary and save to resultPath

%% Part 5: Run FBA
%%%%%%%%%%%%%%%%%%%%%% Flux balance analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% Check if FBAs have already been run.
if isfield(progress, 'fba')
    if progress.fba(1)
        paths.fba.flagFBA = false;
    end
end

% Open log file
diary([resultPath filesep 'logFile_FBA.txt'])

% Run FBA's for the models if so specified.
if paths.fba.flagFBA == 1

    FBA_results = analyseWBMs(paths.mWBM.outputPathMWBM, ...
        paths.fba.outputPathFluxResult, ...
        paths.fba.rxnList,...
        'rxnSense', paths.fba.rxnSense,...
        'paramFluxProcessing', paths.fba.paramFluxProcessing,...
        'numWorkers', paths.General.numWorkersOptimisation, ...
        'saveFullRes', paths.fba.saveFullRes,...
        'fluxAnalysisPath', paths.fba.outputPathFluxAnalysis,...
        'solver', paths.General.solver);

    % Save progress that FBA's have been run
    part5 = toc;
    progress.fba = [true, part5];
    save([resultPath, filesep, 'progress.mat'], 'progress')  
else
    disp('Solving human-microbiome models is skipped')
end

diary('off') % Close diary and save to resultPath

%% Part 6: 
%%%%%%%%%%%%%%%%%%%%%% Analysis of flux results %%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
if paths.stats.flagStatistics && statToolboxInstalled
    diary([resultPath filesep 'logFile_statistics.txt']) % Open diary for log file

    for i = 1:size(paths.stats.response,2)
        singleResp = paths.stats.response{i};
        % Run statistics pipeline
        if isfield(progress, 'mWBMCreation')
            if progress.mWBMCreation(1)
            results = performStatsPersephone( ...
                paths.stats.outputPathStatistics, ...
                fullfile(paths.fba.outputPathFluxAnalysis, 'processed_fluxes.csv'), ...
                paths.General.metadataPath, ...
                singleResp, ...
                'confounders',paths.stats.confounders, ...
                'pathToWbmRelAbundances', fullfile(paths.fba.outputPathFluxAnalysis, 'WBM_relative_abundances.csv'));
            end
        else
            results = performStatsPersephone( ...
                paths.stats.outputPathStatistics, ...
                fullfile(paths.fba.outputPathFluxAnalysis, 'processed_fluxes.csv'), ...
                paths.General.metadataPath, ...
                singleResp, ...
                'confounders',paths.stats.confounders);
        end
    end
    part6 = toc;

    progress.statistics = [true, part6];
    diary('off') % Close diary and save to resultPath

    else
        disp("The statistical analysis is skipped")
end
totalT= 0;
fields = fieldnames(progress);  
for i = 1:numel(fields)-1
    data = progress.(fields{i});  
    totalT = totalT + data(2); 
end
progress.totalTime = totalT;
save([resultPath, filesep, 'progress.mat'], 'progress') 
disp(['Total elapsed time: ', num2str(totalT), ' seconds']);
end
