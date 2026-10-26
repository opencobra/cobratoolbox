% The COBRAToolbox: testGenerateFullRowRankFR.m
%
% Purpose:
%     - tests generateFullRowRankFR, which edits a model until the internal
%       forward/reverse half-stoichiometric matrix [F, R] has full row rank,
%       on hand-built fixtures (zero row, identical rows, sum dependency with
%       dead ends, irreducible dependency, opt-in general removal, full rank)
%       and, when available, on Recon3D, iDopaNeuroC and Recon3T
%
% Authors:
%     - Ronan Fleming, 2026

% no solver is required: the function uses rank factorisations only
prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% numerical tolerance for residuals of left-null witnesses
tol = 1e-9;
param = struct('printLevel', 0);

%% fixture sanity: confirm each fixture's starting [F, R] structure
% name, model, m, rank
fixtures = {'fullRank', fixtureFullRank(), 3, 3; ...
            'zeroRow', fixtureZeroRow(), 4, 3; ...
            'identicalPair', fixtureIdenticalPair(), 5, 4; ...
            'fiveGroup', fixtureFiveGroup(), 8, 4; ...
            'preexistingDuplicate', fixturePreexistingDuplicate(), 5, 4; ...
            'sumDependency', fixtureSumDependency(), 6, 5; ...
            'irreducible', fixtureIrreducible(), 6, 5; ...
            'irreducibleBackbone', fixtureIrreducibleBackbone(), 6, 5; ...
            'twoPass', fixtureTwoPass(), 7, 5};
for i = 1:size(fixtures, 1)
    fixture = fixtures{i, 2};
    [~, ~, FR] = frOf(fixture, fixture.SConsistentRxnBool);
    rankLUSOL = getRankLUSOL(FR, 0);
    rankFull = rank(full(FR));
    fprintf('%-22s m = %d, rank (LUSOL) = %d, rank (full) = %d\n', fixtures{i, 1}, size(FR, 1), rankLUSOL, rankFull);
    assert(size(FR, 1) == fixtures{i, 3});
    assert(rankLUSOL == fixtures{i, 4} && rankFull == fixtures{i, 4});
end
% structural facts the expectations below rely on
model = fixtureZeroRow();
[~, ~, FR] = frOf(model, model.SConsistentRxnBool);
assert(isequal(model.mets(~any(FR, 2)), {'X'}));
model = fixtureIdenticalPair();
[~, ~, FR] = frOf(model, model.SConsistentRxnBool);
assert(isequal(FR(4, :), FR(5, :)));
model = fixtureSumDependency();
[~, ~, FR] = frOf(model, model.SConsistentRxnBool);
y = zeros(6, 1);
y(strcmp(model.mets, 'P')) = 1;
y(ismember(model.mets, {'D1', 'D2', 'D3'})) = -1;
assert(norm(FR' * y, inf) == 0);
model = fixtureIrreducible();
[~, ~, FR] = frOf(model, model.SConsistentRxnBool);
y = zeros(6, 1);
y(ismember(model.mets, {'A', 'D'})) = 1;
y(ismember(model.mets, {'B', 'C'})) = -1;
assert(norm(FR' * y, inf) == 0);
[~, ia] = unique(FR, 'rows', 'stable');
assert(numel(ia) == 6);
N = model.S(:, model.SConsistentRxnBool);
assert(all(sum(N(1:4, :) ~= 0, 2) >= 2));

%% US1: zero row (FR-005)
model = fixtureZeroRow();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(report.fullRowRank && report.rankAfter == 3 && report.mAfter == 3);
assert(isequal({report.removedMets.met}', {'X'}) && strcmp(report.removedMets(1).reason, 'zeroRow'));
assert(isequal({report.removedRxns.rxn}', {'EX_X'}) && strcmp(report.removedRxns(1).reason, 'emptyColumn'));
assert(~report.removedRxns(1).internal);
assert(isempty(report.lumpedGroups) && isempty(report.nullVectors));
assertSetdiffAccounted(model, modelOut, report);

%% US1: identical pair, lumped (FR-006) and field preservation (R6)
model = fixtureIdenticalPair();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(report.fullRowRank && report.mAfter == 4);
assert(isscalar(report.lumpedGroups));
group = report.lumpedGroups(1);
assert(isequal(group.members, {'P'; 'Q'}) && strcmp(group.representative, 'P'));
assert(isequal(group.rxnsRewritten, {'r4'}));
assert(isequal(group.differenceVectors, {{'Q', 1; 'P', -1}}));
assert(isequal({report.removedMets.met}', {'Q'}) && strcmp(report.removedMets(1).reason, 'lumped'));
assert(isempty(report.removedRxns));
col = strcmp(modelOut.rxns, 'r4');
[metInd, ~, coef] = find(modelOut.S(:, col));
assert(isequal(sort(modelOut.mets(metInd)), {'A'; 'B'; 'P'}));
assert(isequal(full(coef(strcmp(modelOut.mets(metInd), 'A'))), -1) && isequal(full(coef(strcmp(modelOut.mets(metInd), 'P'))), -1));
assert(isequal(full(coef(strcmp(modelOut.mets(metInd), 'B'))), 1));
assertReactionFieldsPreserved(model, modelOut, 'r4');
assertSetdiffAccounted(model, modelOut, report);

%% US1: five-member identical group (FR-006)
model = fixtureFiveGroup();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(report.fullRowRank && report.mAfter == 4);
assert(isscalar(report.lumpedGroups));
group = report.lumpedGroups(1);
assert(isequal(group.members, {'G1'; 'G2'; 'G3'; 'G4'; 'G5'}) && strcmp(group.representative, 'G1'));
assert(isequal(group.rxnsRewritten, {'r4'; 'r5'}));
expectedVectors = arrayfun(@(i) {sprintf('G%d', i), 1; 'G1', -1}, (2:5)', 'UniformOutput', false);
assert(isequal(group.differenceVectors, expectedVectors));
assert(numel(report.removedMets) == 4 && all(strcmp({report.removedMets.reason}, 'lumped')));
assertReactionFieldsPreserved(model, modelOut, 'r4');
assertReactionFieldsPreserved(model, modelOut, 'r5');
assertSetdiffAccounted(model, modelOut, report);

%% US1: identical pair with remedy = 'removeRxns' (FR-006)
model = fixtureIdenticalPair();
[modelOut, report] = generateFullRowRankFR(model, struct('printLevel', 0, 'remedy', 'removeRxns'));
assertReportFields(report);
assert(report.fullRowRank && report.mAfter == 3);
assert(isequal({report.removedRxns.rxn}', {'r4'}) && strcmp(report.removedRxns(1).reason, 'identicalRowGroup'));
assert(isscalar(report.lumpedGroups) && isempty(report.lumpedGroups(1).representative));
assert(isempty(report.lumpedGroups(1).rxnsRewritten));
assert(isequal(sort({report.removedMets.met}'), {'P'; 'Q'}) && all(strcmp({report.removedMets.reason}, 'orphaned')));
assertSetdiffAccounted(model, modelOut, report);

%% US1: a duplicate that exists before lumping is not removed (FR-007, R5a)
model = fixturePreexistingDuplicate();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(report.fullRowRank);
assert(~any(strcmp({report.removedRxns.reason}, 'duplicateAfterLump')));
assert(all(ismember({'r4'; 'r5'}, modelOut.rxns)));
assert(isequal(report.lumpedGroups(1).rxnsRewritten, {'r4'; 'r5'}));
assertSetdiffAccounted(model, modelOut, report);

%% US2: sum dependency resolved through dead ends (FR-008, FR-009, FR-011)
model = fixtureSumDependency();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(isscalar(report.nullVectors));
witness = report.nullVectors(1);
assert(isequal(sort(witness.support), {'D1'; 'D2'; 'D3'; 'P'}));
assertProportional(witness, {'P', 'D1', 'D2', 'D3'}, [1, -1, -1, -1]);
assert(witness.residual <= tol);
assert(strcmp(witness.remedy, 'deadEndRemoval') && isequal(sort(witness.rxnsRemoved), {'r1'; 'r2'; 'r3'}));
assert(isequal(sort({report.removedRxns.rxn}'), {'r1'; 'r2'; 'r3'}) && all(strcmp({report.removedRxns.reason}, 'deadEnd')));
assert(isequal(sort({report.removedMets.met}'), {'D1'; 'D2'; 'D3'; 'P'}));
assert(all(strcmp({report.removedMets.reason}, 'orphaned')) && all([report.removedMets.iteration] == 1));
assert(~any(ismember({'g1', 'g2'}, modelOut.genes)) && ismember('g3', modelOut.genes));
assert(isequal(modelOut.S(:, strcmp(modelOut.rxns, 'ra')), model.S(ismember(model.mets, modelOut.mets), strcmp(model.rxns, 'ra'))));
assert(report.fullRowRank && report.mAfter == 2);
assert(isempty(report.flaggedForReview));
assertSetdiffAccounted(model, modelOut, report);

%% US3: irreducible dependency stops without a guessed edit (FR-010)
model = fixtureIrreducible();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(~report.fullRowRank && strcmp(report.stopReason, 'irreducibleDependency'));
assert(isscalar(report.nullVectors));
witness = report.nullVectors(1);
assert(isequal(sort(witness.support), {'A'; 'B'; 'C'; 'D'}));
assertProportional(witness, {'A', 'B', 'C', 'D'}, [1, -1, -1, 1]);
assert(witness.residual <= tol && strcmp(witness.remedy, 'none'));
assert(isempty(report.removedMets) && isempty(report.removedRxns) && isempty(report.lumpedGroups));
assert(isequal(modelOut, model));
assert(~report.generalRemovalUsed);

%% US3: iteration limit (FR-004)
model = fixtureTwoPass();
[modelOut, report] = generateFullRowRankFR(model, struct('printLevel', 0, 'maxIterations', 1));
assertReportFields(report);
assert(strcmp(report.stopReason, 'maxIterations') && ~report.fullRowRank && report.iterations == 1);
assert(isequal({report.removedMets.met}', {'X'}) && strcmp(report.removedMets(1).reason, 'zeroRow'));
assert(isequal({report.removedRxns.rxn}', {'EX_X'}) && strcmp(report.removedRxns(1).reason, 'emptyColumn'));
assert(all(ismember({'r1'; 'r2'; 'r3'}, modelOut.rxns)));
[~, report] = generateFullRowRankFR(model, param);
assert(report.fullRowRank && isempty(report.stopReason));

%% US3: error paths
assert(verifyCobraFunctionError('generateFullRowRankFR', 'inputs', {fixtureFullRank(), struct('remedy', 'bogus')}, ...
    'testMessage', 'param.remedy must be ''lump'' or ''removeRxns''.'));
assert(verifyCobraFunctionError('generateFullRowRankFR', 'inputs', {fixtureFullRank(), struct('irreducibleRemedy', 'bogus')}, ...
    'testMessage', 'param.irreducibleRemedy must be ''stop'' or ''removeMetabolites''.'));
assert(verifyCobraFunctionError('generateFullRowRankFR', 'inputs', {fixtureFullRank(), struct('rxnBool', true(2, 1))}, ...
    'testMessage', 'param.rxnBool must have one entry per reaction (3).'));

%% US5: opt-in general removal guarantees full row rank (FR-018 to FR-021)
generalParam = struct('printLevel', 0, 'irreducibleRemedy', 'removeMetabolites');
model = fixtureIrreducibleBackbone();
[modelOut, report] = generateFullRowRankFR(model, generalParam);
assertReportFields(report);
assert(report.fullRowRank && report.generalRemovalUsed && isempty(report.stopReason));
assert(numel(report.nullVectors) == 2);
assert(strcmp(report.nullVectors(1).remedy, 'generalRemoval') && strcmp(report.nullVectors(1).chosenMet, 'A'));
assert(isequal(sort(report.nullVectors(1).rxnsRemoved), {'r1'; 'r3'}));
assert(isequal(sort(report.nullVectors(2).support), {'B'; 'C'; 'D'}) && strcmp(report.nullVectors(2).remedy, 'deadEndRemoval'));
assert(isequal(sort(report.nullVectors(2).rxnsRemoved), {'r2'; 'r4'}));
assert(isequal(reasonOf(report.removedMets, 'met', 'generalRemoval'), {'A'}));
assert(isequal(sort(reasonOf(report.removedMets, 'met', 'orphaned')), {'B'; 'C'; 'D'}));
assert(isequal(sort(reasonOf(report.removedRxns, 'rxn', 'generalRemoval')), {'r1'; 'r3'}));
assert(isequal(sort(reasonOf(report.removedRxns, 'rxn', 'deadEnd')), {'r2'; 'r4'}));
assert(all([report.removedRxns.internal]));
assert(isequal(modelOut.mets, {'P'; 'Q'}) && isequal(modelOut.rxns, {'r5'; 'r6'}));
assert(isequal(modelOut.S, model.S(ismember(model.mets, {'P', 'Q'}), ismember(model.rxns, {'r5', 'r6'}))));
assertSetdiffAccounted(model, modelOut, report);

%% US5: choice rule with external reactions (FR-019, FR-020)
% EX_A makes A the most expensive species, so B is chosen (fewest reactions, then model order)
model = addExchanges(fixtureIrreducibleBackbone(), {'A'});
[modelOut, report] = generateFullRowRankFR(model, generalParam);
assert(report.fullRowRank && strcmp(report.nullVectors(1).chosenMet, 'B'));
assert(isequal(sort(report.nullVectors(1).rxnsRemoved), {'r1'; 'r4'}));
assertSetdiffAccounted(model, modelOut, report);
% exchanges on every support species: A is chosen and its exchange is removed as external
model = addExchanges(fixtureIrreducibleBackbone(), {'A', 'B', 'C', 'D'});
[modelOut, report] = generateFullRowRankFR(model, generalParam);
assert(report.fullRowRank && strcmp(report.nullVectors(1).chosenMet, 'A'));
assert(isequal(sort(report.nullVectors(1).rxnsRemoved), {'EX_A'; 'r1'; 'r3'}));
removedEx = report.removedRxns(strcmp({report.removedRxns.rxn}, 'EX_A'));
assert(strcmp(removedEx.reason, 'generalRemoval') && ~removedEx.internal);
assert(isequal(sort(reasonOf(report.removedRxns, 'rxn', 'emptyColumn')), {'EX_B'; 'EX_C'; 'EX_D'}));
assert(isequal(sort(reasonOf(report.removedMets, 'met', 'zeroRow')), {'B'; 'C'; 'D'}));
assert(isequal(modelOut.mets, {'P'; 'Q'}));
assertSetdiffAccounted(model, modelOut, report);

%% US5: the option is inert when the specific remedies suffice, and off by default
builders = {@fixtureZeroRow, @fixtureIdenticalPair, @fixtureFiveGroup, @fixturePreexistingDuplicate, @fixtureSumDependency, @fixtureTwoPass};
for i = 1:numel(builders)
    model = builders{i}();
    [modelDefault, reportDefault] = generateFullRowRankFR(model, param);
    [modelGeneral, reportGeneral] = generateFullRowRankFR(model, generalParam);
    assert(~reportGeneral.generalRemovalUsed);
    assert(isequal(modelDefault, modelGeneral) && isequal(reportDefault, reportGeneral));
end
[~, report] = generateFullRowRankFR(fixtureIrreducible());
assert(strcmp(report.stopReason, 'irreducibleDependency'));

%% US4: a full-rank model is returned unchanged (SC-006)
model = fixtureFullRank();
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(isequal(modelOut, model));
assert(report.fullRowRank && report.iterations == 1 && isempty(report.stopReason));
assert(report.rankBefore == 3 && report.rankAfter == 3 && report.mBefore == 3 && report.mAfter == 3);
assert(isempty(report.removedMets) && isempty(report.removedRxns) && isempty(report.removedCtrs));
assert(isempty(report.lumpedGroups) && isempty(report.nullVectors) && isempty(report.flaggedForReview));
assert(strcmp(report.rxnBoolSource, 'SConsistentRxnBool'));
% the findSExRxnInd path adds no field to the returned model
model = rmfield(fixtureFullRank(), 'SConsistentRxnBool');
[modelOut, report] = generateFullRowRankFR(model, param);
assert(strcmp(report.rxnBoolSource, 'findSExRxnInd') && report.fullRowRank);
assert(isequal(modelOut, model));

%% US4: determinism and silence at printLevel 0 on every fixture (SC-005, SC-007)
builders = {@fixtureFullRank, @fixtureZeroRow, @fixtureIdenticalPair, @fixtureFiveGroup, @fixturePreexistingDuplicate, ...
            @fixtureSumDependency, @fixtureIrreducible, @fixtureTwoPass};
for i = 1:numel(builders)
    model = builders{i}();
    [modelOut1, report1] = generateFullRowRankFR(model, param);
    [modelOut2, report2] = generateFullRowRankFR(model, param);
    assertReportFields(report1);
    assert(isequal(modelOut1, modelOut2) && isequal(report1, report2));
    printedText = captureConsoleText(@() generateFullRowRankFR(model, param));
    assert(isempty(printedText), 'generateFullRowRankFR printed output at printLevel 0');
end

%% Large models: in-repo Recon3D (SC-002b, runs in CI)
model = getDistributedModel('Recon3DModel_301_xomics_input.mat');
[modelOut, report] = generateFullRowRankFR(model, param);
assertReportFields(report);
assert(report.mBefore == 5835 && report.rankBefore == 5826);
expectedGroups = {{'HC00004[e]'; 'HC00006[e]'; 'HC00007[e]'; 'HC00008[e]'}, {'malcoa[e]'; 'arachcoa[e]'}, ...
                  {'CE5787[e]'; 'CE5791[e]'}, {'CE5868[e]'; 'CE5869[e]'}, {'cdpea[e]'; '12dgr120[e]'}, {'M01820[e]'; 'M00510[e]'}};
assertRecon3Groups(report, expectedGroups);
assertRecon3DeadEnds(report, tol);
assert(report.fullRowRank && report.mAfter == 5812);
assertSetdiffAccounted(model, modelOut, report);
[~, reportGeneral] = generateFullRowRankFR(model, generalParam);
assert(~reportGeneral.generalRemovalUsed && isequal(reportGeneral, report));

%% Large models: iDopaNeuroC (SC-003; skipped when the papers submodule is absent)
iDopaFile = fullfile(fileparts(which('initCobraToolbox')), 'papers', '2023_iDopaNeuro', 'models', 'iDopaNeuroC.mat');
if exist(iDopaFile, 'file')
    loaded = load(iDopaFile);
    model = loaded.iDopaNeuroC;
    [modelOut, report] = generateFullRowRankFR(model, param);
    assertReportFields(report);
    assert(report.mBefore == 1244 && report.rankBefore == 1243);
    assert(isscalar(report.lumpedGroups));
    assert(isequal(report.lumpedGroups(1).members, {'dcholcoa[x]'; 'ppcoa[x]'}));
    assert(strcmp(report.lumpedGroups(1).representative, 'dcholcoa[x]'));
    assert(isequal(sort(report.lumpedGroups(1).rxnsRewritten), sort({'r0698'; 'RE1836X'})));
    assertReactionFieldsPreserved(model, modelOut, 'r0698');
    assert(report.fullRowRank && report.mAfter == 1243);
    assertSetdiffAccounted(model, modelOut, report);
else
    fprintf('testGenerateFullRowRankFR: skipping iDopaNeuroC (not found: %s)\n', iDopaFile);
end

%% Large models: Recon3T (SC-002; skipped when the variationalKinetics data folder is absent)
recon3TFile = fullfile(getenv('HOME'), 'drive', 'sbgCloud', 'projects', 'variationalKinetics', 'data', 'Recon3T', ...
    'Recon3DModel_301_xomics_input_VK_withL.mat');
if exist(recon3TFile, 'file')
    loaded = load(recon3TFile);
    model = loaded.model;
    [modelOut, report] = generateFullRowRankFR(model, param);
    assertReportFields(report);
    assert(report.mBefore == 5824 && report.rankBefore == 5809);
    expectedZeroRows = {'idl_hs[e]'; 'M02560[e]'; 'M02561[e]'; 'M02909[e]'; 'protein[c]'};
    firstPass = [report.removedMets.iteration] == 1;
    assert(isequal(sort({report.removedMets(firstPass).met}'), sort(expectedZeroRows)));
    assert(all(strcmp({report.removedMets(firstPass).reason}, 'zeroRow')));
    expectedGroups{1} = {'HC00004[e]'; 'HC00006[e]'; 'HC00007[e]'; 'HC00008[e]'; 'HC00009[e]'};
    assertRecon3Groups(report, expectedGroups);
    assert(nnz(strcmp({report.removedMets.reason}, 'lumped')) == 9);
    assertRecon3DeadEnds(report, tol);
    assert(report.fullRowRank && report.mAfter == 5795);
    assertSetdiffAccounted(model, modelOut, report);
else
    fprintf('testGenerateFullRowRankFR: skipping Recon3T (not found: %s)\n', recon3TFile);
end

% change the directory back
cd(currentDir);

%% local functions

function [F, R, FR] = frOf(model, rxnBool)
% forward and reverse half-stoichiometric matrices of the internal columns
N = model.S(:, rxnBool);
F = max(-N, 0);
R = max(N, 0);
FR = [F, R];
end

function model = makeModel(mets, rxns, S, internalBool, grRules)
% assemble a small COBRA model with legacy char subSystems entries
nMets = numel(mets);
nRxns = numel(rxns);
model.S = sparse(S);
model.mets = mets(:);
model.metNames = mets(:);
model.rxns = rxns(:);
model.rxnNames = strcat('name_', rxns(:));
model.lb = -1000 * ones(nRxns, 1);
model.ub = 1000 * ones(nRxns, 1);
model.c = zeros(nRxns, 1);
model.b = zeros(nMets, 1);
model.csense = repmat('E', nMets, 1);
model.osenseStr = 'max';
model.subSystems = strcat('subsystem_', rxns(:));
model.genes = unique(grRules(~cellfun(@isempty, grRules)));
model.genes = model.genes(:);
model.grRules = grRules(:);
model.rules = cell(nRxns, 1);
for j = 1:nRxns
    if isempty(grRules{j})
        model.rules{j} = '';
    else
        model.rules{j} = sprintf('x(%d)', find(strcmp(model.genes, grRules{j})));
    end
end
model.SConsistentRxnBool = logical(internalBool(:));
end

function model = addExchanges(model, mets)
% append one external exchange reaction per metabolite
for k = 1:numel(mets)
    column = zeros(numel(model.mets), 1);
    column(strcmp(model.mets, mets{k})) = -1;
    model.S = [model.S, sparse(column)];
    model.rxns{end + 1, 1} = ['EX_' mets{k}];
    model.rxnNames{end + 1, 1} = ['name_EX_' mets{k}];
    model.lb(end + 1, 1) = -1000;
    model.ub(end + 1, 1) = 1000;
    model.c(end + 1, 1) = 0;
    model.subSystems{end + 1, 1} = 'exchange';
    model.grRules{end + 1, 1} = '';
    model.rules{end + 1, 1} = '';
    model.SConsistentRxnBool(end + 1, 1) = false;
end
end

function model = fixtureFullRank()
% A -> B -> C -> A
S = [-1  0  1;
      1 -1  0;
      0  1 -1];
model = makeModel({'A'; 'B'; 'C'}, {'r1'; 'r2'; 'r3'}, S, true(3, 1), {'g1'; 'g2'; ''});
end

function model = fixtureZeroRow()
% full-rank cycle plus X, which occurs only in the exchange EX_X
model = fixtureFullRank();
model.S = [model.S; sparse(1, 3)];
model.mets{end + 1, 1} = 'X';
model.metNames{end + 1, 1} = 'X';
model.b(end + 1, 1) = 0;
model.csense(end + 1, 1) = 'E';
model = addExchanges(model, {'X'});
end

function model = fixtureIdenticalPair()
% full-rank cycle plus r4: A + P + Q -> B, so P and Q have identical rows
S = [-1  0  1 -1;
      1 -1  0  1;
      0  1 -1  0;
      0  0  0 -1;
      0  0  0 -1];
model = makeModel({'A'; 'B'; 'C'; 'P'; 'Q'}, {'r1'; 'r2'; 'r3'; 'r4'}, S, true(4, 1), {'g1'; 'g2'; ''; 'g4'});
end

function model = fixtureFiveGroup()
% full-rank cycle plus r4: A + G1..G5 -> B and r5: B + G1..G5 -> C
S = [-1  0  1 -1  0;
      1 -1  0  1 -1;
      0  1 -1  0  1;
      repmat([0 0 0 -1 -1], 5, 1)];
mets = [{'A'; 'B'; 'C'}; {'G1'; 'G2'; 'G3'; 'G4'; 'G5'}];
model = makeModel(mets, {'r1'; 'r2'; 'r3'; 'r4'; 'r5'}, S, true(5, 1), {'g1'; 'g2'; ''; 'g4'; 'g5'});
end

function model = fixturePreexistingDuplicate()
% identical pair plus r5 = 2 * r4, a scalar multiple present before lumping
S = [-1  0  1 -1 -2;
      1 -1  0  1  2;
      0  1 -1  0  0;
      0  0  0 -1 -2;
      0  0  0 -1 -2];
model = makeModel({'A'; 'B'; 'C'; 'P'; 'Q'}, {'r1'; 'r2'; 'r3'; 'r4'; 'r5'}, S, true(5, 1), {'g1'; 'g2'; ''; 'g4'; 'g5'});
end

function model = fixtureSumDependency()
% ra: A -> B, rb: B -> A, ri: A -> P + Di; P occurs only in r1..r3 and each Di only in ri
S = [-1  1 -1 -1 -1;
      1 -1  0  0  0;
      0  0  1  1  1;
      0  0  1  0  0;
      0  0  0  1  0;
      0  0  0  0  1];
model = makeModel({'A'; 'B'; 'P'; 'D1'; 'D2'; 'D3'}, {'ra'; 'rb'; 'r1'; 'r2'; 'r3'}, S, true(5, 1), {'g3'; ''; 'g1'; 'g1'; 'g2'});
end

function model = fixtureIrreducible()
% r1: A + B -> P, r2: C + D -> P, r3: A + C -> Q, r4: B + D -> Q
S = [-1  0 -1  0;
     -1  0  0 -1;
      0 -1 -1  0;
      0 -1  0 -1;
      1  1  0  0;
      0  0  1  1];
model = makeModel({'A'; 'B'; 'C'; 'D'; 'P'; 'Q'}, {'r1'; 'r2'; 'r3'; 'r4'}, S, true(4, 1), {'g1'; 'g2'; 'g3'; 'g4'});
end

function model = fixtureIrreducibleBackbone()
% irreducible fixture plus the backbone r5: P -> Q and r6: Q -> P
base = fixtureIrreducible();
S = [full(base.S), [0 0 0 0 -1 1]', [0 0 0 0 1 -1]'];
model = makeModel(base.mets, [base.rxns; {'r5'; 'r6'}], S, true(6, 1), [base.grRules; {''; ''}]);
end

function model = fixtureTwoPass()
% sum dependency plus a zero row X (exchange only): needs a zero-row pass, then a dead-end pass
model = fixtureSumDependency();
model.S = [model.S; sparse(1, size(model.S, 2))];
model.mets{end + 1, 1} = 'X';
model.metNames{end + 1, 1} = 'X';
model.b(end + 1, 1) = 0;
model.csense(end + 1, 1) = 'E';
model = addExchanges(model, {'X'});
end

function assertReportFields(report)
% every report field of data-model.md is present
requiredFields = {'mBefore', 'nBefore', 'mAfter', 'nAfter', 'rankBefore', 'rankAfter', 'rankMethod', 'rankLog', ...
                  'rxnBoolSource', 'fullRowRank', 'removedMets', 'removedRxns', 'removedCtrs', 'lumpedGroups', ...
                  'nullVectors', 'flaggedForReview', 'generalRemovalUsed', 'iterations', 'stopReason'};
assert(all(isfield(report, requiredFields)));
assert(all(isfield(report.removedMets, {'met', 'iteration', 'reason'})));
assert(all(isfield(report.removedRxns, {'rxn', 'iteration', 'reason', 'internal'})));
assert(all(isfield(report.lumpedGroups, {'members', 'representative', 'rxnsRewritten', 'differenceVectors', 'iteration'})));
assert(all(isfield(report.nullVectors, {'iteration', 'support', 'coefficients', 'residual', 'remedy', 'chosenMet', 'rxnsRemoved'})));
assert(report.fullRowRank == (report.rankAfter == report.mAfter));
end

function assertSetdiffAccounted(model, modelOut, report)
% every removed metabolite and reaction is in the report exactly once (contract 5a)
removedMets = setdiff(model.mets, modelOut.mets);
removedRxns = setdiff(model.rxns, modelOut.rxns);
reportedMets = {report.removedMets.met};
reportedRxns = {report.removedRxns.rxn};
assert(isequal(sort(removedMets(:)), sort(reportedMets(:))));
assert(isequal(sort(removedRxns(:)), sort(reportedRxns(:))));
end

function assertReactionFieldsPreserved(model, modelOut, rxnId)
% every reaction-indexed field of a rewritten reaction keeps its value, except S;
% grRules is compared up to whitespace (addReaction normalises it)
nRxns = numel(model.rxns);
j = strcmp(model.rxns, rxnId);
k = strcmp(modelOut.rxns, rxnId);
fields = fieldnames(model);
for f = 1:numel(fields)
    value = model.(fields{f});
    if strcmp(fields{f}, 'S') || size(value, 1) ~= nRxns || ~isfield(modelOut, fields{f})
        continue
    end
    before = value(j, :);
    after = modelOut.(fields{f})(k, :);
    if strcmp(fields{f}, 'grRules')
        before = {regexprep(before{1}, '\s', '')};
        after = {regexprep(after{1}, '\s', '')};
    end
    assert(isequal(before, after), sprintf('field %s of %s changed', fields{f}, rxnId));
end
end

function assertProportional(witness, mets, coefficients)
% the witness coefficients are proportional to the expected ones
[~, order] = ismember(mets, witness.support);
y = witness.coefficients(order);
assert(norm(y(:) / y(1) - coefficients(:) / coefficients(1), inf) < 1e-12);
end

function names = reasonOf(list, field, reason)
% names in a report list that carry a given reason
names = {list(strcmp({list.reason}, reason)).(field)}';
end

function assertRecon3Groups(report, expectedGroups)
% the six identical-row groups of Recon3D/Recon3T, each with its first member as representative
assert(numel(report.lumpedGroups) == numel(expectedGroups));
for g = 1:numel(expectedGroups)
    found = cellfun(@(members) isequal(sort(members), sort(expectedGroups{g})), {report.lumpedGroups.members});
    assert(nnz(found) == 1, sprintf('identical-row group of %s not reported', expectedGroups{g}{1}));
    assert(strcmp(report.lumpedGroups(found).representative, report.lumpedGroups(found).members{1}));
end
end

function assertRecon3DeadEnds(report, tol)
% the pa_hs[e] sum dependency, resolved by removing the 14 phospholipase-D reactions
expectedRxns = sort({'ARACHETH'; 'DIDECAETH'; 'DIHOLINETH'; 'DOCOHEXETHc'; 'DOCTETETH'; 'HEPDECETH'; 'HEXDECEETH'; ...
                     'OLEETH'; 'PELINETH'; 'PENDECAETH'; 'PEPALM'; 'STEETH'; 'TETDECAETH'; 'TRIDECETH'});
assert(isscalar(report.nullVectors));
assert(numel(report.nullVectors(1).support) == 15 && report.nullVectors(1).residual <= tol);
assert(ismember('pa_hs[e]', report.nullVectors(1).support));
assert(isequal(sort(reasonOf(report.removedRxns, 'rxn', 'deadEnd')), expectedRxns));
flagged = arrayfun(@(f) strjoin(sort(f.rxns), '/'), report.flaggedForReview, 'UniformOutput', false);
assert(isequal(sort(flagged(:)), sort({'DIDECAETH/TETDECAETH'; 'HEPDECETH/PENDECAETH'})));
substrates = sort({report.flaggedForReview.sharedSubstrate}');
assert(isequal(substrates, {'pe12_hs[e]'; 'pe15_hs[e]'}));
end

function printedText = captureConsoleText(functionHandle)
% capture console output with diary (not evalc), so that warnings still reach the
% console; the previous diary file and state are restored afterwards
previousDiaryFile = get(0, 'DiaryFile');
previousDiaryState = get(0, 'Diary');
diary('off');
captureFile = [tempname '.txt'];
diary(captureFile);
functionHandle();
diary('off');
set(0, 'DiaryFile', previousDiaryFile);
if strcmp(previousDiaryState, 'on')
    diary('on');
end
printedText = fileread(captureFile);
delete(captureFile);
% expected warnings are not output of the function itself: the addReaction warning when
% a reaction is rewritten, and the once-per-session getRankLUSOL fallback warning
printedText = removeExpectedWarnings(printedText, ...
    {'Reaction with the same name already exists in the model, updating the reaction', ...
     'getRankLUSOL: LUSOL unavailable'});
end

function text = removeExpectedWarnings(text, messages)
% removes each expected warning in full, in the form matlab -batch writes it (as on CI:
% "[Warning: ...]" wrapped at about 80 columns, each bracket followed by a backspace
% character, then a bracketed "[> In ...]" backtrace) and in the desktop form
% ("Warning: ..." then "> In ..." / "In ..." backtrace lines); any other text is kept
for i = 1:numel(messages)
    message = strrep(regexptranslate('escape', messages{i}), ' ', '\s+');
    text = regexprep(text, ['\[\x08?Warning: ' message '[^\]]*\]\x08?\s*(\[\x08?> In [^\]]*\]\x08?\s*)?'], '');
    text = regexprep(text, ['Warning: ' message '[^\n]*\n?(\s*(> )?In [^\n]*\(line \d+\)[^\n]*\n?)*'], '');
end
text = strtrim(text);
end
