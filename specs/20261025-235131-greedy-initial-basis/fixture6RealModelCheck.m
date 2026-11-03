function results = fixture6RealModelCheck()
% Reproducibility check for SC-006 of feature 20261025-235131-greedy-initial-basis: on a
% genome-scale model, a supplied partial basis survives unchanged and is completed.
%
% USAGE:
%
%    results = fixture6RealModelCheck()
%
% OUTPUT:
%    results:    structure array, one element per model run, with the counts, their
%                scope and the verdicts
%
% NOTE:
%
%    A DOCUMENTED REPRODUCIBILITY CHECK (constitution Principle III), not a CI test.
%    Neither model can be relied on in CI: iDopaNeuroC lives in the `papers` git
%    submodule, and the Recon3D file lives outside the repository.
%
%    No atom-mapped iDopaNeuroC or Recon3D exists in this repository, so the conserved
%    moiety matrix from identifyConservedMoieties cannot be supplied. The supplied basis
%    is therefore a random subset of rows of a previously computed non-negative basis
%    (research R7):
%
%    * iDopaNeuroC: 50 random rows of a basis computed here, plus the sum of the first
%      two of them, which must be reported as dependent;
%    * Recon3D: 125 random rows of `model.L` (251 x 5824) from the variational-kinetics
%      model file, a basis computed before this feature. Rows of it that fail the
%      current accuracy target are rejected and reported, as FR-002 requires.
%
%    Expected output is recorded in fixture6RealModelCheck-expected.md beside this file.
%
% Author: - feature 20261025-235131-greedy-initial-basis, 2026-10-26

featureDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(fileparts(featureDir));
if ~changeCobraSolver('gurobi', 'LP', 0)
    error('fixture6RealModelCheck:solverMissing', 'gurobi is required.');
end

results = struct('model', {}, 'supplyRoute', {}, 'nullity', {}, 'supplied', {}, ...
    'kept', {}, 'dependent', {}, 'dependentIndex', {}, 'rejected', {}, ...
    'rejectedReasons', {}, 'added', {}, 'nSignRetries', {}, 'nLPSolves', {}, ...
    'nTargetedObjectives', {}, 'outcome', {}, 'keptUnchanged', {}, ...
    'residualAbsolute', {}, 'acceptanceTarget', {}, 'elapsedTime', {}, 'solver', {}, ...
    'verdict', {});

% iDopaNeuroC, the model used by feature 20260914's reproducibility check
dopaFile = fullfile(repoRoot, 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat');
if exist(dopaFile, 'file')
    loaded = load(dopaFile);
    dopa = loaded.iDopaNeuroC;
    S = dopa.S(:, dopa.SConsistentRxnBool);
    dopaModel = struct('S', S, 'SConsistentRxnBool', true(size(S, 2), 1));
    param = struct('printLevel', 0, 'maxNewBasisTime', 60, 'maxTime', 600);
    rng(20261026, 'twister');
    [Zpos0, ~, status0] = greedyExtremeRayBasis(dopaModel, param);
    if ~strcmp(status0.outcome, 'complete')
        error('fixture6RealModelCheck:noReference', ...
            'The reference basis for iDopaNeuroC is %s.', status0.outcome);
    end
    rng(20261027, 'twister');
    chosen = randperm(size(Zpos0, 1), 50);
    supplied = [Zpos0(chosen, :); Zpos0(chosen(1), :) + Zpos0(chosen(2), :)];
    param.initialBasis = supplied;
    rng(20261028, 'twister');
    [Zpos, ~, status] = greedyExtremeRayBasis(dopaModel, param);
    result = summarise('iDopaNeuroC (internal, consistent reactions)', ...
        sprintf('50 random rows of a basis computed here (seed 20261026) + 1 dependent sum row'), ...
        supplied, Zpos, status);
    result.verdict = verdict(result, isequal(status.initialBasisDependentIndex, 51));
    results(end+1) = result;
else
    fprintf('fixture6RealModelCheck: %s not found; iDopaNeuroC skipped.\n', dopaFile);
end

% Recon3D, the model and file used by feature 20261003
reconFile = fullfile(char(java.lang.System.getProperty('user.home')), 'drive', 'sbgCloud', ...
    'projects', 'variationalKinetics', 'data', 'Recon3T', ...
    'Recon3DModel_301_xomics_input_VK_withL.mat');
if exist(reconFile, 'file')
    loaded = load(reconFile);
    recon = loaded.model;
    param = struct('printLevel', 0, 'internalStoichiometriMatrixLeftNullspace', true, ...
        'maxNewBasisTime', 120, 'maxTime', 1200);
    rng(20261029, 'twister');
    chosen = sort(randperm(size(recon.L, 1), 125));
    supplied = recon.L(chosen, :);
    param.initialBasis = supplied;
    rng(20261030, 'twister');
    [Zpos, ~, status] = greedyExtremeRayBasis(recon, param);
    result = summarise('Recon3D 3.01 (internal, consistent reactions)', ...
        '125 random rows of model.L, a basis computed before this feature', ...
        supplied, Zpos, status);
    result.verdict = verdict(result, true);
    results(end+1) = result;
else
    fprintf('fixture6RealModelCheck: %s not found; Recon3D skipped.\n', reconFile);
end

for i = 1:numel(results)
    r = results(i);
    fprintf(['%s\n  route: %s\n  nullity %d | supplied %d, kept %d, dependent %d %s, ' ...
        'rejected %d %s | added %d | sign retries %d, LPs %d, targeted %d\n' ...
        '  outcome %s, kept rows unchanged %d, residual %g (target %g), %.1f s, %s\n' ...
        '  verdict: %s\n'], r.model, r.supplyRoute, r.nullity, r.supplied, r.kept, ...
        r.dependent, mat2str(r.dependentIndex), r.rejected, ...
        strjoin(unique(r.rejectedReasons), ','), r.added, r.nSignRetries, r.nLPSolves, ...
        r.nTargetedObjectives, r.outcome, r.keptUnchanged, r.residualAbsolute, ...
        r.acceptanceTarget, r.elapsedTime, r.solver, r.verdict);
end


function result = summarise(modelName, supplyRoute, supplied, Zpos, status)
nKept = status.initialBasisKept;
result = struct();
result.model = modelName;
result.supplyRoute = supplyRoute;
result.nullity = status.raysExpected;
result.supplied = status.initialBasisSupplied;
result.kept = nKept;
result.dependent = status.initialBasisDependent;
result.dependentIndex = status.initialBasisDependentIndex;
result.rejected = status.initialBasisRejected;
result.rejectedReasons = status.initialBasisRejectedReason;
result.added = status.raysAdded;
result.nSignRetries = status.nSignRetries;
result.nLPSolves = status.nLPSolves;
result.nTargetedObjectives = status.nTargetedObjectives;
result.outcome = status.outcome;
% value-identical: every entry of the kept rows bitwise equal to what was supplied
result.keptUnchanged = isequal(full(Zpos(1:nKept, :)), ...
    full(supplied(status.initialBasisKeptIndex, :)));
result.residualAbsolute = status.residualAbsolute;
result.acceptanceTarget = status.acceptanceTarget;
result.elapsedTime = status.elapsedTime;
result.solver = status.solverUsed;
result.verdict = '';


function text = verdict(result, extraCondition)
if strcmp(result.outcome, 'complete') && result.keptUnchanged && extraCondition && ...
        result.kept + result.added == result.nullity
    text = 'PASS';
else
    text = 'FAIL';
end
