% The COBRAToolbox: testConvertOldCouplingFormat.m
%
% Purpose:
%     - convertOldCouplingFormat moves old-style coupling constraints into the fields C, ctrs, d
%       and dsense and removes the legacy field A. Old style is either A with extra rows below S
%       (the extra rows are listed in mets, b and csense), or rows named slack_... inside S itself
%       with A of the same size. A model without A, or without S, is returned unchanged.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - The old-format inputs are derived from the loaded model (ecoli_core_model has no coupling
%       constraints): two coupling constraints that couple PGI and PFK to the biomass reaction
%       are appended to it as the help text describes.
%     - Reference values: none are needed; every expected value is derived from the input model
%       and the appended coupling rows.
%
% Function under test:
%     src/base/io/utilities/convertOldCouplingFormat.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertOldCouplingFormat'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% two coupling constraints, as coupleRxnList2Rxn would write them:
%     v(PGI) - 400 v(biomass) <= 0.01  and  v(PFK) + 400 v(biomass) >= -0.01
nRxns = numel(model.rxns);
nMets = numel(model.mets);
biomassIdx = find(model.c);
coupledIdx = [find(strcmp(model.rxns, 'PGI')), find(strcmp(model.rxns, 'PFK'))];
couplingMatrix = sparse([1, 2, 1, 2], [coupledIdx, biomassIdx, biomassIdx], [1, 1, -400, 400], 2, nRxns);
couplingIds = {'slack_PGI'; 'slack_PFK'};
couplingRhs = [0.01; -0.01];
couplingSense = ['L'; 'G'];
couplingFields = {'C', 'ctrs', 'd', 'dsense'};

%% a model without the legacy field A is returned unchanged

assert(isequal(convertOldCouplingFormat(model), model));
assert(isequal(convertOldCouplingFormat(model, 1), model));

%% A with coupling rows below S is converted into C, ctrs, d and dsense

% old format: A = [S; coupling rows] and mets, b and csense list the coupling rows; S is unchanged
oldModel = model;
oldModel.A = [model.S; couplingMatrix];
oldModel.mets = [model.mets; couplingIds];
oldModel.b = [model.b; couplingRhs];
oldModel.csense = [model.csense; couplingSense];
newModel = convertOldCouplingFormat(oldModel);

% the coupling rows are moved to the new fields (copies, so equality is exact)
assert(isequal(newModel.C, couplingMatrix));
assert(isequal(newModel.ctrs, couplingIds));
assert(isequal(newModel.d, couplingRhs));
assert(isequal(newModel.dsense, couplingSense));

% the coupling fields are consistent with each other and with the reactions
assert(isequal(size(newModel.C), [numel(newModel.ctrs), numel(newModel.rxns)]));
assert(numel(newModel.d) == numel(newModel.ctrs) && numel(newModel.dsense) == numel(newModel.ctrs));

% A is removed and mets, b and csense are cut back to S, so everything else equals the input
% model; in particular size(S) matches mets and rxns again
assert(~isfield(newModel, 'A'));
assert(isequal(rmfield(newModel, couplingFields), model));
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));
clear oldModel newModel

%% printLevel 1 announces the conversion with a warning

oldModel = model;
oldModel.A = [model.S; couplingMatrix];
oldModel.mets = [model.mets; couplingIds];
oldModel.b = [model.b; couplingRhs];
oldModel.csense = [model.csense; couplingSense];

% the warning is shown (not suppressed) and read back with lastwarn; the result is the same as
% with the default printLevel 0
lastwarn('');
newModel = convertOldCouplingFormat(oldModel, 1);
assert(startsWith(lastwarn, 'The inserted Model contains an old style coupling matrix (A).'));
assert(isequal(newModel, convertOldCouplingFormat(oldModel, 0)));
assert(isequal(rmfield(newModel, couplingFields), model));
assert(isequal(newModel.C, couplingMatrix) && isequal(newModel.ctrs, couplingIds));
clear oldModel newModel

%% slack rows inside S with A of the same size are moved out of S

% old format: the coupling rows are part of S, every metabolite-sized field has an entry for
% them, and A equals S
slackModel = model;
slackModel.S = [model.S; couplingMatrix];
slackModel.mets = [model.mets; couplingIds];
slackModel.b = [model.b; couplingRhs];
slackModel.csense = [model.csense; couplingSense];
slackModel.metNames = [model.metNames; couplingIds];
slackModel.metFormulas = [model.metFormulas; {''; ''}];
slackModel.A = slackModel.S;
newModel = convertOldCouplingFormat(slackModel);

% the slack rows are moved to the new fields (copies, so equality is exact)
assert(isequal(newModel.C, couplingMatrix));
assert(isequal(newModel.ctrs, couplingIds));
assert(isequal(newModel.d, couplingRhs));
assert(isequal(newModel.dsense, couplingSense));
assert(isequal(size(newModel.C), [numel(newModel.ctrs), numel(newModel.rxns)]));
assert(numel(newModel.d) == numel(newModel.ctrs) && numel(newModel.dsense) == numel(newModel.ctrs));

% the slack rows are removed from S and from every metabolite-sized field, no reaction is
% removed, and A is removed: the rest equals the input model
assert(~isfield(newModel, 'A'));
assert(isequal(rmfield(newModel, couplingFields), model));
assert(isequal(size(newModel.S), [nMets, nRxns]));
clear slackModel newModel

%% A of the same size as S without slack rows gives empty coupling fields

oldModel = model;
oldModel.A = model.S;
newModel = convertOldCouplingFormat(oldModel);

% there are no rows below S, so C has no row and ctrs, d and dsense are empty columns
assert(isequal(size(newModel.C), [0, nRxns]));
assert(isequal(size(newModel.ctrs), [0, 1]) && iscell(newModel.ctrs));
assert(isequal(size(newModel.d), [0, 1]));
assert(isequal(size(newModel.dsense), [0, 1]) && ischar(newModel.dsense));
assert(~isfield(newModel, 'A'));
assert(isequal(rmfield(newModel, couplingFields), model));
clear oldModel newModel

%% a model with A but without S is returned unchanged, without a warning

oldModel = rmfield(model, 'S');
oldModel.A = [model.S; couplingMatrix];
lastwarn('');
assert(isequal(convertOldCouplingFormat(oldModel, 1), oldModel));
assert(isempty(lastwarn));
clear oldModel

% change the directory
cd(currentDir)
