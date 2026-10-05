% The COBRAToolbox: testBuildAtomAndBondTransitionMultigraph.m
%
% Purpose:
%     - Test that buildAtomAndBondTransitionMultigraph returns M2BiE, M2BiW and
%       BTi2R as sparse double matrices by default and as full double matrices
%       with options.denseBondMatrices = 1, with identical values, sizes and
%       classes of every other output in both modes (feature
%       20260921-125236-sparse-bond-matrices, FR-015).
%     - Test that the atomic and bond decompositions hold with zero residual
%       in both modes, and that the bond mismatch report prints identically in
%       both modes on a deliberately inconsistent model.
%     - Test that options.denseBondMatrices has no effect when
%       options.bondTransitionMultigraph = 0.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-125236-sparse-bond-matrices

global CBTDIR

% no solver is needed; declared for the harness convention
prepareTest();

% save the current path and initialize the test
currentDir = pwd;
fileDir = fileparts(which('testBuildAtomAndBondTransitionMultigraph'));
cd(fileDir);

% atom-mapped reaction files shipped beside the reacting-moiety tests
rxnFilesDir = [fileDir filesep 'data' filesep 'rxnFiles'];
assert(isfolder(rxnFilesDir), 'Atom-mapped rxnFiles fixture not found.');

% the r0317/ACONTm/r0426 Recon3D subnetwork used by testConservedReactingMoieties.m
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'Recon3D_301.mat']);
subModel = extractSubNetwork(model, {'r0317'; 'ACONTm'; 'r0426'});

bondMatrixIdx = 9:11; % M2BiE, M2BiW, BTi2R
otherIdx = setdiff(1:12, bondMatrixIdx);

options.directed = 0;
options.sanityChecks = 1;
defaultOut = cell(1, 12);
[defaultOut{:}] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, options);
denseOptions = options;
denseOptions.denseBondMatrices = 1;
denseOut = cell(1, 12);
[denseOut{:}] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, denseOptions);

% (d) both decompositions hold with zero residual in both modes.
% Exact comparison with zero is valid (Principle III): every entry involved is an
% integer or an exact binary fraction, so the residual is computed exactly
% (specs/20260921-125236-sparse-bond-matrices/research.md R4).
modeOutputs = {defaultOut, denseOut};
modeNames = {'default', 'dense'};
for modeIdx = 1:2
    [atomResidual, bondResidual] = decompositionResiduals(subModel, modeOutputs{modeIdx});
    assert(atomResidual == 0, sprintf('FR-015 (d): atomic decomposition residual is %g in %s mode.', atomResidual, modeNames{modeIdx}));
    assert(bondResidual == 0, sprintf('FR-015 (d): bond decomposition residual is %g in %s mode.', bondResidual, modeNames{modeIdx}));
end

% (e) the bond mismatch report prints identically in both modes. Doubling one
% stoichiometric coefficient of a bond-bearing metabolite of r0317 makes both
% decompositions inconsistent while the RXN-file atom and bond mappings, and
% hence the graphs, are unchanged. The atom-side report and warning also fire
% and stay visible; that is expected.
dBTM = defaultOut{8};
r0317Idx = find(strcmp(subModel.rxns, 'r0317'));
candidateMets = find(subModel.S(:, r0317Idx) ~= 0);
perturbedMetIdx = candidateMets(find(ismember(subModel.mets(candidateMets), dBTM.Nodes.mets), 1));
assert(~isempty(perturbedMetIdx), 'FR-015 (e): no bond-bearing metabolite of r0317 found to perturb.');
badModel = subModel;
badModel.S(perturbedMetIdx, r0317Idx) = 2 * badModel.S(perturbedMetIdx, r0317Idx);
% Both modes are called from the same line, so the warning backtraces in the
% captured text are identical too.
modeOptions = {options, denseOptions};
reportTexts = cell(1, 2);
for modeIdx = 1:2
    reportTexts{modeIdx} = runWithDiary(badModel, rxnFilesDir, modeOptions{modeIdx});
end
[defaultText, denseText] = reportTexts{:};
for modeIdx = 1:2
    assert(contains(reportTexts{modeIdx}, 'Inconsistency between reaction stoichiometry and bond mapped reactions'), ...
        sprintf('FR-015 (e): bond mismatch report not printed in %s mode.', modeNames{modeIdx}));
    assert(contains(reportTexts{modeIdx}, 'Inconsistent directed bond transition multigraph'), ...
        sprintf('FR-015 (e): bond inconsistency warning not raised in %s mode.', modeNames{modeIdx}));
end
% Exact text comparison is valid: both modes perform the same arithmetic on the
% same values (research R4), and the printed report is discrete text.
assert(strcmp(defaultText, denseText), ...
    'FR-015 (e): the console output, including the bond mismatch report, differs between default and dense modes.');

% (b) with options.denseBondMatrices = 1 the three matrices are full double, as before
for k = bondMatrixIdx
    assert(~issparse(denseOut{k}) && isa(denseOut{k}, 'double'), ...
        sprintf('FR-015 (b): output %d must be a full double matrix when options.denseBondMatrices = 1.', k));
end

% (c) every other output is identical across modes, including class and sparsity,
% and the three matrices hold identical values. Exact comparison is valid: the
% outputs are discrete (graphs, index maps, 0/1 incidence, integer bond types).
for k = otherIdx
    assert(isequaln(defaultOut{k}, denseOut{k}), ...
        sprintf('FR-015 (c): output %d differs between default and dense modes.', k));
    assert(strcmp(class(defaultOut{k}), class(denseOut{k})) && issparse(defaultOut{k}) == issparse(denseOut{k}), ...
        sprintf('FR-015 (c): output %d changes class or sparsity between default and dense modes.', k));
end
for k = bondMatrixIdx
    assert(isequal(size(defaultOut{k}), size(denseOut{k})) && isequaln(full(defaultOut{k}), denseOut{k}), ...
        sprintf('FR-015 (c): output %d holds different values in default and dense modes.', k));
end

% (a) by default the three matrices are sparse double (FR-003)
for k = bondMatrixIdx
    assert(issparse(defaultOut{k}) && isa(defaultOut{k}, 'double'), ...
        sprintf('FR-015 (a), FR-003: output %d must be a sparse double matrix by default.', k));
end

% (f) with options.bondTransitionMultigraph = 0, options.denseBondMatrices has no
% effect (US1 acceptance scenario 4); only the first five outputs are assigned.
noBondOptions = options;
noBondOptions.bondTransitionMultigraph = 0;
noBondDenseOptions = noBondOptions;
noBondDenseOptions.denseBondMatrices = 1;
noBondOut = cell(1, 5);
[noBondOut{:}] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, noBondOptions);
noBondDenseOut = cell(1, 5);
[noBondDenseOut{:}] = buildAtomAndBondTransitionMultigraph(subModel, rxnFilesDir, noBondDenseOptions);
for k = 1:5
    assert(isequaln(noBondOut{k}, noBondDenseOut{k}) && strcmp(class(noBondOut{k}), class(noBondDenseOut{k})) && ...
        issparse(noBondOut{k}) == issparse(noBondDenseOut{k}), ...
        sprintf('FR-015 (f): output %d depends on options.denseBondMatrices when options.bondTransitionMultigraph = 0.', k));
end

% return to the original directory
cd(currentDir);

function [atomResidual, bondResidual] = decompositionResiduals(model, out)
% Recompute both decompositions from the outputs, deriving N and the
% bond-mapped subsets as buildAtomAndBondTransitionMultigraph does.
[dATM, metAtomMappedBool, rxnAtomMappedBool, M2Ai, Ti2R] = out{1:5};
[dBTM, M2BiE, M2BiW, BTi2R, BTiE] = out{8:12};
atomN = sparse(model.S(metAtomMappedBool, rxnAtomMappedBool));
atomRes = (M2Ai * M2Ai') * atomN - M2Ai * incidence(dATM) * Ti2R;
atomResidual = full(max([0; abs(atomRes(:))]));
rxnBondMappedBool = ismember(model.rxns, dBTM.Edges.rxns);
metBondMappedBool = ismember(model.mets, dBTM.Nodes.mets(~ismember(dBTM.Nodes.Bond, {'E'})));
bondN = sparse(model.S(metBondMappedBool, rxnBondMappedBool));
bondRes = (M2BiW(metBondMappedBool, :) * M2BiE(metBondMappedBool, :)') * bondN - ...
    M2BiE(metBondMappedBool, :) * BTiE * BTi2R;
bondResidual = full(max([0; abs(bondRes(:))]));
end

function consoleText = runWithDiary(model, rxnFilesDir, options)
% Run the function with its console output recorded by diary rather than
% evalc, so every warning still reaches the console (Principle VII-B); the
% caller's diary state is restored afterwards.
diaryFile = [tempname '.txt'];
previousDiaryState = get(0, 'Diary');
previousDiaryFile = get(0, 'DiaryFile');
restoreDiary = onCleanup(@() restoreDiaryState(previousDiaryState, previousDiaryFile, diaryFile)); %#ok<NASGU>
diary(diaryFile);
buildAtomAndBondTransitionMultigraph(model, rxnFilesDir, options);
diary('off');
consoleText = fileread(diaryFile);
end

function restoreDiaryState(previousDiaryState, previousDiaryFile, diaryFile)
diary('off');
set(0, 'DiaryFile', previousDiaryFile);
if strcmp(previousDiaryState, 'on')
    diary('on');
end
if isfile(diaryFile)
    delete(diaryFile);
end
end
