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
%     - Test that a model containing a reaction with no bonds (implicit-hydrogen water
%       transport, data/rxn) builds, with that reaction's atom transition in the atom graph and
%       no bond transition from it (feature 20261012-093525-symmetric-iso-zero-bond, FR-005).
%
% Function under test:
%     src/analysis/topology/reactingMoieties/buildAtomAndBondTransitionMultigraph.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; RXN files shipped or written to a temporary folder, with a three-reaction
%     extract of Recon3D and toy models.
%
% Coverage exemptions:
%     Lines 187-189, 498-519: the bodies of two `if 0` blocks.
%     Lines 430, 438, 862, 870: unreachable, the index tested is set to 1:n on the lines above, so its differences are all 1.
%     Lines 458, 462, 467, 472: unreachable, incidence() refuses a self-loop, so each column has one -1 and one +1, and each node has an edge since the graph is built from its edges.
%     Line 633: unreachable, the key repeats the node name, and the names of the digraph nodes are unique.
%     Lines 936, 940, 945, 950: unreachable, as for lines 458-472, for the graph of the bonds.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Decompartmentalising the model keeps the opening bracket
%       SEVERITY: wrong-result
%       TRIGGER: model.mets with compartments, as in 'a[c]', and RXN files without, as in 'a'
%       OBSERVED: model.mets{i}(1:end-2) turns 'a[c]' into 'a[', which matches no atom
%       EXPECTED: 'a[c]' becomes 'a', the three characters of the compartment removed, as for the atoms at line 275
%       LINES: 206, 207
%     - DEFECT: A reaction with an elemental mismatch stops the build instead of being skipped
%       SEVERITY: error
%       TRIGGER: an RXN file with an atom transition between two elements
%       OBSERVED: the reaction is reported as skipped, then the unfilled rows of the edge table stop digraph at line 382 with an error about the edge table
%       EXPECTED: the reaction is skipped, as the message says and as for an RXN file that cannot be parsed, and the graphs are built from the others
%       LINES: 325, 368
%     - DEFECT: The bond graph is not decompartmentalised
%       SEVERITY: error
%       TRIGGER: model.mets without compartments, RXN files with compartments, and options.bondTransitionMultigraph = 1
%       OBSERVED: the atoms are decompartmentalised for the atom graph only, so no atom of the bonds is found, every reaction is skipped and digraph stops at line 771
%       EXPECTED: the bond graph is built as the atom graph is; the option 0 works
%       LINES: 771
%
% Authors:
%     - COBRA Toolbox, feature 20260921-125236-sparse-bond-matrices
%     - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond (zero-bond reaction)
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

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

% (g) a reaction with no bonds (feature 20261012-093525-symmetric-iso-zero-bond, FR-005, SC-004):
% implicit-hydrogen ethanol transport plus water transport, whose single-atom molecules have no
% bonds. The build completes, the water atom transition is in the atom graph, the water
% reaction contributes no bond transition, and both decompositions hold.
implicitHDir = [fileDir filesep 'data' filesep 'rxn'];
zeroBondModel = struct();
zeroBondModel.mets = {'etoh[e]'; 'etoh[c]'; 'h2o[c]'; 'h2o[e]'};
zeroBondModel.rxns = {'ETOHt_implicitH'; 'H2Ot_implicitH'};
zeroBondModel.S = sparse([-1, 0; 1, 0; 0, -1; 0, 1]);
zeroBondModel.lb = [-1000; -1000];
zeroBondModel.ub = [1000; 1000];
zeroBondModel.c = [0; 0];
zeroBondModel.b = [0; 0; 0; 0];
zeroBondOut = cell(1, 12);
[zeroBondOut{:}] = buildAtomAndBondTransitionMultigraph(zeroBondModel, implicitHDir, options);
zeroBondATM = zeroBondOut{1};
zeroBondBTM = zeroBondOut{8};
assert(all(zeroBondOut{3}), 'FR-005: both reactions must be atom mapped.');
waterTransitions = strcmp(zeroBondATM.Edges.rxns, 'H2Ot_implicitH');
assert(nnz(waterTransitions) == 1, 'FR-005: the water reaction must contribute one atom transition.');
waterEnds = zeroBondATM.Edges.EndNodes(waterTransitions, :);
waterEndMets = zeroBondATM.Nodes.mets(findnode(zeroBondATM, waterEnds));
assert(isequal(sort(waterEndMets(:)), {'h2o[c]'; 'h2o[e]'}), ...
    'FR-005: the water atom transition must join the two water oxygens.');
assert(nnz(strcmp(zeroBondATM.Edges.rxns, 'ETOHt_implicitH')) == 3, ...
    'FR-005: the ethanol reaction must contribute three atom transitions.');
assert(~any(strcmp(zeroBondBTM.Edges.rxns, 'H2Ot_implicitH')), ...
    'FR-005: the water reaction must contribute no bond transition.');
assert(any(strcmp(zeroBondBTM.Edges.rxns, 'ETOHt_implicitH')), ...
    'FR-005: the ethanol reaction must contribute bond transitions.');
[atomResidual, bondResidual] = decompositionResiduals(zeroBondModel, zeroBondOut);
assert(atomResidual == 0 && bondResidual == 0, ...
    sprintf('FR-005: decomposition residuals %g (atoms) and %g (bonds) must be zero.', atomResidual, bondResidual));

% small RXN files written for the branches below go to temporary folders
noBonds = zeros(0, 3);
carbonOxide = @(name) makeMolecule(name, {'C', 'O'}, [1 2], [1 2 1]);
carbonOxides = @(a, b) {carbonOxide(a), carbonOxide(b)};
% a -> b -> c, with RXN files written in the folder toyDir
toyModel = struct('mets', {{'a[c]'; 'b[c]'; 'c[c]'}}, 'rxns', {{'R1'; 'R2'}}, ...
    'S', sparse([-1 0; 1 -1; 0 1]), 'lb', [-1000; -1000], 'ub', [1000; 1000], 'c', [0; 0], 'b', [0; 0; 0]);
toyDir = tempname;
mkdir(toyDir);
removeToyDir = onCleanup(@() rmdir(toyDir, 's'));
writeRxnFile(toyDir, 'R1', 'a[c] -> b[c]', 1, 1, carbonOxides('a[c]', 'b[c]'));
writeRxnFile(toyDir, 'R2', 'b[c] -> c[c]', 1, 1, carbonOxides('b[c]', 'c[c]'));

%% Default options: the checks run and both graphs are built
toyOut = cell(1, 12);
[toyOut{:}] = buildAtomAndBondTransitionMultigraph(toyModel, toyDir);
assert(numedges(toyOut{1}) == 4 && numedges(toyOut{8}) == 2, ...
    'Two reactions of two atoms and one bond have four atom and two bond transitions.');
assert(all(toyOut{2}) && all(toyOut{3}), 'All the metabolites and reactions must be atom mapped.');
[atomResidual, bondResidual] = decompositionResiduals(toyModel, toyOut);
assert(atomResidual == 0 && bondResidual == 0, 'Both decompositions must hold on the toy model.');
% an options structure without sanityChecks takes the same default
sameOut = cell(1, 12);
[sameOut{:}] = buildAtomAndBondTransitionMultigraph(toyModel, toyDir, struct('directed', 0));
assert(isequaln(sameOut{1}, toyOut{1}) && isequaln(sameOut{8}, toyOut{8}), ...
    'Unset options must take their defaults.');

%% Repeated metabolites or reactions are refused
repeatedMet = toyModel;
repeatedMet.mets{2} = 'a[c]';
assert(verifyCobraFunctionError('buildAtomAndBondTransitionMultigraph', 'inputs', {repeatedMet, toyDir}, ...
    'testMessage', 'duplicate metabolites'));
repeatedRxn = toyModel;
repeatedRxn.rxns{2} = 'R1';
assert(verifyCobraFunctionError('buildAtomAndBondTransitionMultigraph', 'inputs', {repeatedRxn, toyDir}, ...
    'testMessage', 'duplicate reactions'));

%% RXN files with compartments and a model without: the atom graph uses the model's names
plainModel = toyModel;
plainModel.mets = {'a'; 'b'; 'c'};
[plainATM, plainMets, plainRxns] = buildAtomAndBondTransitionMultigraph(plainModel, toyDir, ...
    struct('bondTransitionMultigraph', 0));
assert(all(ismember(plainATM.Nodes.mets, plainModel.mets)) && all(plainMets) && all(plainRxns), ...
    'The atoms must carry the metabolite names of the model, without compartments.');

%% Different names without compartments, here R1 starts with b, are left as they are
reversedDir = tempname;
mkdir(reversedDir);
removeReversedDir = onCleanup(@() rmdir(reversedDir, 's'));
writeRxnFile(reversedDir, 'R1', 'b -> a', 1, 1, carbonOxides('b', 'a'));
reversedModel = struct('mets', {{'a'; 'b'}}, 'rxns', {{'R1'}}, 'S', sparse([1; -1]), ...
    'lb', -1000, 'ub', 1000, 'c', 0, 'b', [0; 0]);
reversedATM = buildAtomAndBondTransitionMultigraph(reversedModel, reversedDir, struct('bondTransitionMultigraph', 0));
assert(numedges(reversedATM) == 2 && all(ismember(reversedATM.Nodes.mets, {'a'; 'b'})), ...
    'Metabolites without compartments must not be changed.');

%% A reaction without an atom mapping is reported as skipped in both graphs, the others are built
% zero transition numbers are not counted as transitions, so the edge tables stay full
skippedDir = tempname;
mkdir(skippedDir);
removeSkippedDir = onCleanup(@() rmdir(skippedDir, 's'));
writeRxnFile(skippedDir, 'R1', 'a[c] -> b[c]', 1, 1, carbonOxides('a[c]', 'b[c]'));
unmapped = @(name) makeMolecule(name, {'C', 'O'}, [0 0], [1 2 1]);
writeRxnFile(skippedDir, 'R2', 'b[c] -> c[c]', 1, 1, {unmapped('b[c]'), unmapped('c[c]')});
skippedOut = cell(1, 12);
consoleText = evalc('[skippedOut{:}] = buildAtomAndBondTransitionMultigraph(toyModel, skippedDir);');
assert(isequal(skippedOut{2}', [true true false]) && isequal(skippedOut{3}', [true false]), ...
    'Only the reaction with a mapping, and its metabolites, must be in the atom graph.');
assert(numedges(skippedOut{1}) == 2 && numedges(skippedOut{8}) == 1, ...
    'The mapped reaction must keep its two atom transitions and one bond transition.');
assert(contains(consoleText, 'R2.rxn could not be parsed for atom mappings and was skipped.') && ...
    contains(consoleText, 'R2.rxn could not be parsed for bond mappings and was skipped.'), ...
    'A skipped reaction must be reported for both graphs.');
assert(contains(consoleText, '3 metabolites should be atom mapped, but only 2 in the dATM:') && ...
    contains(consoleText, '2 reactions should be atom mapped, but only 1 in the dATM:'), ...
    'The metabolites and reactions left out of the atom graph must be reported.');

%% A molecule with other bonds in another RXN file is reported, and its new atom kept as it is
% b has one bond in R1 and two, to an atom that R1 does not have, in R2
inconsistentDir = tempname;
mkdir(inconsistentDir);
removeInconsistentDir = onCleanup(@() rmdir(inconsistentDir, 's'));
writeRxnFile(inconsistentDir, 'R1', 'a[c] -> b[c]', 1, 1, carbonOxides('a[c]', 'b[c]'));
threeAtoms = @(name) makeMolecule(name, {'C', 'O', 'N'}, [1 2 3], [1 2 1; 2 3 1]);
writeRxnFile(inconsistentDir, 'R2', 'b[c] -> c[c]', 1, 1, {threeAtoms('b[c]'), threeAtoms('c[c]')});
inconsistentOut = cell(1, 12);
consoleText = evalc('[inconsistentOut{:}] = buildAtomAndBondTransitionMultigraph(toyModel, inconsistentDir);');
% warnings captured from the console are wrapped at its width
assert(contains(regexprep(consoleText, '\s+', ' '), 'b[c] bond-graph node count (2) does not match its true bond count (1)'), ...
    'A metabolite with more bonds than in its first molecule block must raise a warning.');
assert(numedges(inconsistentOut{8}) == 3, 'R1 has one bond transition and R2 two.');

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

function writeRxnFile(folder, rxnId, formula, nSubstrates, nProducts, molecules)
% Write an MDL RXN file. molecules is a cell array of structs with fields name, elements,
% mapping (the atom transition numbers) and bonds (rows [head tail type]).
fid = fopen(fullfile(folder, [rxnId '.rxn']), 'w');
fprintf(fid, '$RXN\n%s\nTest fixture\n%s\n%3d%3d\n', rxnId, formula, nSubstrates, nProducts);
for i = 1:numel(molecules)
    molecule = molecules{i};
    fprintf(fid, '$MOL\n%s\n  fixture\n\n%3d%3d  0  0  0  0  0  0  0  0999 V2000\n', ...
        molecule.name, numel(molecule.elements), size(molecule.bonds, 1));
    for a = 1:numel(molecule.elements)
        fprintf(fid, '%10.4f%10.4f%10.4f %-3s 0  0  0  0  0  0  0  0  0%3d  0  0\n', 0, 0, 0, ...
            molecule.elements{a}, molecule.mapping(a));
    end
    for b = 1:size(molecule.bonds, 1)
        fprintf(fid, '%3d%3d%3d  0\n', molecule.bonds(b, :));
    end
    fprintf(fid, 'M  END\n');
end
fclose(fid);
end

function molecule = makeMolecule(name, elements, mapping, bonds)
% One molecule of a writeRxnFile fixture.
molecule = struct('name', name, 'elements', {elements}, 'mapping', mapping, 'bonds', bonds);
end
