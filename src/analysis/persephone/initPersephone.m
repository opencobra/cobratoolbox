function [initialised, statToolboxInstalled, updatedMetadataPath] = initPersephone(resultPath, paths)
% Initialise the Persephone pipeline: check toolboxes, metadata, and folders
%
% Checks for the required MATLAB toolbox dependencies, reads and validates the
% metadata file (harmonising the ID and Sex columns), writes a processed
% metadata file, and creates the output directory structure used by the
% pipeline.
%
% USAGE:
%
%    [initialised, statToolboxInstalled, updatedMetadataPath] = initPersephone(resultPath, paths)
%
% INPUTS:
%    resultPath:    char/string, path to the main results directory
%    paths:         structure with the Persephone configuration. Fields used:
%
%                     * .General - general settings; `.metadataPath` gives the
%                       metadata file
%                     * .mgPipe - mgPipe settings (`.computeProfiles`,
%                       `.outputPathMgPipe`)
%                     * .seqC - SeqC output settings (`.outputPathSeqC`)
%                     * .Mars - MARS output settings (`.outputPathMars`)
%                     * .persWBM - personalisation output settings
%                       (`.outputPathPersonalisation`)
%                     * .mWBM - host-microbiome output settings
%                       (`.outputPathMWBM`)
%                     * .fba - flux output settings (`.outputPathFluxResult`,
%                       `.outputPathFluxAnalysis`)
%                     * .stats - statistics output settings
%                       (`.outputPathStatistics`)
%
% OUTPUTS:
%    initialised:            logical, true if initialisation was successful
%    statToolboxInstalled:    logical, true if the Statistics and Machine
%                            Learning Toolbox is installed and licensed
%    updatedMetadataPath:    char, path to the processed metadata file
%
% .. Author: - Tim Hensen, January 2025
%            - Bram Nap, July 2024 (automatic creation of output folders)

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
varNames = metadata.Properties.VariableNames;
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
updatedMetadataPath = updatedMetadataPath + "_processed.xlsx";

% Convert updated path to character array
updatedMetadataPath = char(updatedMetadataPath);

% Throw an error if paths.mgPipe.computeProfiles = true and there are less
% than 5 samples.
if paths.mgPipe.computeProfiles == true && numel(unique(metadata.ID))<5
    msg = 'You have turned on the computeProfiles parameter in mgPipe (paths.mgPipe.computeProfiles). However, you have very few samples. An error is likely to occur in the mgSimResCollect function. Specifically, when producing a PCoA plot to generate microbiome community FVA results. Please set paths.mgPipe.computeProfiles = false to continue. FVA results will be generated on the microbiome community models when setting paths.mgPipe.computeProfiles = false. Turning off the computeProfiles parameters will cause no summary statistics to be generated anymore, thus avoiding the error.';
    error(msg)
end

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
