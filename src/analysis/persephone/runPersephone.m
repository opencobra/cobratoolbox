function [progress] = runPersephone(configPath)
% This pipeline orchestrates the end-to-end process of constructing and 
% analysing human–microbiome whole-body models (WBMs). It integrates 
% sequencing data processing, metagenomic mapping, microbiome model 
% generation, WBM personalisation, host–microbiome model creation, flux 
% balance analysis (FBA), and statistical evaluation. 
%
%
% Updated: 2025.07.01 wbarton
% Updated: 2025.09.09 asheehy
% Updated: 2025.09.19 bnap
%
% Usage:
%     runPersephone(configPath)
%
% Overview of steps:
% 1. SeqC:                  Pre-process sequencing data and prepare input for MARS.
% 2. MARS:                  Map taxonomy-assigned reads to AGORA2/APOLLO reconstructions 
%                           to generate relative abundance files.
% 3. MgPipe:                Build microbiome community models using relative abundances.
% 4. WBM personalisation:   Personalise WBMs with physiological and/or 
%                           metabolomic data.
% 5. mWBM Creation:         Combine WBMs (personalised or base) with microbiome models 
%                           to create host–microbiome WBMs (miWBMs).
% 6. FBA:                   Perform flux balance analysis on mWBMs using user-specified 
%                           reaction objectives, followed by flux post-processing.
% 7. Statistics:            Run statistical analyses (e.g., mixed-effects linear 
%                           regression) on flux and abundance results, 
%                           accounting for metadata-specified predictors and confounders.
%
%%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% configPath : Path to a .mat file which should contain all of the
%              necessary inputs needed to run specific or all sections of 
%              this pipeline. A template of this config file can be found
%              at: https://github.com/opencobra/cobratoolbox/tree/master/src/analysis/persephone
%              or you can fill in an online version and download at: https://vmh2.life/persephone
%
%%%%%% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% All results will be saved to your computer in the directories you can
% choose in the config file. The output 'progress' will also be produced
% and saved to your workspace. It will detail all sections that have been
% run and how long they took.
%
%% %%%%%%%%%%%%%%%%%%% PERSEPHONE INITIALISATION %%%%%%%%%%%%%%%%%%%%%%%%%
% Start timer
tic;
% Load all variables defined in the configPersephone.m
run(configPath);

% Validate the set workspace variables and give descriptive errors on which
% variables were not set correctly.
validatePersephoneInputs(paths,resultPath);

% Create log file on the pipeline setup
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

%% Part 1: SEQUENCING DATA PROCESSING (SeqC) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        paths.seqC.runApptainer ...
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
%% PART 2: METAGENOMIC MAPPING (MARS) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    % Perform metagenomic mapping
    runMars(paths.Mars.readsTablePath,...
        'cutoffMars', paths.Mars.cutoffMars,...
        'flagLoneSpecies', paths.Mars.flagLoneSpecies,...
        'taxaDelimiter', paths.Mars.taxaDelimiter,...
        'removeClade', paths.Mars.removeClade,...
        'reconstructionDb', paths.Mars.reconstructionDb,...
        'userDbPath', paths.Mars.userDbPath, ...
        'sampleReadCountCutoff', paths.Mars.sampleReadCountCutoff,...
        'taxaTablePath', paths.Mars.taxaTable, ...
        'outputPathMars', paths.Mars.outputPathMars, ...
        'calculateBrayCurtis', paths.Mars.calculateBrayCurtis, ...
        'compoundedDatabase', paths.Mars.compoundedDatabase)

    % Save progress that MARS has run.
    part1 = toc;
    progress.mars = [true, part1];
    
    save([resultPath, filesep, 'progress.mat'], 'progress');
    
else
    disp(' > Calculation of relative abundances with MARS is skipped')
end
diary('off'); % Save MARS logfile
%% Part 3: Create microbiome models %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        paths.mgPipe.relAbunFilePath, ...
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

%% Part 4: Personalisation of WBMs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
% Open new log file
diary([resultPath filesep 'logFile_WBM_personalisation.txt'])

% check if personalisation is already complete
if isfield(progress, 'personalisation')
    if progress.personalisation(1)
        paths.persWBM.flagPersonalise = false;
    end
end

% Check if there is a user provided male or female model and that 

% if paths.persWBM.flagPersonalize is still true, personalize models
if paths.persWBM.flagPersonalise

     disp(' > Personalise WBM models.')
    persWBM(...
        paths.General.metadataPath, ...
        'persPhysiology', paths.persWBM.persPhysiology, ...
        'resPath', paths.persWBM.outputPathPersonalisation, ...
        'persMetabolites', paths.persWBM.persMetabolites, ...
        'solver', paths.General.solver, ...
        'Diet',  paths.General.diet, ...
        'femaleWBM', paths.persWBM.femaleWBMPath, ...
        'maleWBM', paths.persWBM.maleWBMPath);
    

    % ensure personalized models are used in HM creation
    part3 = toc;
    progress.personalisation = [true, part3];
    
    save([resultPath, filesep, 'progress.mat'], 'progress');
else
    disp('Personalisation of WBMs is skipped')
end

diary('off') % Close diary and save to resultPath

%% Part 5:Creation of Human-Microbiome models %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
            'numWorkersCreation',paths.General.numWorkersCreation)
    else

        disp(' > Create host-microbiome WBMs (mWBMs) from unpersonalised WBMs and microbiome community models.')

        createBatchMWBM(paths.mgPipe.outputPathMgPipe, ...
            paths.mWBM.outputPathMWBM, ...
            paths.General.metadataPath,...
            'solver', paths.General.solver,...
            'Diet', paths.General.diet,...
            'numWorkersCreation',paths.General.numWorkersCreation)
    end


    % Save progress that human-microbiome models have been created.
    part4 = toc;
    progress.mWBMCreation = [true, part4];    
    save([resultPath, filesep, 'progress.mat'], 'progress');

else
    disp('Human-microbiome model creation is skipped')
end

diary('off') % Close diary and save to resultPath

%% Part 6: Flux balance analysis %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    analyseWBMs(paths.mWBM.outputPathMWBM, ...
        paths.fba.outputPathFluxResult, ...
        paths.fba.rxnList,...
        'rxnSense', paths.fba.rxnSense,...
        'paramFluxProcessing', paths.fba.paramFluxProcessing,...
        'numWorkers', paths.General.numWorkersOptimisation, ...
        'saveFullRes', paths.fba.saveFullRes,...
        'fluxAnalysisPath', paths.fba.outputPathFluxAnalysis,...
        'solver', paths.General.solver,...
        'analyseGF', paths.fba.analyseGF);


    % Save progress that FBA's have been run
    part5 = toc;
    progress.fba = [true, part5];
    save([resultPath, filesep, 'progress.mat'], 'progress')  
else
    disp('Solving human-microbiome models is skipped')
end

diary('off') % Close diary and save to resultPath

%% Part 7: Analysis of flux results %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%% Save timing
totalT = 0;
fields = fieldnames(progress);

for i = 1:numel(fields)
    data = progress.(fields{i});
    
    % Only add if data is numeric, has at least 2 elements, and the flag is true
    if isnumeric(data) && numel(data) >= 2 && data(1)
        totalT = totalT + data(2);
    end
end

progress.totalTime = totalT;

save(fullfile(resultPath, 'progress.mat'), 'progress');
disp(['Total elapsed time: ', num2str(totalT), ' seconds']);

end
