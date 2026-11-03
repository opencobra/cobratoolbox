% The COBRAToolbox: testValidatePersephoneInputs.m
%
% Purpose:
%     - validatePersephoneInputs checks the paths structure of the Persephone pipeline: the
%       seven pipeline flags, the result path and the shared General settings always, and the
%       parameters of each pipeline part (SeqC, MARS, mgPipe, WBM personalisation,
%       host-microbiome creation, FBA, statistics) only when its flag is true. It returns true
%       when every check passes and raises the error of validateattributes or validatestring
%       otherwise; a reaction list with duplicates gives an error that names them.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the expected results and error identifiers follow from the
%       validateattributes and validatestring calls of the source (no first-run value is
%       needed). The paths are text only: no file or folder is read or created.
%
% Function under test:
%     src/analysis/persephone/validatePersephoneInputs.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A column reaction list with two or more duplicates fails while the message is built
%       SEVERITY: error
%       TRIGGER: paths.fba.flagFBA true and paths.fba.rxnList a column cell array in which two or
%         more entries are repeats, for example {'r1'; 'r2'; 'r1'; 'r2'}
%       OBSERVED: the error MATLAB:catenate:dimensionMismatch (the transposed list is
%         concatenated with a column of commas)
%       EXPECTED: the error 'Reactions r1,r2 are duplicated in rxnList, please remove', as for a
%         row list
%       LINES: 117
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testValidatePersephoneInputs'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a valid structure with every pipeline part switched off; the worker counts are 1, which is
% within feature('numCores') on any machine
basePaths = struct();
basePaths.seqC.flagSeqC = false;
basePaths.Mars.flagMars = false;
basePaths.mgPipe.flagMgPipe = false;
basePaths.persWBM.flagPersonalise = false;
basePaths.mWBM.flagMWBMCreation = false;
basePaths.fba.flagFBA = false;
basePaths.stats.flagStatistics = false;
basePaths.General.solver = 'gurobi';
basePaths.General.diet = 'EUAverageDiet';
basePaths.General.metadataPath = 'metadata.csv';
basePaths.General.numWorkersCreation = 1;
basePaths.General.numWorkersOptimisation = 1;

% the parameters of every pipeline part, used when its flag is switched on
seqC = struct('flagSeqC', true, 'repoPathSeqC', 'seqCRepo', 'outputPathSeqC', 'seqCOut', ...
    'fileIDSeqC', 'samples.txt', 'procKeepSeqC', false, 'maxMemSeqC', 20, 'maxCpuSeqC', 4, ...
    'maxProcSeqC', 4, 'debugSeqC', false, 'runApptainer', true);
mars = struct('flagMars', true, 'readsTablePath', 'reads.csv', 'outputPathMars', 'marsOut', ...
    'sampleReadCountCutoff', 1, 'taxaDelimiter', ';', 'removeClade', true, ...
    'reconstructionDb', 'AGORA2', 'userDbPath', '', 'taxaTablePath', '');
mgPipe = struct('flagMgPipe', true, 'relAbunFilePath', 'abundance.csv', ...
    'outputPathMgPipe', 'mgPipeOut', 'microbeReconstructionPath', 'agora', 'computeProfiles', true);
persWBM = struct('flagPersonalise', true, 'outputPathPersonalisation', 'persOut', ...
    'persPhysiology', {{}});
mWBM = struct('flagMWBMCreation', true, 'outputPathMWBM', 'mwbmOut', ...
    'usePersonalisedWBM', false, 'alteredWBMPath', 'alteredWBMs');
fba = struct('flagFBA', true, 'outputPathFluxResult', 'fluxOut', ...
    'outputPathFluxAnalysis', 'fluxAnalysisOut', 'saveFullRes', true, ...
    'rxnList', {{'DM_r1', 'DM_r2', 'DM_r3'}}, 'paramFluxProcessing', struct('fluxMethod', 'x'));
stats = struct('flagStatistics', true, 'outputPathStatistics', 'statsOut', ...
    'response', 'Disease', 'confounders', {{'Age', 'Sex'}});

%% every pipeline part off: only the flags and the shared settings are checked

validated = validatePersephoneInputs(basePaths, 'results');
assert(islogical(validated) && isscalar(validated) && validated);

% the result path may be a string, and the other accepted solvers pass
assert(validatePersephoneInputs(basePaths, "results"));
for solver = {'ibm_cplex', 'tomlab_cplex', 'mosek'}
    paths = basePaths;
    paths.General.solver = solver{1};
    assert(validatePersephoneInputs(paths, 'results'));
end

%% every pipeline part on with valid parameters

paths = basePaths;
paths.seqC = seqC;
paths.Mars = mars;
paths.mgPipe = mgPipe;
paths.persWBM = persWBM;
paths.mWBM = mWBM;
paths.fba = fba;
paths.stats = stats;
% the confounders check passes the attribute list {''}, for which validateattributes prints the
% warning 'Attribute  not supported.' (not suppressed here); the class check still applies
assert(validatePersephoneInputs(paths, 'results'));

%% invalid flags and shared settings

% each structure below differs from a valid one in a single field, so the error comes from the
% check of that field

% a flag that is not logical
paths = basePaths;
paths.seqC.flagSeqC = 1;
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% an empty result path
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {basePaths, ''}));

% a solver outside the four accepted ones
paths = basePaths;
paths.General.solver = 'glpk';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% more creation workers than processor cores
paths = basePaths;
paths.General.numWorkersCreation = feature('numCores') + 1;
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

%% invalid parameters of a pipeline part that is switched on

% SeqC: a memory limit below 1
paths = basePaths;
paths.seqC = seqC;
paths.seqC.maxMemSeqC = 0;
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% MARS: an unknown reconstruction database
paths = basePaths;
paths.Mars = mars;
paths.mgPipe.relAbunFilePath = 'abundance.csv';
paths.Mars.reconstructionDb = 'unknownDb';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% mgPipe: an empty output path
paths = basePaths;
paths.mgPipe = mgPipe;
paths.mgPipe.outputPathMgPipe = '';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% WBM personalisation: physiology that is not a cell array
paths = basePaths;
paths.persWBM = persWBM;
paths.persWBM.persPhysiology = 'weight';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% host-microbiome creation: a non-logical usePersonalisedWBM
paths = basePaths;
paths.mWBM = mWBM;
paths.mWBM.usePersonalisedWBM = 'yes';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% FBA: an empty flux-processing structure
paths = basePaths;
paths.fba = fba;
paths.fba.paramFluxProcessing = struct([]);
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

% statistics: an empty response
paths = basePaths;
paths.stats = stats;
paths.stats.response = '';
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}));

%% FBA: duplicated reactions are named in the error

% the entries left after removing the first occurrence of every reaction are listed, joined by
% commas (a row list; a column list with two or more duplicates is skipped, see the defect)
paths = basePaths;
paths.fba = fba;
paths.fba.rxnList = {'DM_r1', 'DM_r2', 'DM_r1', 'DM_r3', 'DM_r2'};
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}, ...
    'testMessage', 'Reactions DM_r1,DM_r2 are duplicated in rxnList, please remove'));

% a single duplicate, in a row or in a column list
paths.fba.rxnList = {'DM_r1', 'DM_r2', 'DM_r1'};
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}, ...
    'testMessage', 'Reactions DM_r1 are duplicated in rxnList, please remove'));
paths.fba.rxnList = {'DM_r1'; 'DM_r2'; 'DM_r1'};
assert(verifyCobraFunctionError('validatePersephoneInputs', 'inputs', {paths, 'results'}, ...
    'testMessage', 'Reactions DM_r1 are duplicated in rxnList, please remove'));

% a column list without duplicates passes
paths.fba.rxnList = {'DM_r1'; 'DM_r2'};
assert(validatePersephoneInputs(paths, 'results'));

% change the directory
cd(currentDir)
