function [initialised, statToolboxInstalled, updatedMetadataPath] = initPersephone(resultPath, paths)
% Initializes the Persephone pipeline by:
%     - Checking for MATLAB toolbox dependencies.
%     - Processing and validating the metadata file.
%     - Cross-referencing metadata with microbiome data (if provided).
%     - Setting up directory structures for Persephone results.
%
% USAGE:
%   [initialised, paths, statToolboxInstalled] = initPersephone(resultPath, metadataPath, readsTablePath)
%
% INPUTS:
%   resultPath        - (char) Path to the main results directory where output folders will be created.
%   metadataPath     - (char) Path to the metadata file (.csv or .xlsx). Must include sample IDs and sex information.
%   readsTablePath   - (char) Optional. Path to the microbiome reads table. If not provided, metadata will not be cross-referenced with microbiome data.
%
% OUTPUTS:
%   initialised           - (logical) True if initialization was successful.
%   paths             - (struct) Structure containing paths to created result directories.
%   statToolboxInstalled  - (logical) True if the Statistics and Machine Learning Toolbox is installed.
%   updatedMetadataPath   - (char) Character array containing path to the update metadata file.
%
% REQUIREMENTS:
%   - MATLAB R2020b or newer.
%   - Parallel Computing Toolbox (mandatory).
%   - Statistics and Machine Learning Toolbox (recommended for analysis).
%
% NOTES:
%   - Metadata must contain a column of sample IDs and a column of sex information.
%   - Metadata and reads table will be synchronized to ensure consistent samples across analyses.
%   - Any discrepancies in variable naming (e.g., "ID", "Sex") are automatically resolved.
%   - Processed metadata is saved to an updated file.
%
% EXAMPLE:
%   resultPath = './results';
%   metadataPath = './data/metadata.csv';
%   readsTablePath = './data/readsTable.csv';
%   [initialised, paths, statToolboxInstalled] = initPersephone(resultPath, metadataPath, readsTablePath);
%
% AUTHOR:
%  - Tim Hensen, January 2025
%  - Bram Nap, July 2024: Automatic creation of output folders

% Check the validity of inputs using arguments
arguments
    % resultPath must be a non-empty char or string
    resultPath (1, :) {mustBeNonempty, mustBeText}
    
    % metadataPath must be a non-empty char or string
    paths (1, :) {mustBeNonempty}
end


%%% Test for Matlab toolbox dependency issues %%%
%fix for error from missing toolbox - stats and ML - wb 20250305
sysAddons = matlab.addons.installedAddons();
if any(strcmp(sysAddons.Name,'Parallel Computing Toolbox'))
    % Check if the parallel toolbox is installed (Required)
    if ~matlab.addons.isAddonEnabled('Parallel Computing Toolbox')
        error('It seems the Paralell Computing Toolbox is not installed. Please consider installing it via the add-on option in MATLAB, it is required to generate microbiome models, HM models and to generate flux results.')
    else
        if ~license('test','Distrib_Computing_Toolbox')
          error('It seems the Paralell Computing Toolbox is installed but no valid license exists. Please consider updating/obtaining a license, it is required to generate microbiome models, HM models and to generate flux results.')
        end   
    end
end
% Check if the statistics toolbox is installed (Not critical, but recommended)
if any(strcmp(sysAddons.Name,'Statistics and Machine Learning Toolbox'))
    if ~matlab.addons.isAddonEnabled('Statistics and Machine Learning Toolbox')
        statToolboxInstalled = false;
        warning('It seems the Statistics and Machine Learning Toolbox is not installed. Please consider installing it via the add-on option in MATLAB as it is required for analysis')
    else
        if license('test', 'Statistics_Toolbox')
        statToolboxInstalled = true;
        else 
         warning('It seems the Statistics and Machine Learning Toolbox installed but no valid license exists. Please consider updating/obtaining a license as it is required for analysis')
        statToolboxInstalled = false;
        end    
    end
else
    statToolboxInstalled = false;

end


%%% Check and process the metadata file %%%

% Load the metadata into memory and test if the metadata file contains all
% required characteristics. The metadata file needs to contain at least one
% column with sample IDs and one column with sample sex information. An
% optional input of the initPersephone function is the path to the
% microbiome read table. Models will only be generated for samples
% that are present in both the metadata and the microbiome data. If no
% microbiome data is given, then this step will not be performed.
% Read the metadata file

% Read metadata
metadata = readMetadataForPersephone(paths.General.metadataPath);

% Define list of acceptable variable names (case insensitive)
acceptableIdNameList = {'id','sample','name','sample_id','sample_name','sample id','sample name'}; % Can be extended in the future

% Check if ID information can be found in the metadata
varNames = metadata.Properties.VariableDescriptions;
if any(matches(acceptableIdNameList,varNames{1},"IgnoreCase",true))
    metadata = renamevars(metadata, varNames{1},'ID');
    metadata.ID = string(metadata.ID);
    disp(strcat("> '",string(varNames{1}), "' was renamed to 'ID' in the metadata file. "))
else
    error('COBRA:BadInput', 'Cannot find sample IDs. Make sure that the sample IDs are in the first column and are named ID.')
end

% Check if sex information can be found
colWithSexInfo = matches(varNames,{'gender','sex'},'IgnoreCase',true);
if any(colWithSexInfo)
    metadata.Properties.VariableNames(colWithSexInfo) = {'Sex'};
    disp(strcat("> '",string(varNames(colWithSexInfo)), "' was renamed to 'Sex' in the metadata file. "))
else
    error('COBRA:BadInput', 'Cannot find sample Sex variable. Make sure that the sample sex is in the metadata.')
end

% Throw an error if the sex information is numeric
validateattributes(metadata.Sex,{'string','cell'},{'nonempty'},'Test if Sex information is not numeric.')

% Validate the sex decodings in metadata.Sex
cellfun(@(x) validatestring(x,{'m','f','female','male',''},'Test if Sex information is encoded as f/m or female/male'), metadata.Sex, 'UniformOutput', false);

% Convert the sex decoding into male/female
metadata.Sex = lower(string(metadata.Sex));
metadata.Sex(matches(metadata.Sex,{'f','female'},'IgnoreCase',true)) = "female";
metadata.Sex(matches(metadata.Sex,{'m','male'},'IgnoreCase',true)) = "male";

% Generated updated metadata path
% Original statement raises error when using with AD dataset, because a
% string array instead of one string was produced, the update works as an
% alternative also for the AD dataset - JW
updatedMetadataPath = erase(paths.General.metadataPath, [".xlsx", ".csv"]);
updatedMetadataPath = updatedMetadataPath + "_processed.csv";

% Convert updated path to character array
updatedMetadataPath = char(updatedMetadataPath);

% Save updated file
writetable(metadata,updatedMetadataPath);
disp(strcat("> The processed metadata file is saved in :", string(updatedMetadataPath)))


%%% Create folders for PERSEPHONE results %%%

% The following lines create all required output directories for the
% human-microbiome creation and analysis pipeline.  All the paths
% for the created directories are stored in a structure variable.

% Create folders for the following output paths
newFolders = {...
    paths.seqC.outputPathSeqC;...
    paths.Mars.outputPathMars;...
    paths.mgPipe.outputPathMgPipe;...
    paths.persWBM.outputPathPersonalisation;...
    paths.mWBM.outputPathMWBM;...
    paths.fba.outputPathFluxResult;...
    paths.fba.outputPathFluxAnalysis;...
    paths.stats.outputPathStatistics};

for i = 1:numel(newFolders)
    % Create the directory if it does not exist
    if ~exist(newFolders{i}, 'dir')
        mkdir(newFolders{i});
    end
end

% Initialise cobratoolbox
global CBTDIR
if isempty(CBTDIR)
    initCobraToolbox
end

% Initialisation was successful!
disp(' > Persephone was successfully initialised.');

initialised = true;
end