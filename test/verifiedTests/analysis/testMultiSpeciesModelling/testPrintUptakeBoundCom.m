% The COBRAToolbox: testPrintUptakeBoundCom.m
%
% Purpose:
%     - printUptakeBoundCom prints, for a community model, the uptake bounds of the community
%       (EXcom) and of each organism (EXsp, and the host through [b]) for every community
%       metabolite whose uptake is allowed, and returns the printed matrix and the metabolite
%       labels. This test builds small joint models with createModel, derives infoCom and
%       indCom with getMultiSpeciesModelId, sets the bounds by hand and checks the returned
%       matrix and labels for: the defaults (community uptake only), SpFlag (organism uptake
%       shows a row), metFlag with metNames (a nested cell is unwrapped, a name longer than
%       30 characters is wrapped), a host model, the two-column EXcom layout (upper bounds of
%       separate uptake reactions), no shown row, and the two documented errors.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/printUptakeBoundCom.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built joint models (createModel), no solver.
%
% Coverage exemptions:
%     Line 37: reached only by a model without indCom; the call infoCom2indCom(model) fails
%     (defect below, not asserted).
%     Line 46: reached only by a model without infoCom, which then fails at line 62 (defect
%     below, not asserted).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Continuation lines of long names are printed as the literal text %30s in the
%         host layout
%       SEVERITY: cosmetic
%       TRIGGER: printUptakeBoundCom(model, true, true) on a model with a host whose
%         community metabolite name has more than 30 characters
%       OBSERVED: after the first line of the row, each continuation line reads '%30s'
%         (MATLAB R2025a): the format of line 121 starts with '%%', so the text argument is
%         not consumed; the layout without host (line 106) prints the remaining characters
%       EXPECTED: the remaining characters of the name, 30 per line
%       LINES: 121
%     - DEFECT: A model without indCom cannot be printed
%       SEVERITY: limitation
%       TRIGGER: printUptakeBoundCom(model) for a model with infoCom but without indCom
%       OBSERVED: "Undefined function 'infoCom2indCom' for input arguments of type
%         'struct'." (MATLAB R2025a): infoCom2indCom is a local function of
%         src/analysis/multiSpecies/SteadyCom/subroutines/SteadyComSubroutines.m and not on
%         the path; the documentation lists both fields, so the branch is a convenience that
%         never works
%       EXPECTED: indCom derived from infoCom, as the branch intends
%       LINES: 37
%     - DEFECT: A model without infoCom fails after the default abbreviations are built
%       SEVERITY: limitation
%       TRIGGER: printUptakeBoundCom(model) for a model with indCom but without infoCom
%       OBSERVED: 'Unrecognized field name "infoCom".' at line 62 (MATLAB R2025a) although
%         line 46 builds the default abbreviations Org1, Org2, ... for this case
%       EXPECTED: the bounds printed with the default abbreviations, from indCom alone
%       LINES: 46, 62
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintUptakeBoundCom'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system
prepareTest();

%% community model of two species with infoCom and indCom from getMultiSpeciesModelId

rxnList = {'Org1R1'; 'Org1TrA'; 'Org1TrB'; 'Org1IEX_A[u]tr'; 'Org1IEX_B[u]tr'; ...
    'Org2TrA'; 'Org2DM_A'; 'Org2IEX_A[u]tr'; 'EX_A[u]'; 'EX_B[u]'};
formulaList = {'Org1A[c] -> Org1B[c]'; 'Org1A[e] <=> Org1A[c]'; 'Org1B[c] -> Org1B[e]'; ...
    'A[u] <=> Org1A[e]'; 'B[u] <=> Org1B[e]'; 'Org2A[e] -> Org2A[c]'; 'Org2A[c] -> '; ...
    'A[u] <=> Org2A[e]'; 'A[u] <=> '; 'B[u] <=> '};
modelCom = createModel(rxnList, rxnList, formulaList, 'printLevel', 0);
[modelCom.infoCom, modelCom.indCom] = getMultiSpeciesModelId(modelCom, {'Org1'; 'Org2'});

% the community may take up A (lb < 0) but not B; Org1 may still take up B from [u]; the
% other reversible reactions keep the createModel default lower bound -1000
modelCom = changeRxnBounds(modelCom, {'EX_A[u]'; 'EX_B[u]'; 'Org1IEX_B[u]tr'}, [-10; 0; -5], 'l');

%% defaults: only metabolites with community uptake, labelled by their [u]-free identifier

[printMatrix, printMet] = printUptakeBoundCom(modelCom);
% columns Comm., Org1, Org2: the lower bounds of EX_A[u], Org1IEX_A[u]tr and Org2IEX_A[u]tr;
% B is not shown because its community uptake bound is 0
assert(isequal(printMatrix, [-10 -1000 -1000]));
assert(isequal(printMet, {'(1) A'}));

%% SpFlag: a metabolite taken up by an organism alone is shown as well

[printMatrix, printMet] = printUptakeBoundCom(modelCom, true);
% row B: no community uptake (0), Org1 takes it up (-5), Org2 has no exchange for it (0)
assert(isequal(printMatrix, [-10 -1000 -1000; 0 -5 0]));
assert(isequal(printMet, {'(1) A'; '(2) B'}));

%% metFlag: labels from metNames, a nested cell is unwrapped, a long name is wrapped

longName = 'a very long metabolite name that goes beyond thirty characters';
modelCom.metNames{findMetIDs(modelCom, 'A[u]')} = {longName};
[printMatrix, printMet] = printUptakeBoundCom(modelCom, true, true);
% the matrix is unchanged; the labels are the metabolite names with the compartment kept
assert(isequal(printMatrix, [-10 -1000 -1000; 0 -5 0]));
assert(isequal(printMet, {['(1) ' longName]; '(2) B[u]'}));

%% a model with a host adds a column for the uptake from the host compartment [b]

rxnListHost = [rxnList; {'HostIEX_A[u]tr'; 'HostTrA'; 'HostTrbB'; 'HostTrbA'; 'EX_B[b]'; 'EX_A[b]'}];
formulaListHost = [formulaList; {'A[u] <=> HostA[e]'; 'HostA[e] <=> HostA[c]'; ...
    'HostA[c] -> HostB[b]'; 'HostA[c] <=> HostA[b]'; 'HostB[b] <=> '; 'HostA[b] <=> '}];
modelHost = createModel(rxnListHost, rxnListHost, formulaListHost, 'printLevel', 0);
[modelHost.infoCom, modelHost.indCom] = getMultiSpeciesModelId(modelHost, {'Org1'; 'Org2'}, 'Host');
modelHost = changeRxnBounds(modelHost, {'EX_A[u]'; 'EX_B[u]'; 'Org1IEX_B[u]tr'; 'EX_A[b]'}, [-10; 0; -5; -3], 'l');
modelHost.metNames{findMetIDs(modelHost, 'A[u]')} = longName;
[printMatrix, printMet] = printUptakeBoundCom(modelHost, true, true);
% columns Comm., Org1, Org2, Host (from [u]), Host (from [b]); B is shown because the host
% takes it up from [b] (lb of EX_B[b] is the default -1000)
assert(isequal(printMatrix, [-10 -1000 -1000 -1000 -3; 0 -5 0 0 -1000]));
assert(isequal(printMet, {['(1) ' longName]; '(2) B[u]'}));

%% two-column EXcom: separate uptake reactions, shown when their upper bound is positive

% the first column holds the uptake reactions; the system exchanges stand in for them here
modelTwoCol = modelCom;
modelTwoCol.infoCom.EXcom = repmat(modelCom.infoCom.EXcom, 1, 2);
modelTwoCol.indCom.EXcom = repmat(modelCom.indCom.EXcom, 1, 2);
modelTwoCol = changeRxnBounds(modelTwoCol, {'EX_A[u]'; 'EX_B[u]'}, [0; 1000], 'u');
[printMatrix, printMet] = printUptakeBoundCom(modelTwoCol);
% only B has a positive upper bound; its community column holds that upper bound
assert(isequal(printMatrix, [1000 -5 0]));
assert(isequal(printMet, {'(2) B'}));

%% no uptake allowed anywhere: header only, empty matrix and labels

modelQuiet = changeRxnBounds(modelCom, 'EX_A[u]', 0, 'l');
[printMatrix, printMet] = printUptakeBoundCom(modelQuiet);
assert(isequal(size(printMatrix), [0 3]) && isequal(size(printMet), [0 1]));

%% documented errors: more than two EXcom columns, neither infoCom nor indCom

modelThreeCol = modelTwoCol;
modelThreeCol.infoCom.EXcom = repmat(modelCom.infoCom.EXcom, 1, 3);
assert(verifyCobraFunctionError('printUptakeBoundCom', 'inputs', {modelThreeCol}, ...
    'testMessage', 'infoCom.EXcom or indCom.EXcom should have at most two columns.'));
modelNoInfo = rmfield(modelCom, {'infoCom', 'indCom'});
assert(verifyCobraFunctionError('printUptakeBoundCom', 'inputs', {modelNoInfo}, ...
    'testMessage', 'model.indCom or model.infoCom must exist for printing bounds'));

% change the directory
cd(currentDir)
