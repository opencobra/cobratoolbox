function runMars(pythonPath, marsRepoPath, cutoffMARS, outputExtensionMARS, flagLoneSpecies, taxaSplit, removeCladeExtensionsFromTaxa, whichModelDatabase, userDatabase_path, sample_read_counts_cutoff, readsTablePath, taxaTable, outputPathMARS)
%
% This function integrates MATLAB with the MARS Python repository to process 
% microbiome taxonomy and read abundance data. The MARS pipeline maps 
% joined microbiome data to a metabolic model database for downstream analysis.
%
% INPUTS:
%   pythonPath                      char with path to the Python executable (e.g., Anaconda installation).
%   marsRepoPath                    char with path to the directory containing the MARS pipeline repository.
%   cutoffMARS                      double with relative abundance cutoff threshold below which relative abundances 
%                                   are treated as zero. Defaul is 1e-6.
%   outputExtensionMARS             char with desired file format for output files (e.g., 'csv', 'txt').
%   flagLoneSpecies                 logical that indicates if genus name is omitted in species names 
%                                   (e.g., "copri" instead of "Prevotella copri").
%   taxaSplit                       char with delimiter used to separate taxonomic levels.
%   removeCladeExtensionsFromTaxa   Logical which specifies whether clade name extensions should be removed 
%                                   from microbiome taxa for compatibility with AGORA2 models.
%   whichModelDatabase              char that specifies the metabolic model database to use. 
%                                   Options: 'AGORA2', 'APOLLO', 'full_db', 'user_db' (requires 'userDatabase_path').
%   userDatabase_path               char with path to a user-defined model database file, required only if 'whichModelDatabase' is set to 'user_db'.
%   sample_read_counts_cutoff       double variable. Threshold for read counts below which samples are excluded.
%                                   Only applies if 'readsTablePath' contains absolute read counts.
%   readsTablePath                  char with path to the file containing microbiome taxonomy and read abundance data.
%   taxaTable                       char with path to the file containing taxonomic assignments. 
%                                   Required only if taxonomy is not included in 'readsTablePath'.
%
% OUTPUTS:
%   The function does not return variables but writes processed results 
%   to the specified output directory in the MARS pipeline.
%
% DEPENDENCIES:
%   - Python and the MARS repository must be installed and accessible.
%   - COBRA Toolbox for MATLAB must be properly set up if further 
%     integration with COBRA models is required.
%
% NOTES:
%   - Ensure 'pythonPath' is set to the correct Python executable version 
%     and environment containing the required MARS dependencies.
%   - If 'readsTablePath' already includes taxonomy assignments, 'taxaTable' is optional.
%
% AUTHOR: Tim Hensen, January 2025
%         modified by Jonas Widder, January 2025 (added generateStackedBarPlot_PhylumMARScoverage.m)


% Initialise the python environment
pyStatus = pyenv;
if isempty(pyStatus.Version)
    pyenv('Version',pythonPath);
end

%Enter the MARS folder
cd(marsRepoPath);

% Import the entire MARS repository so that the all scripts are on a path
% that MATLAB recognises
disp(' > Import the MARS repository.');
py.importlib.import_module('MARS');

%Enter folder that contains the "main.py" script

cd(fullfile(marsRepoPath, 'MARS'));

% Set all optional inputs in Python readable format
marsOptArg = pyargs('cutoff', cutoffMARS, ...
    'output_format', string(outputExtensionMARS), ...
    'flagLoneSpecies',flagLoneSpecies, ...
    'taxaSplit', string(taxaSplit), ...
    'removeCladeExtensionsFromTaxa', removeCladeExtensionsFromTaxa, ...
    'whichModelDatabase', whichModelDatabase,...
    'userDatabase_path', userDatabase_path, ...
    'sample_read_counts_cutoff', sample_read_counts_cutoff);

% Run MARS mapping of joined_MBs to AGORA2 database
disp(' > Run MARS.');
py.main.process_microbial_abundances(readsTablePath, taxaTable, outputPathMARS, marsOptArg);

%%%%%%%%%%%%% Additional descriptive statistics on MARS results %%%%%%%%%%%%%%%%%%%%%%
disp(' > Generate metrics visualizations.');

% 1) Generate stacked barplots comparing pre to post MARS-mapped Pyhlum mean relative abundances
input_stackedBarPlots_preMapping_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum', sprintf('preMapping_abundanceMetrics_Phylum.%s', outputExtensionMARS)));
input_stackedBarPlots_postMapping_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum', sprintf('mapped_abundanceMetrics_Phylum.%s', outputExtensionMARS)));
saveDir_stackedBarPlot_path = string(fullfile(outputPathMARS, 'metrics', 'Phylum'));

% In case the input paths exist run the visualization function on the inputs
% If an error arises in figure creation, skip the step & continue Persephone, but log a warning
if exist(input_stackedBarPlots_preMapping_path, 'file') == 2 && exist(input_stackedBarPlots_postMapping_path, 'file') == 2
    try
        generateStackedBarPlot_PhylumMARScoverage(input_stackedBarPlots_preMapping_path, ...
            input_stackedBarPlots_postMapping_path, saveDir_stackedBarPlot_path, 'mappingDatabase_name', whichModelDatabase)
    catch ME
        warning('Error occurred in generateStackedBarPlot_PhylumMARScoverage function:');
        disp(ME.message);
    end
else
    warning('One or both input files do not exist. Skipping generateStackedBarPlot_PhylumMARScoverage function.');
end

end