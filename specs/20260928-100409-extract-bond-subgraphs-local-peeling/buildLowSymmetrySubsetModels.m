function models = buildLowSymmetrySubsetModels(corpusDir, homeDir)
% Build the lowSymmetryRisk_2000rxn model and its nested subsets
%
% USAGE:
%
%    models = buildLowSymmetrySubsetModels(corpusDir, homeDir)
%
% INPUTS:
%    corpusDir:    directory of the atom-mapped RXN corpus
%    homeDir:      home directory holding repos/ReconXKG-cidev and repos/reconXmoieties
%
% OUTPUT:
%    models:       structure with fields n332, n531, n1067, n1604 (nested subsets, whole
%                  subsystems added in rng(1) shuffled order up to 250/500/1000/1500
%                  reactions) and n1960 (the full selection)
%
% NOTE:
%    Follows sections 2, 2b and 7 of
%    reconXmoieties/experiments/moietySizing/scripts/exp_measure_conserved_moiety_runtime_2000rxn.mlx.
%    Used by captureLocalPeelingFixtures.m and extractBondSubgraphsPeelingCheck.m.
%
% .. Author: - COBRA Toolbox, feature 20260928-100409-extract-bond-subgraphs-local-peeling

addpath(fullfile(homeDir, 'repos', 'reconXmoieties', 'scripts'));   % scanRXNFileIssues
modelPath = fullfile(homeDir, 'repos', 'ReconXKG-cidev', 'ReconXKGtoCobra', 'models', ...
    'vmh2_reconx_for_atom_mapping.mat');
selectionFile = fullfile(homeDir, 'repos', 'reconXmoieties', 'data', 'models', ...
    'lowSymmetryRisk_2000rxn.mat');
model = readCbModel(modelPath);
model.rxns = regexprep(model.rxns, '^R_', '');
model.mets = regexprep(model.mets, '^M_', '');
[~, rxnHasRXNFile] = findRXNFiles(model, corpusDir);
atomMappedRxns = model.rxns(rxnHasRXNFile);
sel = load(selectionFile, 'selectedRxns', 'chosen', 'coaSet');
missingFromModel = setdiff(sel.selectedRxns, model.rxns);
assert(isempty(missingFromModel), 'Selected reactions not in model: %s', strjoin(missingFromModel, ', '))
rxnList = intersect(sel.selectedRxns, atomMappedRxns, 'stable');
runModel = extractSubNetwork(model, rxnList);
runModel.description = 'lowSymmetryRisk_2000rxn';

scanOptions = struct('model', runModel, 'onlyModelRxns', true, 'depth', 'reader');
rxnScanReport = scanRXNFileIssues(corpusDir, scanOptions);
blockedRxns = rxnScanReport.files(strcmp(rxnScanReport.status, 'blocked'));
if ~isempty(blockedRxns)
    runModel = removeRxns(runModel, blockedRxns);
end

if isfield(runModel, 'subSystems')
    rxnSubsRaw = runModel.subSystems;
else
    rxnSubsRaw = runModel.subsystems;
end
rxnSubs = cellfun(@firstSubsystem, rxnSubsRaw, 'UniformOutput', false);
rng(1);
uSubs = unique(rxnSubs);
subsOrder = uSubs(randperm(numel(uSubs)));
subsCounts = cellfun(@(s) nnz(strcmp(rxnSubs, s)), subsOrder);
cumCounts = cumsum(subsCounts);
targets = [250 500 1000 1500];
names = {'n332', 'n531', 'n1067', 'n1604'};
models = struct();
for p = 1:numel(targets)
    k = find(cumCounts >= targets(p), 1);
    if isempty(k)
        k = numel(subsOrder);
    end
    subsetRxns = runModel.rxns(ismember(rxnSubs, subsOrder(1:k)));
    models.(names{p}) = extractSubNetwork(runModel, subsetRxns);
end
models.n1960 = runModel;
end

function s = firstSubsystem(entry)
% First subsystem name of a model.subSystems entry, as char (verbatim from the notebook)
if ischar(entry)
    s = entry;
elseif isstring(entry) && isscalar(entry)
    s = char(entry);
elseif iscell(entry) && ~isempty(entry)
    s = strjoin(cellfun(@char, entry, 'UniformOutput', false), '; ');
else
    s = '';
end
end
