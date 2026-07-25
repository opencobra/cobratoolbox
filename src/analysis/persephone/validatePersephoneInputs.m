function validated = validatePersephoneInputs(paths, resultPath)
% Validate the inputs supplied in the `paths` structure for the Persephone pipeline
%
% Ensures that the required fields, flags, and parameters for each pipeline
% component (SeqC, MARS, mgPipe, WBM personalisation, host-microbiome creation,
% FBA, and statistics) are present, correctly typed, and within their expected
% constraints. Validation errors are raised by the underlying
% `validateattributes`/`validatestring` calls.
%
% USAGE:
%
%    validated = validatePersephoneInputs(paths, resultPath)
%
% INPUTS:
%    paths:         structure with all Persephone input fields. Fields used:
%
%                     * .General - shared settings (`.solver`, `.diet`,
%                       `.metadataPath`, worker counts)
%                     * .seqC - SeqC flag and parameters
%                     * .Mars - MARS flag and parameters
%                     * .mgPipe - mgPipe flag and parameters
%                     * .persWBM - WBM personalisation flag and parameters
%                     * .mWBM - host-microbiome creation flag and parameters
%                     * .fba - FBA flag and parameters (including
%                       `.rxnList` and `.paramFluxProcessing`)
%                     * .stats - statistics flag and parameters
%    resultPath:    char/string, path to the results directory (validated as
%                   non-empty)
%
% OUTPUT:
%    validated:    logical scalar, true if validation succeeded
%
% .. Author: - Tim Hensen, January 2025

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

% Validate SeqC variables
if paths.seqC.flagSeqC
    validateattributes(paths.seqC.repoPathSeqC,{'char','string'},{'nonempty'},'repoPathSeqC')
    validateattributes(paths.seqC.outputPathSeqC,{'char','string'},{'nonempty'},'outputPathSeqC')
    validateattributes(paths.seqC.fileIDSeqC,{'char','string'},{'nonempty'},'fileIDSeqC')
    validateattributes(paths.seqC.procKeepSeqC,{'logical'},{'scalar'},'procKeepSeqC')
    validateattributes(paths.seqC.maxMemSeqC,{'double','integer'},{'>=',1},'maxMemSeqC')
    validateattributes(paths.seqC.maxCpuSeqC,{'double','integer'},{'>=',1},'maxCpuSeqC')
    validateattributes(paths.seqC.maxProcSeqC,{'double','integer'},{'>=',1},'maxProcSeqC')
    validateattributes(paths.seqC.debugSeqC,{'logical'},{'scalar'},'debugSeqC')
    validateattributes(paths.seqC.runApptainer,{'logical'},{'scalar'},'runApptainer')
end

% Validate all variables that are associated with MARS
if paths.Mars.flagMars
    validateattributes(paths.Mars.readsTablePath,{'char','string'},{'nonempty'},'readsTablePath')
    validateattributes(paths.Mars.outputPathMars,{'char','string'},{'nonempty'},'outputPathMars')
    validateattributes(paths.mgPipe.relAbunFilePath,{'char','string'},{'nonempty'},'relAbunFilePath') 
    validateattributes(paths.Mars.sampleReadCountCutoff,{'double','integer'},{'>=',1},'sample_read_counts_cutoff')
    validateattributes(paths.Mars.taxaDelimiter ,{'char','string'},{'scalartext'},'taxaDelimiter')
    validateattributes(paths.Mars.removeClade,{'logical'},{'scalar'},'removeClade')
    validatestring(paths.Mars.reconstructionDb ,{'AGORA2', 'APOLLO', 'full_db', 'user_db'},'reconstructionDb ');
    validateattributes(paths.Mars.userDbPath,{'char','string'},{'scalartext'},'userDbPath')
    validateattributes(paths.Mars.taxaTablePath,{'char','string'},{'scalartext'},'taxaTable')
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
    % Check there are no duplicates in the rxnList variable
    if length(unique(paths.fba.rxnList)) ~= length(paths.fba.rxnList)
        rxnList = paths.fba.rxnList;
        % Find unique indexes
        [~,idx] = unique(rxnList);

        % Remove unique indexes to only obtain the non-unique entries
        rxnList(idx) = [];
        
        % Make the rxnList into a comma seperated string 
        rxnListStringTmp= [rxnList',[repmat({','},numel(rxnList)-1,1);{[]}]]';
        rxnListStringDupl = [rxnListStringTmp{:}];
        % Create error
        error('Reactions %s are duplicated in rxnList, please remove', rxnListStringDupl);
    end

    % Note, we still need to individually test for each field in
    % .paramFluxProcessing, TH.
    validateattributes(paths.fba.paramFluxProcessing,{'struct'},{'nonempty'},'paramFluxProcessing')    
end

% Validate inputs for statistics
if paths.stats.flagStatistics
    validateattributes(paths.stats.outputPathStatistics,{'char','string','cell'},{'nonempty'},'outputPathStatistics')
    validateattributes(paths.stats.response,{'char','string','cell'},{'nonempty'},'response')
    validateattributes(paths.stats.confounders,{'char','string','cell'},{''},'confounders')
end

validated = true;
end