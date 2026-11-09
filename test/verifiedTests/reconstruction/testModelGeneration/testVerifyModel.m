% The COBRAToolbox: testVerifyModel.m
%
% Purpose:
%     - Tests the Model Verification function
%
% Function under test:
%     src/reconstruction/modelGeneration/modelVerification/verifyModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation: ecoli_core_model and small hand-built models, an LP solver.
%
% Coverage exemptions:
%     None apart from the lines of the defects below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the fields reported as problematic are the valid ones
%       SEVERITY: wrong-result
%       TRIGGER: verifyModel(model, 'fluxConsistency', true) on a model that lacks one of S, lb, ub, c
%       OBSERVED: checkFields returns true for a VALID field, and that vector selects the entries of
%         results.consistency.problematicFields, so the valid fields are listed and the missing one is not
%       EXPECTED: the missing or inconsistent fields are listed
%       LINES: 188-190
%     - DEFECT: every reaction counts as imbalanced in a mass balance without charges
%       SEVERITY: wrong-result
%       TRIGGER: verifyModel(model, 'massBalance', true) on a model without metCharges
%       OBSERVED: the charges are set to NaN, a NaN charge imbalance flags the reaction, so that
%         results.massBalance.imBalancedRxnBool is true for mass balanced reactions as well
%       EXPECTED: imBalancedRxnBool reflects the elements when the charges are not known
%       LINES: 158
%     - DEFECT: a consistent model fails the simple check of flux consistency
%       SEVERITY: wrong-result
%       TRIGGER: verifyModel(model, 'simpleCheck', true, 'fluxConsistency', true)
%       OBSERVED: the test is ~(abs(mins) > 1e-12) | (abs(maxs) > 1e-12), which is true for a reaction
%         that can carry flux, so results is not empty and false is returned
%       EXPECTED: true when every reaction can carry flux
%       LINES: 195
%     - DEFECT: the report of stoichiometric consistency stops with an error
%       SEVERITY: error
%       TRIGGER: verifyModel(model, 'stoichiometricConsistency', true) without 'simpleCheck', or with
%         'simpleCheck' on a stoichiometrically inconsistent model
%       OBSERVED: line 224 reads the misspelled, undefined variable ununknownSConsistencyRxnBool
%       EXPECTED: the booleans of the consistency test are returned in results.stoichiometricConsistency
%       LINES: 218-225
%
% Authors:
%     - Original test, COBRA Toolbox contributors.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVerifyModel'));
cd(fileDir);

% declare the requirements of this test: an LP solver for the flux consistency check
solvers = prepareTest('needsLP', true);

model = getDistributedModel('ecoli_core_model.mat');

% test whether the correct "invalid" subSystem is found. Note:
% modelSub.subSystems(20) = {'blubb'} (paren-indexing) previously used here
% keeps position 20 as the plain char 'blubb', which is a VALID legacy
% entry -- it never actually exercised the malformed-content path; use
% curly-brace assignment of a non-char, non-cell value instead (FR-006,
% research.md R2).
modelSub = model;
modelSub.subSystems{20} = 5;
subSystemsBefore = modelSub.subSystems;

res = verifyModel(modelSub,'silentCheck',true);

assert(~isempty(res))
assert(isfield(res,'Errors') && isfield(res.Errors,'propertiesNotMatched') && ...
    isfield(res.Errors.propertiesNotMatched,'subSystems'), ...
    'verifyModel did not report the malformed subSystems entry.');
assert(isequal(res.Errors.propertiesNotMatched.subSystems, sprintf('Field does not match the required properties at the following positions: \n            20')));
assert(isequal(modelSub.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a validly flat-char subSystems field reports no error (FR-006, SC-004)
subSystemsBefore = model.subSystems;
resFlat = verifyModel(model,'silentCheck',true);
assert(~(isfield(resFlat,'Errors') && isfield(resFlat.Errors,'propertiesNotMatched') && ...
    isfield(resFlat.Errors.propertiesNotMatched,'subSystems')), ...
    'verifyModel false-flagged a validly flat-char subSystems field.');
assert(isequal(model.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a validly nested-cell subSystems field (multi-subsystem
% reactions) reports no error (FR-006, SC-004)
modelNested = model;
modelNested.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
modelNested.subSystems{1} = {'Glycolysis','Pentose Phosphate'};
subSystemsBefore = modelNested.subSystems;
resNested = verifyModel(modelNested,'silentCheck',true);
assert(~(isfield(resNested,'Errors') && isfield(resNested.Errors,'propertiesNotMatched') && ...
    isfield(resNested.Errors.propertiesNotMatched,'subSystems')), ...
    'verifyModel false-flagged a validly nested-cell subSystems field.');
assert(isequal(modelNested.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that an empty-double entry ('subSystems(i) = {[]}', as used by e.g.
% testConvertOldStyleModel.m to mark a reaction with no subsystem) is
% tolerated like '' and {}, not reported as malformed (FR-006)
modelEmptyDouble = model;
modelEmptyDouble.subSystems(10) = {[]};
subSystemsBefore = modelEmptyDouble.subSystems;
resEmptyDouble = verifyModel(modelEmptyDouble,'silentCheck',true);
assert(~(isfield(resEmptyDouble,'Errors') && isfield(resEmptyDouble.Errors,'propertiesNotMatched') && ...
    isfield(resEmptyDouble.Errors.propertiesNotMatched,'subSystems')), ...
    'verifyModel false-flagged an empty-double ([]) subSystems entry.');
assert(isequal(modelEmptyDouble.subSystems, subSystemsBefore), 'verifyModel mutated model.subSystems.');

% test that a valid rxn2subSystem/subSystemNames pair reports no error (FR-005)
modelMat = model;
[~, modelMat.rxn2subSystem, modelMat.subSystemNames] = buildRxn2subSystem(model, false);
resMat = verifyModel(modelMat,'silentCheck',true);
assert(~(isfield(resMat,'Errors') && isfield(resMat.Errors,'propertiesNotMatched') && ...
    (isfield(resMat.Errors.propertiesNotMatched,'rxn2subSystem') || ...
     isfield(resMat.Errors.propertiesNotMatched,'subSystemNames'))), ...
    'verifyModel false-flagged a valid rxn2subSystem/subSystemNames pair.');

% test that a malformed rxn2subSystem (wrong column count) reports an error (FR-005)
modelBadMat = modelMat;
modelBadMat.rxn2subSystem = modelBadMat.rxn2subSystem(:,1:end-1);
resBadMat = verifyModel(modelBadMat,'silentCheck',true);
assert(isfield(resBadMat,'Errors') && isfield(resBadMat.Errors,'inconsistentFields') && ...
    isfield(resBadMat.Errors.inconsistentFields,'rxn2subSystem'), ...
    'verifyModel did not report a dimension-mismatched rxn2subSystem.');

% test whether rules are checked crrectly
modelRule = model;
modelRule.rules(3) = {'x(17) )'};
res = verifyModel(modelRule,'silentCheck',true);

assert(~isempty(res))
assert(isequal(res.Errors.propertiesNotMatched.rules, sprintf('Field does not match the required properties at the following positions: \n       3')));

%% fields that are required but missing
modelNoLb = rmfield(model, 'lb');
res = verifyModel(modelNoLb, 'silentCheck', true);
assert(isequal(res.Errors.missingFields, {'lb'}));

%% the check is restricted to a list of fields, or to the fields of FBA
% lb is not among the listed fields, so that its absence is no problem any more
res = verifyModel(modelNoLb, 'silentCheck', true, 'restrictToFields', {'ub', 'c'});
assert(isempty(fieldnames(res)));
% an optional field in the list is still checked
res = verifyModel(modelRule, 'silentCheck', true, 'restrictToFields', {'rules'});
assert(isfield(res.Errors.propertiesNotMatched, 'rules'));
% rules play no role in FBA, but lb does
res = verifyModel(modelRule, 'silentCheck', true, 'FBAOnly', true);
assert(isempty(fieldnames(res)));
res = verifyModel(modelNoLb, 'silentCheck', true, 'FBAOnly', true);
assert(isequal(res.Errors.missingFields, {'lb'}));

%% a model can bring its own field properties
modelOwnProperties = model;
modelOwnProperties.fieldProperties = {'lb', 'rxns', NaN, 'ischar(x)'};
res = verifyModel(modelOwnProperties, 'silentCheck', true);
assert(isfield(res.Errors.propertiesNotMatched, 'lb'));

%% the simple check returns a boolean
assert(verifyModel(model, 'simpleCheck', true) == true);
assert(verifyModel(modelNoLb, 'simpleCheck', true, 'silentCheck', true) == false);

%% problems are printed unless the check is silent
reportText = evalc('verifyModel(modelNoLb);');
assert(contains(reportText, 'The following problems have been encountered in the model structure'));
assert(contains(reportText, sprintf('missingFields:\nlb\n')));
reportText = evalc('verifyModel(modelRule);');
assert(contains(reportText, 'propertiesNotMatched:'));
assert(contains(reportText, 'rules: Field does not match the required properties'));
assert(isempty(evalc('verifyModel(modelRule, ''silentCheck'', true);')));

%% a small model for the checks of balance and consistency
%   EX_a  a[c] <=>      exchange
%   r1    a[c] -> b[c]  loses one carbon and one charge
%   EX_b  b[c] ->       exchange, the objective
%   r2    d[c] -> a[c]  blocked: nothing produces d[c], which is a dead end
small = struct();
small.mets = {'a[c]'; 'b[c]'; 'd[c]'};
small.rxns = {'EX_a'; 'r1'; 'EX_b'; 'r2'};
small.S = sparse([-1 -1 0 1; 0 1 -1 0; 0 0 0 -1]);
small.lb = [-10; 0; 0; 0];
small.ub = [1000; 1000; 1000; 1000];
small.c = [0; 0; 1; 0];
small.b = zeros(3, 1);
small.csense = ['E'; 'E'; 'E'];
small.osenseStr = 'max';
small.genes = cell(0, 1);
small.rules = repmat({''}, 4, 1);
assert(isempty(fieldnames(verifyModel(small, 'silentCheck', true))));

%% mass and charge balance
smallFormula = small;
smallFormula.metFormulas = {'C2'; 'C'; 'C2'};
smallCharge = small;
smallCharge.metCharges = [0; -1; 0];
smallBoth = smallFormula;
smallBoth.metCharges = smallCharge.metCharges;

% the field that the check needs is missing
res = verifyModel(small, 'massBalance', true, 'silentCheck', true);
assert(contains(res.massBalance.missingFields, 'The metFormulas field is missing'));
res = verifyModel(small, 'chargeBalance', true, 'silentCheck', true);
assert(contains(res.chargeBalance.missingFields, 'The metCharges field is missing'));

% the formulas are enough for the mass balance: r1 loses a carbon, r2 is balanced
% (imBalancedRxnBool is not asserted here, see the defect about missing charges in the header)
res = verifyModel(smallFormula, 'massBalance', true, 'silentCheck', true);
carbonImbalance = res.massBalance.massImbalance(:, strcmp(res.massBalance.Elements, 'C'));
assert(isequal(full(carbonImbalance), [-2; -1; -1; 0]));
assert(strcmp(res.massBalance.imBalancedMass{2}, '-1 C') && isempty(res.massBalance.imBalancedMass{4}));
assert(~any(res.massBalance.missingFormulaeBool) && isfield(res.massBalance, 'balancedMetBool'));
assert(~isfield(res, 'chargeBalance'));

% the charges are enough for the charge balance: r1 changes the charge by -1, r2 keeps it
res = verifyModel(smallCharge, 'chargeBalance', true, 'silentCheck', true);
assert(isequal(res.chargeBalance.imBalanceCharge, [0; -1; 1; 0]));
assert(~isfield(res, 'massBalance'));

% both at once: with the charges known, only the reactions that are out of balance are flagged
res = verifyModel(smallBoth, 'massBalance', true, 'chargeBalance', true, 'silentCheck', true);
assert(isequal(res.massBalance.imBalancedRxnBool(:), [true; true; true; false]));
assert(isfield(res, 'chargeBalance'));

% the simple check is false for an imbalanced model (the balanced one is below)
assert(~verifyModel(smallBoth, 'massBalance', true, 'chargeBalance', true, 'simpleCheck', true, 'silentCheck', true));

%% flux consistency
changeCobraSolver(solvers.LP{1}, 'LP', 0);
res = verifyModel(small, 'fluxConsistency', true, 'silentCheck', true);
% at the optimum the blocked reaction carries no flux and the other three do
assert(isequal(res.fluxConsistency.consistentReactions, {'EX_a'; 'r1'; 'EX_b'}));
assert(isequal(res.fluxConsistency.consistentReactionBool, [true; true; true; false]));

%% dead end metabolites
res = verifyModel(small, 'deadEndMetabolites', true, 'silentCheck', true);
assert(isequal(res.deadEndMetabolites.DeadEndMetabolites, {'d[c]'}));
assert(~verifyModel(small, 'deadEndMetabolites', true, 'simpleCheck', true, 'silentCheck', true));

%% stoichiometric consistency of a model that is consistent throughout
% a <=> b conserves mass, so that the simple check passes (see the defect in the header for the rest)
closed = struct();
closed.mets = {'a[c]'; 'b[c]'};
closed.rxns = {'r1'; 'r2'};
closed.S = sparse([-1 1; 1 -1]);
closed.lb = [0; 0];
closed.ub = [1000; 1000];
closed.c = [0; 0];
closed.b = [0; 0];
closed.csense = ['E'; 'E'];
closed.osenseStr = 'max';
closed.genes = cell(0, 1);
closed.rules = {''; ''};
assert(verifyModel(closed, 'stoichiometricConsistency', true, 'simpleCheck', true, 'silentCheck', true));

%% the simple check of mass and charge balance on a balanced model
closed.metFormulas = {'C'; 'C'};
closed.metCharges = [0; 0];
assert(verifyModel(closed, 'massBalance', true, 'chargeBalance', true, 'simpleCheck', true, 'silentCheck', true));

%% database identifiers
modelBadID = small;
modelBadID.metKEGGID = {'C00031'; 'notAnID'; ''};
res = verifyModel(modelBadID, 'checkDatabaseIDs', true, 'silentCheck', true);
assert(isequal(res.checkDatabaseIDs.invalidIDs.metKEGGID, {'valid'; 'notAnID'; 'valid'}));
assert(isempty(fieldnames(verifyModel(small, 'checkDatabaseIDs', true, 'silentCheck', true))));

% change the directory
cd(currentDir);
