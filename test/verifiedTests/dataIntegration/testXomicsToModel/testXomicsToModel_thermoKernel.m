% The COBRAToolbox: testXomicsToModel_thermoKernel.m
%
% Purpose:
%     - Drive the XomicsToModel multi-omics context-specific model extraction
%       pipeline end-to-end with the thermoKernel tissue-specific solver, on the
%       shipped generic Recon3D-derived model and the (dopaminergic-neuron) omics
%       data, and assert the extracted model is a valid, feasible, expected-scale
%       context-specific model that retains the requested core reactions.
%     - Covers XomicsToModel, preprocessingOmicsModel, fastcc and thermoKernel.
%
%     Repurposed from tutorials/dataIntegration/XomicsToModel/tutorial_XomicsToModel.m
%     (feature 006-xomicstomodel-test). This is a HEAVYWEIGHT run (~10 min); it is
%     FULL-MODE-ONLY and is skipped in the fast/default test mode.
%
% Authors:
%     - COBRA Toolbox, repurposed from the XomicsToModel tutorial (iDopaNeuro).
%

global CBTDIR
global CBT_MISSING_REQUIREMENTS_ERROR_ID

% full-mode-only: XomicsToModel on a genome-scale model takes ~10 min, so skip in
% fast/default mode (it still runs in full mode and in CI, where COBRA_CI forces full)
if strcmp(getCobraTestMode(), 'fast')
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, ...
        'testXomicsToModel_thermoKernel is full-mode-only (heavyweight ~10 min); skipped in fast mode.');
end

% XomicsToModel and the thermoKernel extraction need an LP and a MILP solver
prepareTest('needsLP', true, 'needsMILP', true);

% save the path and figure-visibility state; restore both even on error
currentDir = pwd;
origFigVis = get(0, 'DefaultFigureVisible');
restoreFigVis = onCleanup(@() set(0, 'DefaultFigureVisible', origFigVis));
set(0, 'DefaultFigureVisible', 'off');   % generate figures, but do not display them

fileDir = fileparts(which('testXomicsToModel_thermoKernel'));

% generic input model: ships in the papers submodule; skip cleanly if unavailable
genericModelPath = [CBTDIR filesep 'papers' filesep '2023_iDopaNeuro' filesep 'Recon3DModel_301_xomics_input.mat'];
if ~exist(genericModelPath, 'file')
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, ...
        'Recon3DModel_301_xomics_input.mat not found (papers submodule not initialised); skipped.');
end
loaded = load(genericModelPath);
fns = fieldnames(loaded);
model = loaded.(fns{1});

% context-specific omics data (ships beside this test)
dataFolder = [fileDir filesep 'data' filesep];
specificData = preprocessingOmicsModel([dataFolder 'bibliomicData.xlsx'], 1, 1);
specificData.exoMet = readtable([dataFolder 'exometabolomicData.txt']);
specificData.transcriptomicData = readtable([dataFolder 'transcriptomicData.txt']);

% extraction parameters (from the tutorial), with the thermoKernel tissue-specific solver
feasTol = getCobraSolverParams('LP', 'feasTol');
param = struct();
param.TolMinBoundary = -1e4;
param.TolMaxBoundary = 1e4;
param.boundPrecisionLimit = feasTol * 10;
param.closeIons = true;
param.closeUptakes = true;
param.nonCoreSinksDemands = 'closeAll';
param.sinkDMinactive = true;
param.activeGenesApproach = 'oneRxnPerActiveGene';
param.tissueSpecificSolver = 'thermoKernel';
param.fluxEpsilon = feasTol * 10;
param.fluxCCmethod = 'fastcc';
param.addCoupledRxns = 1;
param.curationOverOmics = false;
param.inactiveGenesTranscriptomics = true;
param.metabolomicWeights = 'mean';
param.transcriptomicThreshold = 2;
param.weightsFromOmics = true;
param.printLevel = 0;
param.debug = false;   % do not write debug checkpoint files

% run the extraction inside a temporary directory so that any files XomicsToModel
% writes do not land in the repository; restore the directory and clean up afterwards
tmpWork = tempname;
mkdir(tmpWork);
returnFromTmp = cd(tmpWork);
try
    [tissueModel, modelGenerationReport] = XomicsToModel(model, specificData, param);
    cd(returnFromTmp);
    rmdir(tmpWork, 's');
catch ME
    cd(returnFromTmp);
    if exist(tmpWork, 'dir'); rmdir(tmpWork, 's'); end
    % Instrumentation: the CI-only "Index in position 1 exceeds array bounds"
    % failure does not reproduce outside the full-suite state, so print the full
    % stack (file:line of the innermost frame) before rethrowing, letting a CI run
    % pin the exact failure site.
    fprintf(2, '\n[testXomicsToModel_thermoKernel] XomicsToModel failed: %s\n%s\n', ...
        ME.message, getReport(ME, 'extended', 'hyperlinks', 'off'));
    rethrow(ME);
end

% --- assertions: assert VALIDITY, not exact size. The extraction is
%     nondeterministic (model size varies by several % across solver runs), so
%     the model is checked for the properties any correct context-specific
%     extraction must satisfy rather than a captured reference size. ---

% a proper, non-empty, strictly smaller context-specific submodel
assert(~isempty(tissueModel.rxns) && ~isempty(tissueModel.mets));
assert(size(tissueModel.S, 2) < size(model.S, 2));
assert(~isempty(tissueModel.genes) && numel(tissueModel.genes) < numel(model.genes));

% a valid, feasible COBRA model
sol = optimizeCbModel(tissueModel);
assert(sol.stat == 1);

% most of the requested context-specific core (bibliomic active) reactions are retained
nCore = numel(specificData.activeReactions);
nCoreKept = sum(ismember(specificData.activeReactions, tissueModel.rxns));
assert(nCoreKept >= round(0.85 * nCore));

close all force;
cd(currentDir);
