function validated = validatePersephoneInputs(paths,resultPath) 
% Validates the inputs provided in the `paths` structure for the Persephone 
% pipeline. This function ensures that all required fields, flags, and 
% parameters are present, appropriately formatted, and meet the expected 
% constraints. Validation is performed across multiple pipeline components, 
% including MARS, mgPipe, WBM personalization, HM creation, FBA, and statistics.
% 
% USAGE:
%   validated = validatePersephoneInput(paths)
%
% INPUT:
%   paths       Structure containing all required input fields for the Persephone 
%               pipeline. Fields include:
%               - General flags and paths (e.g., `flagSeqC`, `resultPath`)
%               - Component-specific flags and parameters (e.g., `flagMars`, 
%               `marsRepoPath`, `flagMgPipe`, `metadataPath`, etc.)
% 
% OUTPUT:
%   validated   Logical scalar indicating whether the validation succeeded 
%               (true) or failed (false).
% 
% NOTES:
%   - Ensure all required flags and fields in the `paths` structure are defined 
%     prior to invoking this function. Undefined or mismatched fields will 
%     result in validation failure.
%   - This function is designed to be modular and extendable for future 
%     additions to the Persephone pipeline.
% 
% AUTHOR:
%   Tim Hensen, January 2025
%
% See also: validateattributes, validatestring, COBRA Toolbox

validated = false;

% Validate the pipeline flags
validateattributes(paths.seqC.flagSeqC,{'logical'},{'scalar'},'flagSeqC')
validateattributes(paths.Mars.flagMars,{'logical'},{'scalar'},'flagMars')
validateattributes(paths.mgPipe.flagMgPipe,{'logical'},{'scalar'},'flagMgPipe')
validateattributes(paths.persWBM.flagPersonalise,{'logical'},{'scalar'},'flagPersonalise')
validateattributes(paths.mWBM.flagMWBMCreation,{'logical'},{'scalar'},'flagMWBMCreation')
validateattributes(paths.fba.flagFBA,{'logical'},{'scalar'},'flagFBA')
validateattributes(paths.stats.flagStatistics,{'logical'},{'scalar'},'flagStatistics')

% Validate inputs that are used in multiple parts
validateattributes(resultPath,{'char','string'},{'nonempty'},'resultPath')
validateattributes(paths.General.solver,{'char','string'},{'nonempty'},'solver')
validatestring(paths.General.solver,{'ibm_cplex','gurobi','tomlab_cplex','mosek'},'solver');
validateattributes(paths.General.diet,{'char','string','cell'},{'nonempty'},'diet')
validateattributes(paths.General.metadataPath,{'char','string'},{'nonempty'},'metadataPath')
validateattributes(paths.General.numWorkersCreation,{'double','integer'},{'<=',feature('numCores')},'numWorkersCreation')
validateattributes(paths.General.numWorkersOptimisation,{'double','integer'},{'<=',feature('numCores')},'numWorkersOptimisation')



% Validate all variables that are associated with MARS
if paths.Mars.flagMars

    validateattributes(paths.Mars.marsRepoPath,{'char','string'},{'nonempty'},'marsRepoPath')
    validateattributes(paths.Mars.pythonPath,{'char','string'},{'nonempty'},'pythonPath')
    validateattributes(paths.Mars.readsTablePath,{'char','string'},{'nonempty'},'readsTablePath')
    validateattributes(paths.Mars.outputPathMars,{'char','string'},{'nonempty'},'outputPathMars')
    validateattributes(paths.Mars.outputExtensionMars,{'char','string'},{'nonempty'},'outputExtensionMars')
    validatestring(paths.Mars.outputExtensionMars,{'csv','xls','xlsx','txt'},'outputExtensionMars');
    validateattributes(paths.Mars.relAbunFilePath,{'char','string'},{'nonempty'},'relAbunFilePath') 
    validateattributes(paths.Mars.sample_read_counts_cutoff,{'double','integer'},{'>=',1},'sample_read_counts_cutoff')
    % This validation step needs to be updated to account for variable type
    % "missing".
    % validateattributes(paths.Mars.OTUTable,{'string'},{'scalartext'},'OTUTable')
    validateattributes(paths.Mars.taxaDelimiter ,{'char'},{'scalartext'},'taxaDelimiter')
    validateattributes(paths.Mars.removeClade,{'logical'},{'scalar'},'removeClade')
    validatestring(paths.Mars.reconstructionDb ,{'AGORA2', 'APOLLO', 'full_db', 'user_db'},'reconstructionDb ');
    validateattributes(paths.Mars.userDbPath,{'string'},{'scalartext'},'userDbPath')
    % This validation step needs to be updated to account for variable type
    % "missing".
    % validateattributes(paths.Mars.taxaTable,{'string'},{'scalartext'},'taxaTable')
end

% Validate all inputs for mgPipe
if paths.mgPipe.flagMgPipe
    validateattributes(paths.mgPipe.outputPathMgPipe,{'char','string'},{'nonempty'},'outputPathMgPipe')
    validateattributes(paths.mgPipe.microbeReconstructionPath,{'char','string'},{'nonempty'},'microbeReconstructionPath')
    validateattributes(paths.mgPipe.computeProfiles,{'logical'},{'scalar'},'computeProfiles')
end

% Validate inputs for WBM personalisation
if paths.persWBM.flagPersonalise
    validateattributes(paths.persWBM.outputPathPersonalisation,{'char','string'},{'nonempty'},'outputPathPersonalisation')
    validateattributes(paths.persWBM.persPhysiology,{'cell'},{},'persPhysiology')
end

% Validate inputs for HM creation
if paths.mWBM.flagMWBMCreation
    validateattributes(paths.mWBM.outputPathMWBM,{'char','string'},{'nonempty'},'outputPathMWBM')
    validateattributes(paths.mWBM.usePersonalisedWBM,{'logical'},{'scalar'},'usePersonalisedWBM')
    validateattributes(paths.mWBM.alteredWBMPath,{'char','string'},{'nonempty'},'alteredWBMPath')
end

% Validate inputs for FBA
if paths.fba.flagFBA    
    validateattributes(paths.fba.outputPathFluxResult,{'char','string'},{'nonempty'},'outputPathFluxResult')
    validateattributes(paths.fba.outputPathFluxAnalysis,{'char','string'},{'nonempty'},'outputPathFluxAnalysis')
    validateattributes(paths.fba.saveFullRes,{'logical'},{'scalar'},'saveFullRes')
    validateattributes(paths.fba.rxnList,{'cell'},{'nonempty'},'rxnlist')
    % Note, we still need to individually test for each field in
    % .paramFluxProcessing, TH.
    validateattributes(paths.fba.paramFluxProcessing,{'struct'},{'nonempty'},'paramFluxProcessing')    
end

% Validate inputs for statistics
if paths.stats.flagStatistics
    validateattributes(paths.stats.outputPathStatistics,{'char','string','cell'},{'nonempty'},'outputPathStatistics')
    validateattributes(paths.stats.response,{'char','string','cell'},{'nonempty'},'response')
    validateattributes(paths.stats.confounders,{'char','string','cell'},{''},'confounders')
    validateattributes(paths.stats.moderationAnalysis,{'logical'},{'scalar'},'moderationAnalysis')
end

validated = true;
end