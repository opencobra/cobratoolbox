% The COBRAToolbox: testConstrainRxns.m
%
% Purpose:
%     - tests constrainRxns, which applies custom, growth media and metabolomic constraints to a model
%       for XomicsToModel, on toy networks. In the mode allConstraints it fits a gecko-style model
%       (extra variables and matrices C, D and E) to data by quadratic relaxation of its bounds:
%       * a bound of an extra variable can be relaxed
%       * the model is feasible after relaxation, and flux and enzyme usage stay coupled
%     - This file was a function-based test (functiontests). The harness (runScriptFile) runs a test
%       with run(fileName), which only builds such a test suite and never runs it, so the test passed
%       with 0% coverage and its three checks had never run under testAll. It is a script now.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/metabolomics/constrainRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on hand-built toy networks; the largest has 131 reactions because the
%       printed lists of relaxed reactions stop at 99 entries.
%
% Coverage exemptions:
%     Lines 290, 314, 764, 785: unreachable, inside an if 0 block.
%     Lines 344, 390-391, 476, 478, 482-483: unreachable, in the else branch of an if 1 block.
%     Lines 888, 944-947, 1072-1073, 1076-1077, 1081-1082, 1084-1085: unreachable, in the else branch of an if 1 block.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default eta is below the noise of the fit
%       SEVERITY: limitation
%       TRIGGER: an exometabolomic or allConstraints fit with the default eta, solved by gurobi
%       OBSERVED: the fit leaves relaxations of about 2e-5 on bounds that need none. They exceed
%         eta = 1e-5, count as relaxed, and such a measured bound stays at its model value instead of
%         mean +/- SD. The sections below that need the bounds exact set eta = 1e-3
%       EXPECTED: an eta that separates a relaxation from the tolerance of the QP
%       LINES: 112, 441-442, 1020-1023
%     - DEFECT: The fitted exometabolomic relaxation is not applied to a feasible model
%       SEVERITY: wrong-result
%       TRIGGER: mode exometabolomicConstraints, a feasible model and a measured flux outside its
%         bounds, so that the fit relaxes a bound
%       OBSERVED: modelFitted is a plain copy of the model and only an infeasible model gets the bounds
%         lb - p and ub + q. The relaxation is reported but the bound stays, and the bound opposite to
%         it moves to the fitted flux, which can stop the call with "lower bounds greater than upper
%         bounds"
%       EXPECTED: the relaxed bounds in modelFitted before the feasibility check, as the mode
%         allConstraints does
%       LINES: 395
%     - DEFECT: The mode allConstraints needs the extra variable fields it treats as optional
%       SEVERITY: error
%       TRIGGER: mode allConstraints with a model without the field evarlb
%       OBSERVED: the call stops with "Unrecognized field name evarlb" although nExt = 0 is handled
%         earlier; the test passes empty evars, evarNames, evarlb and evarub to reach those lines
%       EXPECTED: a model without extra variables fitted like any other
%       LINES: 954-955
%     - DEFECT: An unknown varID stops the mode allConstraints on a model without extra variables
%       SEVERITY: error
%       TRIGGER: mode allConstraints, no extra variables, several exoMet rows and one that is not a
%         reaction of the model
%       OBSERVED: false(numel(exo.varID)) is a square matrix, so the mask indexes outside the table and
%         the call stops with "The logical indices contain a true value outside of the array bounds"
%       EXPECTED: the entry reported and ignored, as it is with extra variables
%       LINES: 650-651, 655
%     - DEFECT: A reaction listed three times stops the constraint step
%       SEVERITY: error
%       TRIGGER: rxns2constrain or mediaData with one reaction in three or more rows
%       OBSERVED: idx2delete(c) = idR(1:end - 1) assigns several numbers to one element and the call
%         stops with "Unable to perform assignment"
%       EXPECTED: the repeated rows removed as they are for two rows
%       LINES: 1203
%     - DEFECT: A tiny bound of the unusual sign changes sign
%       SEVERITY: wrong-result
%       TRIGGER: a positive lower bound or a negative upper bound below boundPrecisionLimit in absolute value
%       OBSERVED: lb = 1e-7 becomes -boundPrecisionLimit and ub = -1e-7 becomes +boundPrecisionLimit,
%         which opens the reaction in a direction it was closed for; extra variables keep their sign
%       EXPECTED: the sign kept, as lines 1361-1371 do for extra variables
%       LINES: 1341, 1348
%     - DEFECT: The session display format is changed
%       SEVERITY: cosmetic
%       TRIGGER: any call that reaches the bound correction
%       OBSERVED: format long g stays in force after the call returns
%       EXPECTED: the display format left as it was
%       LINES: 1244
%     - DEFECT: The message about a feasible fit is never printed
%       SEVERITY: cosmetic
%       TRIGGER: any fit whose model is feasible
%       OBSERVED: fprintf('%\n', text) has no conversion for the text, so an empty line is printed at
%         every printLevel
%       EXPECTED: fprintf('%s\n', text) under printLevel > 0
%       LINES: 400, 963
%
% Authors:
%     - Original file: PkiwiBird, March 2026
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConstrainRxns'));
cd(fileDir);

% fitExperimentalFlux solves its badly scaled QP with one of these, whatever the current QP solver is
prepareTest('needsLP', true, 'needsQP', true, 'requireOneSolverOf', {'gurobi', 'ibm_cplex', 'mosek'});

% constrainRxns leaves format long g behind, see the header
originalFormat = format;
restoreFormat = onCleanup(@() format(originalFormat));

% tol: exact bound arithmetic. fitTol: the fit is regularised (1e-7 on the fluxes), and relaxations of
% about 3e-5 remain on bounds that do not need any
tol = 1e-9;
fitTol = 1e-3;

% eta above the noise of the fit (see the header), for sections that assert exact bounds
etaParam = struct('eta', 1e-3);

%% allConstraints: quadratic relaxation of a gecko-style model
% specificData.exoMet holds the experimental data (mean, SD) of the enzyme usage. The
% param.weight*_e_default are the weights for relaxing the bounds of all extra variables
[model, specificData, param] = createToyGeckoModel();
relaxModel = constrainRxns(model, specificData, param, 'allConstraints', 0); % 0 is printLevel

% simulate LP after relaxation
LP = buildOptProblemFromModel(relaxModel, true, struct());
sol = solveCobraLP(LP);

% the model is feasible after the relaxation
assert(sol.stat == 1);

% the ub of epool was 1 but the experimental mean was 10, so its upper bound is relaxed
epoolEvarIdx = strcmp(relaxModel.evars, 'epool');
isrelaxEvarUb = relaxModel.exometRelaxation.evarupperBoundBool; % true when ub was relaxed
assert(isrelaxEvarUb(epoolEvarIdx));

% enzyme usage and reaction flux stay coupled (coupling constraints with extra variables)
nRxn = numel(relaxModel.rxns);
solFlx = sol.full(1:nRxn);
solEzUsg = sol.full(nRxn+1:end);
v1Idx = ismember(relaxModel.rxns, 'v1');
v2Idx = ismember(relaxModel.rxns, 'v2');
e1Idx = ismember(relaxModel.evars, 'e1');
e2Idx = ismember(relaxModel.evars, 'e2');
epoolIdx = ismember(relaxModel.evars, 'epool');
couplingTol = 1e-6;
assert(abs(solFlx(v1Idx) - solEzUsg(e1Idx)) <= couplingTol); % v1 - e1 = 0
assert(abs(solFlx(v2Idx) - solEzUsg(e2Idx)) <= couplingTol); % v2 - e2 = 0
assert(abs(solEzUsg(e1Idx) + solEzUsg(e2Idx) - solEzUsg(epoolIdx)) <= couplingTol); % e1 + e2 - epool = 0

% the fitted point is a steady state that respects the coupling
relaxation = relaxModel.exometRelaxation;
assert(norm(model.S * relaxation.v + model.E * relaxation.v_extraVariables) < fitTol);
assert(norm(model.C * relaxation.v + model.D * relaxation.v_extraVariables - model.d) < fitTol);
% epool ends between the old bound and the data: weight 1 on q, 1/(1 + SD^2) = 0.5 on the deviation
assert(relaxation.q_extraVariables(epoolIdx) > 1 && relaxation.v_extraVariables(epoolIdx) < 10);
% epool is measured, so its bounds are the fitted value +/- SD unless relaxed
assert(abs(relaxModel.evarub(epoolIdx) - (model.evarub(epoolIdx) + relaxation.q_extraVariables(epoolIdx))) < tol);

%% an unknown mode is refused
model = buildExchangeModel();
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, struct(), struct(), 'noSuchMode', 0}, ...
    'testMessage', 'unrecognised mode'));

%% without param and mode the defaults are set first, then the missing mode stops the call
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, struct()}));

%% customConstraints: incomplete data is refused
customErrors = {struct(), 'Expecting specificData.rxns2constrain but it is absent'; ...
    struct('rxns2constrain', table([1; 2], 'VariableNames', {'lb'})), 'Expecting specificData.rxns2constrain.rxns but it is absent'; ...
    struct('rxns2constrain', table({'R1'}, 'VariableNames', {'rxns'})), 'Expecting specificData.rxns2constrain.lb but it is absent'; ...
    struct('rxns2constrain', table({'R1'}, 1, 'VariableNames', {'rxns', 'lb'})), 'Expecting specificData.rxns2constrain.ub but it is absent'};
for iCase = 1:size(customErrors, 1)
    assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, customErrors{iCase, 1}, struct(), 'customConstraints', 0}, ...
        'testMessage', customErrors{iCase, 2}));
end

%% customConstraints: bounds are set, NaN leaves a bound alone, printLevel defaults to 0
customData = struct('rxns2constrain', table({'EX_a'; 'R1'}, [-5; NaN], [5; 8], 'VariableNames', {'rxns', 'lb', 'ub'}));
[newModel, rxnsConstrained, rxnBoundsCorrected, newSpecificData] = constrainRxns(model, customData, struct(), 'customConstraints');

assert(isequal(rxnsConstrained, {'EX_a'; 'R1'}));
assert(isequal(newModel.lb, [-5; 0; -10; -1; 0; -10]));
assert(isequal(newModel.ub, [5; 8; 10; 1; 10; 0]));
assert(isequal(newModel.constraintDescription(1:3), {'Custom constraint'; 'Custom constraint'; ''}));
% no bound needs a correction, and the data come back with the description column
assert(isempty(rxnBoundsCorrected));
assert(isequal(newSpecificData.rxns2constrain.constraintDescription, {'Custom constraint'; 'Custom constraint'}));

%% customConstraints: bounds in cells, a given description and an existing description field
customTable = table({'EX_a'; 'R1'}, {-5; 1}, {5; 8}, {'From a paper'; ''}, ...
    'VariableNames', {'rxns', 'lb', 'ub', 'constraintDescription'});
modelDescribed = model;
modelDescribed.constraintDescription = repmat({'old'}, numel(model.rxns), 1);
newModel = constrainRxns(modelDescribed, struct('rxns2constrain', customTable), [], 'customConstraints', 0);

assert(isequal(newModel.lb(1:2), [-5; 1]) && isequal(newModel.ub(1:2), [5; 8]));
assert(isequal(newModel.constraintDescription(1:3), {'From a paper'; 'Custom constraint'; 'old'}));

%% customConstraints: reactions outside the model are dropped and reported
customData = struct('rxns2constrain', table({'noSuchRxn'; 'R1'}, [1; 2], [3; 4], 'VariableNames', {'rxns', 'lb', 'ub'}));
[printedText, newModel, rxnsConstrained] = runCapturingOutput(model, customData, struct(), 'customConstraints', 1);

assert(isequal(rxnsConstrained, {'R1'}));
assert(newModel.lb(2) == 2 && newModel.ub(2) == 4);
assert(contains(printedText, 'could not be constrained since they are not present in the model'));
assert(contains(printedText, 'noSuchRxn'));
assert(contains(printedText, 'Adding constraints on 1 reactions'));

%% customConstraints: of a reaction listed twice the last row counts, with a warning
customData = struct('rxns2constrain', table({'R1'; 'EX_a'; 'R1'}, [1; -2; 3], [4; 2; 6], 'VariableNames', {'rxns', 'lb', 'ub'}));
[printedText, newModel, rxnsConstrained] = runCapturingOutput(model, customData, struct(), 'customConstraints', 0);

assert(isequal(rxnsConstrained, {'EX_a'; 'R1'}));
assert(newModel.lb(2) == 3 && newModel.ub(2) == 6);
assert(contains(printedText, 'Reaction R1 is repeated.'));

%% customConstraints: a model with a lower bound above its upper bound is refused
modelCrossed = model;
modelCrossed.lb(2) = 200;
customData = struct('rxns2constrain', table({'EX_a'}, -1, 1, 'VariableNames', {'rxns', 'lb', 'ub'}));
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {modelCrossed, customData, struct(), 'customConstraints', 0}, ...
    'testMessage', 'lower bounds greater than upper bounds'));

%% mediaDataConstraints: incomplete data is refused
mediaErrors = {struct(), 'Expecting specificData.mediaData but it is absent'; ...
    struct('mediaData', table(-1, 'VariableNames', {'mediumMaxUptake'})), 'Expecting specificData.mediaData.rxns but it is absent'; ...
    struct('mediaData', table({'EX_a'}, 'VariableNames', {'rxns'})), 'Expecting specificData.mediaData.mediumMaxUptake but it is absent'};
for iCase = 1:size(mediaErrors, 1)
    assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, mediaErrors{iCase, 1}, struct(), 'mediaDataConstraints', 0}, ...
        'testMessage', mediaErrors{iCase, 2}));
end

%% mediaDataConstraints: the uptake limits the lower bound, an essential amino acid is not secreted
mediaData = struct();
mediaData.mediaData = table({'EX_a'; 'EX_b'}, [-3; -2], 'VariableNames', {'rxns', 'mediumMaxUptake'});
mediaData.essentialAA = table({'EX_b'}, 'VariableNames', {'rxns'});
[newModel, rxnsConstrained] = constrainRxns(model, mediaData, struct(), 'mediaDataConstraints', 0);

assert(isequal(rxnsConstrained, {'EX_a'; 'EX_b'}));
assert(isequal(newModel.lb([1 3]), [-3; -2]));
% the upper bound of the essential amino acid is closed, the other one is unchanged
assert(newModel.ub(1) == 10 && newModel.ub(3) == 0);
assert(isequal(newModel.constraintDescription([1 3]), {'Growth media constraint'; 'Growth media constraint'}));

%% mediaDataConstraints: the older column name and a given description
mediaData.mediaData = table({'EX_a'; 'EX_b'}, [-3; -2], {'Medium A'; ''}, ...
    'VariableNames', {'rxns', 'maxMediumUptake', 'constraintDescription'});
newModel = constrainRxns(modelDescribed, mediaData, struct(), 'mediaDataConstraints', 0);

assert(isequal(newModel.lb([1 3]), [-3; -2]));
assert(isequal(newModel.constraintDescription([1 3]), {'Medium A'; 'Growth media constraint'}));

%% mediaDataConstraints: a model with a lower bound above its upper bound is refused
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {modelCrossed, mediaData, struct(), 'mediaDataConstraints', 0}, ...
    'testMessage', 'lower bounds greater than upper bounds'));

%% bounds outside TolMinBoundary and TolMaxBoundary are moved to the limit and reported
modelWide = model;
modelWide.lb(1) = -1000; % lb below the minimum
modelWide.ub(1) = 1000;  % ub above the maximum
modelWide.lb(3) = -300;  % both below the minimum
modelWide.ub(3) = -200;
modelWide.lb(5) = 200;   % both above the maximum
modelWide.ub(5) = 300;
limitParam = struct('TolMinBoundary', -100, 'TolMaxBoundary', 100);
customData = struct('rxns2constrain', table({'R1'}, 0, 50, 'VariableNames', {'rxns', 'lb', 'ub'}));
[printedText, newModel, ~, rxnBoundsCorrected] = runCapturingOutput(modelWide, customData, limitParam, 'customConstraints', 1);

assert(isequal(sort(rxnBoundsCorrected), sort({'EX_a'; 'EX_b'; 'DM_b'})));
assert(newModel.lb(1) == -100 && newModel.ub(1) == 100);
assert(newModel.lb(3) == -100 && newModel.ub(3) == -100);
assert(newModel.lb(5) == 100 && newModel.ub(5) == 100);
assert(contains(printedText, 'have bounds larger than the recommended value = abs(100)'));
assert(contains(printedText, 'The bounds for the following reactions have been adjusted:'));
assert(contains(printedText, 'Number of corrected bounds (to min/max boundary):'));

%% a bound correction refuses a result with a lower bound above its upper bound
% the custom bounds cross; the correction of another reaction is what reaches the check
customData = struct('rxns2constrain', table({'EX_b'}, 20, 10, 'VariableNames', {'rxns', 'lb', 'ub'}));
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, customData, struct('TolMaxBoundary', 50), 'customConstraints', 0}, ...
    'testMessage', 'lower bounds greater than upper bounds'));

%% bounds below boundPrecisionLimit grow to the limit and are reported
% a negative lower and a positive upper bound: the other signs are a known defect, see the header
modelTiny = model;
modelTiny.lb(1) = -1e-7;
modelTiny.ub(2) = 1e-7;
tinyParam = struct('boundPrecisionLimit', 1e-5);
customData = struct('rxns2constrain', table({'EX_b'}, -5, 5, 'VariableNames', {'rxns', 'lb', 'ub'}));
[printedText, newModel, ~, rxnBoundsCorrected] = runCapturingOutput(modelTiny, customData, tinyParam, 'customConstraints', 1);

assert(isequal(rxnBoundsCorrected, {'EX_a'; 'R1'}));
assert(abs(newModel.lb(1) + tinyParam.boundPrecisionLimit) < tol);
assert(abs(newModel.ub(2) - tinyParam.boundPrecisionLimit) < tol);
assert(contains(printedText, 'have bounds smaller than the reccommended value'));
assert(contains(printedText, 'The bounds for the following reactions will be adjusted:'));

%% a NaN bound is refused
modelNaN = model;
modelNaN.ub(2) = NaN;
customData = struct('rxns2constrain', table({'EX_b'}, -5, 5, 'VariableNames', {'rxns', 'lb', 'ub'}));
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {modelNaN, customData, struct(), 'customConstraints', 0}, ...
    'testMessage', 'at least one NaN bound'));

%% exometabolomicConstraints: incomplete data is refused
exoErrors = {table(1, 2, 'VariableNames', {'mean', 'SD'}), 'Expecting specificData.exoMet.rxns but it is absent'; ...
    table({'EX_a'}, 2, 'VariableNames', {'rxns', 'SD'}), 'Expecting specificData.exoMet.mean but it is absent'; ...
    table({'EX_a'}, 2, 'VariableNames', {'rxns', 'mean'}), 'Expecting specificData.exoMet.SD but it is absent'};
for iCase = 1:size(exoErrors, 1)
    assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, struct('exoMet', exoErrors{iCase, 1}), struct(), 'exometabolomicConstraints', 0}, ...
        'testMessage', exoErrors{iCase, 2}));
end

%% exometabolomicConstraints: fluxes inside the bounds are fitted, the bounds become mean +/- SD
measuredRxns = {'EX_a'; 'EX_b'; 'R1'; 'REV_b'};
exoData = struct('exoMet', table(measuredRxns, [5; 3; 5; -1], [1; 1; 10; 5], 'VariableNames', {'rxns', 'mean', 'SD'}));
[newModel, rxnsConstrained, rxnBoundsCorrected, newSpecificData] = constrainRxns(model, exoData, etaParam, 'exometabolomicConstraints', 0);
fit = newModel.exometRelaxation;

% the fit is a steady state that matches the data
assert(isequal(rxnsConstrained, measuredRxns));
assert(isempty(rxnBoundsCorrected));
assert(norm(model.S * fit.v) < fitTol);
assert(max(abs(fit.dv(ismember(model.rxns, measuredRxns)))) < fitTol);
assert(~any(fit.lowerBoundBool) && ~any(fit.upperBoundBool));

% reversible reactions get mean +/- SD; the forward reaction R1 cannot go below zero, nor the
% reverse reaction REV_b above zero
expectedLb = [4; 0; 2; -1; 0; -6];
expectedUb = [6; 15; 4; 1; 10; 0];
assert(norm(newModel.lb - expectedLb) < fitTol);
assert(norm(newModel.ub - expectedUb) < fitTol);

% the relaxation weights: Inf for internal, sink and demand reactions and for unmeasured lower
% bounds of exchanges. Inf also for the lower bound of an exchange that measurably goes forward
assert(isequal(fit.weightLower, [Inf; Inf; Inf; Inf; Inf; 1]));
assert(isequal(fit.weightUpper, [1; Inf; 1; Inf; Inf; 1]));

% the description and the table of results, sorted by the measured mean
assert(isequal(newModel.constraintDescription(1), {'Metabolomics constraints'}));
results = newSpecificData.exoMet;
assert(isequal(results.rxns, {'REV_b'; 'EX_b'; 'EX_a'; 'R1'}));
assert(isequal(results.sign_vExp, [-1; 1; 1; 1]));
% the interval mean +/- SD of REV_b and R1 contains zero
assert(isequal(results.sign_vExpSD, [0; 1; 1; 0]));
assert(isequal(results.signMatch, [1; 1; 1; 1]));
assert(norm(results.v - [-1; 3; 5; 5]) < fitTol);

%% exometabolomicConstraints: a measured flux that goes backward cannot have its upper bound relaxed
exoData = struct('exoMet', table({'EX_b'}, -3, 1, 'VariableNames', {'rxns', 'mean', 'SD'}));
newModel = constrainRxns(model, exoData, struct(), 'exometabolomicConstraints', 0);
assert(isinf(newModel.exometRelaxation.weightUpper(3)));
assert(newModel.exometRelaxation.weightLower(3) == 1);
% without param.eta it is ten times the feasibility tolerance
assert(abs(newModel.exometRelaxation.eta - 10 * getCobraSolverParams('LP', 'feasTol')) < tol);

%% exometabolomicConstraints: the weight of the deviation from the data
exoData = struct('exoMet', table({'EX_a'}, 5, 2, 'VariableNames', {'rxns', 'mean', 'SD'}));
weightKinds = {'SD', 1 / 5; 'mean', 1 / 26; 'RSD', 1 / 0.16; 'uniform', 2};
for iCase = 1:size(weightKinds, 1)
    newModel = constrainRxns(model, exoData, struct('metabolomicWeights', weightKinds{iCase, 1}), 'exometabolomicConstraints', 0);
    assert(abs(newModel.exometRelaxation.weightExp(1) - weightKinds{iCase, 2}) < tol);
    % reactions without data have no weight
    assert(all(isnan(newModel.exometRelaxation.weightExp(2:end))));
end

%% exometabolomicConstraints: the columns exoMet_mean and exoMet_SD replace mean and SD
exoData = struct('exoMet', table({'EX_a'}, 0, 0, 5, 2, 'VariableNames', {'rxns', 'mean', 'SD', 'exoMet_mean', 'exoMet_SD'}));
[newModel, ~, ~, newSpecificData] = constrainRxns(model, exoData, struct(), 'exometabolomicConstraints', 0);

assert(newSpecificData.exoMet.mean == 5 && newSpecificData.exoMet.SD == 2);
assert(~any(ismember({'exoMet_mean', 'exoMet_SD'}, newSpecificData.exoMet.Properties.VariableNames)));
assert(abs(newModel.exometRelaxation.v(1) - 5) < fitTol);

%% exometabolomicConstraints: user penalties replace the weights of measured reactions
% a finite weight on the internal reaction R1 is allowed, with a warning
exoData = struct('exoMet', table({'EX_a'; 'R1'}, [5; 5], [1; 1], [2; 3], [4; 6], 'VariableNames', ...
    {'rxns', 'mean', 'SD', 'penaltyLowerBoundPerturbation', 'penaltyUpperBoundPerturbation'}));
[printedText, newModel] = runCapturingOutput(model, exoData, struct(), 'exometabolomicConstraints', 0);

assert(isequal(newModel.exometRelaxation.weightLower(1:2), [2; 3]));
assert(isequal(newModel.exometRelaxation.weightUpper(1:2), [4; 6]));
assert(contains(printedText, 'Some internal reaction lower bounds may be relaxed'));
assert(contains(printedText, 'Some internal reaction upper bounds may be relaxed'));

%% exometabolomicConstraints: printed report, unknown and duplicate reactions
exoData = struct('exoMet', table({'EX_a'; 'EX_a'; 'noSuchRxn'}, [5; 5; 1], [1; 1; 1], 'VariableNames', {'rxns', 'mean', 'SD'}));
[printedText, newModel, rxnsConstrained, ~, newSpecificData] = runCapturingOutput(model, exoData, etaParam, 'exometabolomicConstraints', 1);

assert(isequal(rxnsConstrained, {'EX_a'; 'EX_a'}));
assert(abs(newModel.exometRelaxation.v(1) - 5) < fitTol);
% the unknown reaction is kept in the table, without results
unknownRow = strcmp(newSpecificData.exoMet.rxns, 'noSuchRxn');
assert(isnan(newSpecificData.exoMet.lb(unknownRow)) && isnan(newSpecificData.exoMet.v(unknownRow)));
assert(isnan(newSpecificData.exoMet.signMatch(unknownRow)));
assert(contains(printedText, 'The following exometabolomic exchange reactions were not found in the model:'));
assert(contains(printedText, 'There are duplicate rxns entries in the metabolomic data!'));
assert(contains(printedText, 'Fit experimental flux method: two norm.'));
assert(contains(printedText, '1 measured exchange reaction rates.'));
assert(contains(printedText, 'Fit reactions:'));
assert(contains(printedText, 'No relaxation of lower bounds.'));
assert(contains(printedText, 'No relaxation of upper bounds.'));
assert(contains(printedText, '...done.'));

%% exometabolomicConstraints: nothing to fit
exoData = struct('exoMet', table({'noSuchRxn'}, 1, 1, 'VariableNames', {'rxns', 'mean', 'SD'}));
[printedText, newModel, rxnsConstrained] = runCapturingOutput(model, exoData, struct(), 'exometabolomicConstraints', 1);

assert(isempty(rxnsConstrained));
assert(isequal(newModel.lb, model.lb) && isequal(newModel.ub, model.ub));
assert(contains(printedText, 'No finite data to fit reaction bounds.'));

%% exometabolomicConstraints: an infeasible model gets the relaxed bounds that the fit found
% production of a is at most 1 but EX_b must secrete at least 2. Sink and reverse reaction are closed
modelInfeasible = model;
modelInfeasible.ub(1) = 1;
modelInfeasible.lb(3) = 2;
modelInfeasible.lb([4 6]) = 0;
modelInfeasible.ub([4 6]) = 0;
exoData = struct('exoMet', table({'EX_a'; 'EX_b'}, [1.5; 0.5], [1; 1], 'VariableNames', {'rxns', 'mean', 'SD'}));
[printedText, newModel] = runCapturingOutput(modelInfeasible, exoData, etaParam, 'exometabolomicConstraints', 1);
fit = newModel.exometRelaxation;

assert(fit.upperBoundBool(1) && fit.lowerBoundBool(3));
% the relaxations close the gap of 1 between the bounds, and the flux is a steady state inside them
assert(abs(sum(fit.p) + sum(fit.q) - 1) < fitTol);
assert(norm(modelInfeasible.S * fit.v) < fitTol);
assert(all(fit.v >= modelInfeasible.lb - fit.p - fitTol) && all(fit.v <= modelInfeasible.ub + fit.q + fitTol));
assert(abs(newModel.ub(1) - (1 + fit.q(1))) < tol);
assert(abs(newModel.lb(3) - (2 - fit.p(3))) < tol);
% the relaxed model is feasible
relaxedSolution = optimizeCbModel(newModel);
assert(relaxedSolution.stat == 1);
assert(contains(printedText, 'Fitted model is feasible, but only after including small changes'));
assert(contains(printedText, '1 lower bounds relaxed.'));
assert(contains(printedText, '1 measured external metabolite lower bounds relaxed.'));
assert(contains(printedText, 'Relaxation of lower bounds:'));
assert(contains(printedText, 'Relaxation of upper bounds:'));

%% exometabolomicConstraints: a negative SD crosses the bounds, which the last check refuses
exoData = struct('exoMet', table({'EX_a'}, 5, -1, 'VariableNames', {'rxns', 'mean', 'SD'}));
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {model, exoData, etaParam, 'exometabolomicConstraints', 0}, ...
    'testMessage', 'lower bounds greater than upper bounds'));

%% exometabolomicConstraints: a fit that fails is skipped with a warning, and no relaxation applies
% R1 must carry 2 but EX_a gives at most 1. R1 is internal and EX_a measurably goes backward (its upper
% bound may not be relaxed), so no relaxation exists and the QP is infeasible (no stand-in: the
% solver reports it, and fitExperimentalFlux raises the error that constrainRxns catches)
modelUnfittable = model;
modelUnfittable.lb(1) = -1;
modelUnfittable.ub(1) = 1;
modelUnfittable.lb(2) = 2;
exoData = struct('exoMet', table({'EX_a'}, -5, 1, 'VariableNames', {'rxns', 'mean', 'SD'}));
[printedText, newModel] = runCapturingOutput(modelUnfittable, exoData, struct(), 'exometabolomicConstraints', 0);
fit = newModel.exometRelaxation;

assert(contains(printedText, 'Exometabolomic flux fit could not be solved'));
assert(contains(printedText, 'Fitted model is not feasible for FBA yet.'));
assert(all(fit.v == 0) && all(fit.p == 0) && all(fit.q == 0));
assert(all(isnan(fit.dv)) && isnan(newModel.exometRelaxationObj));

%% exometabolomicConstraints: the printed lists stop at 99 reactions
% 130 exchanges must each secrete 0.1, but their common source gives at most 1 in total
nExchange = 130;
exchanges = arrayfun(@(k) sprintf('EX_%d', k), (1:nExchange)', 'UniformOutput', false);
modelManyLower = buildStarModel(exchanges, [1, -ones(1, nExchange)]);
modelManyLower.lb(2:end) = 0.1;
modelManyLower.ub(1) = 1;
exoData = struct('exoMet', table(exchanges, zeros(nExchange, 1), ones(nExchange, 1), 'VariableNames', {'rxns', 'mean', 'SD'}));
[printedText, newModel] = runCapturingOutput(modelManyLower, exoData, struct(), 'exometabolomicConstraints', 1);

assert(all(newModel.exometRelaxation.lowerBoundBool(2:end)));
assert(contains(printedText, ' EX_99 ') && ~contains(printedText, ' EX_100 '));

% the same on the upper bounds: each exchange gives at most 0.01 but the sink must take at least 2
modelManyUpper = buildStarModel(exchanges, [-1, ones(1, nExchange)]);
modelManyUpper.lb(1) = 2;
modelManyUpper.ub(2:end) = 0.01;
[printedText, newModel] = runCapturingOutput(modelManyUpper, exoData, struct(), 'exometabolomicConstraints', 1);

assert(all(newModel.exometRelaxation.upperBoundBool(2:end)));
assert(contains(printedText, ' EX_99 ') && ~contains(printedText, ' EX_100 '));
clear modelManyLower modelManyUpper

%% allConstraints: incomplete data is refused
[modelGecko, ~, paramGecko] = createToyGeckoModel();
exoColumns = {'varID', 'mean', 'SD'};
for iCase = 1:numel(exoColumns)
    columnNames = exoColumns;
    columnNames{iCase} = 'other';
    incomplete = struct('exoMet', table({'v1'}, 1, 2, 'VariableNames', columnNames));
    assert(verifyCobraFunctionError('constrainRxns', 'inputs', {modelGecko, incomplete, paramGecko, 'allConstraints', 0}, ...
        'testMessage', sprintf('Expecting specificData.exoMet.%s but it is absent', exoColumns{iCase})));
end

%% allConstraints: the weight of the deviation from the data, with and without a factor
exoGecko = struct('exoMet', table({'v1'; 'e1'}, [2; 3], [1; 2], 'VariableNames', exoColumns));
% weights of v1 and e1
weightKinds = {'SD', 1 / 2, 1 / 5; 'mean', 1 / 5, 1 / 10; 'RSD', 4, 9 / 4; 'uniform', 2, 2};
factors = {[], 1; 3, 3};
for iCase = 1:size(weightKinds, 1)
    for iFactor = 1:size(factors, 1)
        paramWeight = paramGecko;
        paramWeight.metabolomicWeights = weightKinds{iCase, 1};
        paramWeight.weightExpFct = factors{iFactor, 1};
        newModel = constrainRxns(modelGecko, exoGecko, paramWeight, 'allConstraints', 0);
        fit = newModel.exometRelaxation;
        assert(abs(fit.weightExp(1) - weightKinds{iCase, 2} * factors{iFactor, 2}) < tol);
        assert(abs(fit.weightExp_extraVariables(1) - weightKinds{iCase, 3} * factors{iFactor, 2}) < tol);
        % reactions and extra variables without data have no weight
        assert(isnan(fit.weightExp(2)) && all(isnan(fit.weightExp_extraVariables(2:3))));
    end
end

%% allConstraints: default weights from the fields SIntRxnBool, SinkRxnBool and DMRxnBool
% v1 is internal, v2 an exchange
modelFields = modelGecko;
modelFields.SIntRxnBool = [true; false];
modelFields.SinkRxnBool = [false; false];
modelFields.DMRxnBool = [false; false];
paramFields = rmfield(paramGecko, {'weightLower_flx_default', 'weightUpper_flx_default'});

% unmeasured: the lower bound of an exchange stays, the upper bound may be relaxed
exoData = struct('exoMet', table({'epool'}, 2, 1, 'VariableNames', exoColumns));
newModel = constrainRxns(modelFields, exoData, paramFields, 'allConstraints', 0);
assert(isequal(newModel.exometRelaxation.weightLower, [Inf; Inf]));
assert(isequal(newModel.exometRelaxation.weightUpper, [Inf; 1]));

% measured going forward: the same, because the mean minus SD is positive
exoData = struct('exoMet', table({'v2'}, 3, 1, 'VariableNames', exoColumns));
newModel = constrainRxns(modelFields, exoData, paramFields, 'allConstraints', 0);
assert(isequal(newModel.exometRelaxation.weightLower, [Inf; Inf]));
assert(isequal(newModel.exometRelaxation.weightUpper, [Inf; 1]));

% measured going backward: the upper bound stays and the lower bound may be relaxed
exoData = struct('exoMet', table({'v2'}, -3, 1, 'VariableNames', exoColumns));
newModel = constrainRxns(modelFields, exoData, paramFields, 'allConstraints', 0);
assert(isequal(newModel.exometRelaxation.weightLower, [Inf; 1]));
assert(isequal(newModel.exometRelaxation.weightUpper, [Inf; Inf]));

%% allConstraints: weights given as vectors replace the defaults, with a warning for internal reactions
paramVectors = paramGecko;
paramVectors.weightLower_flx_default = [1; 2];
paramVectors.weightUpper_flx_default = [3; 4];
paramVectors.weightLower_e_default = [1; 2; 3];
paramVectors.weightUpper_e_default = [4; 5; 6];
exoData = struct('exoMet', table({'epool'}, 2, 1, 'VariableNames', exoColumns));
[printedText, newModel] = runCapturingOutput(modelFields, exoData, paramVectors, 'allConstraints', 0);

assert(isequal(newModel.exometRelaxation.weightLower, [1; 2]));
assert(isequal(newModel.exometRelaxation.weightUpper, [3; 4]));
assert(isequal(newModel.exometRelaxation.weightLower_extraVariables, [1; 2; 3]));
assert(isequal(newModel.exometRelaxation.weightUpper_extraVariables, [4; 5; 6]));
assert(contains(printedText, 'Some internal reaction lower bounds may be relaxed'));
assert(contains(printedText, 'Some internal reaction upper bounds may be relaxed'));

%% allConstraints: without any default the weights are 1 on fluxes and Inf on extra variables
% the function warns about both, as neither the fields nor the defaults are there
paramNone = struct('metabolomicWeights', 'SD');
[printedText, newModel] = runCapturingOutput(modelGecko, specificData, paramNone, 'allConstraints', 0);

assert(isequal(newModel.exometRelaxation.weightLower, [1; 1]));
assert(isequal(newModel.exometRelaxation.weightUpper, [1; 1]));
assert(all(isinf(newModel.exometRelaxation.weightLower_extraVariables)));
assert(all(isinf(newModel.exometRelaxation.weightUpper_extraVariables)));
assert(contains(printedText, 'the model lacks SIntRxnBool/SinkRxnBool/DMRxnBool'));
assert(contains(printedText, 'extra variables exist but no weightLower_e_default/weightUpper_e_default was given.'));

%% allConstraints: user penalties replace the weights of measured fluxes and extra variables
exoData = struct('exoMet', table({'v1'; 'epool'}, [2; 2], [1; 1], [2; 3], [4; 5], 'VariableNames', ...
    [exoColumns, {'penaltyLowerBoundPerturbation', 'penaltyUpperBoundPerturbation'}]));
newModel = constrainRxns(modelGecko, exoData, paramGecko, 'allConstraints', 0);

assert(newModel.exometRelaxation.weightLower(1) == 2 && newModel.exometRelaxation.weightUpper(1) == 4);
assert(newModel.exometRelaxation.weightLower_extraVariables(3) == 3);
assert(newModel.exometRelaxation.weightUpper_extraVariables(3) == 5);

%% allConstraints: printed report, unknown and duplicate entries
exoData = struct('exoMet', table({'v1'; 'v1'; 'e1'; 'e1'; 'noSuchVar'}, [1; 1; 1; 1; 1], [1; 1; 1; 1; 1], 'VariableNames', exoColumns));
[printedText, newModel, rxnsConstrained, ~, newSpecificData] = runCapturingOutput(modelFields, exoData, paramGecko, 'allConstraints', 1);

assert(isequal(rxnsConstrained, {'v1'; 'v1'}));
% the unknown entry is kept in the table, without results
unknownRow = strcmp(newSpecificData.exoMet.varID, 'noSuchVar');
assert(isnan(newSpecificData.exoMet.lb(unknownRow)) && isnan(newSpecificData.exoMet.signMatch(unknownRow)));
assert(contains(printedText, 'These exoMet.varID entries neither match model.rxns nor model.evars'));
assert(contains(printedText, 'noSuchVar'));
assert(contains(printedText, 'There are duplicate rxns entries in the data!'));
assert(contains(printedText, 'There are duplicate extra variables entries in the data!'));
assert(contains(printedText, 'Fit experimental method: two norm.'));
assert(contains(printedText, '1 measured reaction rates.'));
assert(contains(printedText, '1 measured extra variables.'));
assert(contains(printedText, '0 external reaction lower bounds relaxed.'));
assert(contains(printedText, '0 external reaction upper bounds relaxed.'));
assert(abs(newModel.exometRelaxation.v(1) - newModel.exometRelaxation.v_extraVariables(1)) < fitTol);

%% allConstraints: a model without extra variables
% the empty fields are needed because of a known defect, see the header
modelNoExtra = model;
modelNoExtra.evars = cell(0, 1);
modelNoExtra.evarNames = cell(0, 1);
modelNoExtra.evarlb = zeros(0, 1);
modelNoExtra.evarub = zeros(0, 1);
modelNoExtra.evarc = zeros(0, 1);
exoData = struct('exoMet', table({'EX_a'; 'EX_b'}, [5; 3], [1; 1], 'VariableNames', exoColumns));
[printedText, newModel, rxnsConstrained] = runCapturingOutput(modelNoExtra, exoData, etaParam, 'allConstraints', 1);

assert(isequal(rxnsConstrained, {'EX_a'; 'EX_b'}));
assert(norm(model.S * newModel.exometRelaxation.v) < fitTol);
assert(norm(newModel.lb([1 3]) - [4; 2]) < fitTol);
assert(norm(newModel.ub([1 3]) - [6; 4]) < fitTol);
assert(isempty(newModel.exometRelaxation.v_extraVariables));
assert(contains(printedText, '0 measured extra variables.'));

%% allConstraints: small changes of unmeasured variables are dropped unless the model needs them
% e1 <= 1 but v1 = e1 >= 2. The relaxation of e1 is below eta = 10 and e1 is not measured, so it is
% zeroed, which leaves the model infeasible, and the relaxation is taken back
modelSmallChange = modelGecko;
modelSmallChange.lb(1) = 2;
paramEta = paramGecko;
paramEta.eta = 10;
exoData = struct('exoMet', table({'e2'}, 0, 1, 'VariableNames', exoColumns));
[printedText, newModel] = runCapturingOutput(modelSmallChange, exoData, paramEta, 'allConstraints', 0);

assert(contains(printedText, 'only after including small changes to bounds of variables not experimentally measured'));
assert(newModel.evarub(1) >= 2 - fitTol);
assert(~any(newModel.exometRelaxation.evarupperBoundBool));
LP = buildOptProblemFromModel(newModel, true, struct());
sol = solveCobraLP(LP);
assert(sol.stat == 1);

%% allConstraints: an unbounded model is reported like an infeasible one
% maximising v1 without any finite upper bound: the fit is bounded through its quadratic term, but the
% LP on the fitted model is not (no stand-in: gurobi returns INF_OR_UNBD, stat 2)
modelUnbounded = modelGecko;
modelUnbounded.ub = [Inf; Inf];
modelUnbounded.evarub = [Inf; Inf; Inf];
modelUnbounded.c = [1; 0];
modelUnbounded.evarc = [0; 0; 0];
modelUnbounded.osense = -1;
modelUnbounded.osenseStr = 'max';
exoData = struct('exoMet', table({'epool'}, 1, 1, 'VariableNames', exoColumns));
[printedText, newModel] = runCapturingOutput(modelUnbounded, exoData, paramGecko, 'allConstraints', 0);

assert(contains(printedText, 'Fitted model is not feasible for FBA yet.'));
% the infinite bounds end at the default maximum
assert(isequal(newModel.ub, [1000; 1000]));
assert(isequal(newModel.evarub(1:2), [1000; 1000]));

%% allConstraints: a negative SD crosses the bounds, which the last check refuses
modelReversible = modelGecko;
modelReversible.lb(1) = -10;
exoData = struct('exoMet', table({'v1'}, 2, -1, 'VariableNames', exoColumns));
assert(verifyCobraFunctionError('constrainRxns', 'inputs', {modelReversible, exoData, paramGecko, 'allConstraints', 0}, ...
    'testMessage', 'lower bounds greater than upper bounds'));

%% allConstraints: bounds of extra variables are limited and tiny ones are enlarged, keeping their sign
extraLb = [-10; -20; 10; -2; -1e-7; 1e-7; -1; 0];
extraUb = [2; -10; 20; 10; 1; 1; -1e-7; 1e-7];
modelBounds = modelGecko;
nNew = numel(extraLb);
modelBounds.evars = [modelGecko.evars; arrayfun(@(k) sprintf('x%d', k), (1:nNew)', 'UniformOutput', false)];
modelBounds.evarNames = modelBounds.evars;
modelBounds.evarlb = [modelGecko.evarlb; extraLb];
modelBounds.evarub = [modelGecko.evarub; extraUb];
modelBounds.evarc = [modelGecko.evarc; zeros(nNew, 1)];
modelBounds.E = [modelGecko.E, zeros(size(modelGecko.E, 1), nNew)];
modelBounds.D = [modelGecko.D, zeros(size(modelGecko.D, 1), nNew)];
paramBounds = paramGecko;
paramBounds.TolMinBoundary = -5;
paramBounds.TolMaxBoundary = 5;
paramBounds.boundPrecisionLimit = 1e-5;
paramBounds.weightLower_e_default = Inf;
paramBounds.weightUpper_e_default = Inf;
exoData = struct('exoMet', table({'v1'}, 0, 1, 'VariableNames', exoColumns));
newModel = constrainRxns(modelBounds, exoData, paramBounds, 'allConstraints', 0);

limit = paramBounds.boundPrecisionLimit;
assert(norm(newModel.evarlb(4:end) - [-5; -5; 5; -2; -limit; limit; -1; 0]) < tol);
assert(norm(newModel.evarub(4:end) - [2; -5; 5; 5; 1; 1; -limit; limit]) < tol);

fprintf('Done.\n');

% change the directory
cd(currentDir)

function model = buildExchangeModel()
% two metabolites: a is taken up (EX_a) and turned into b (R1), which leaves through a secretion
% (EX_b), a sink, a demand or a reaction that only goes backward (REV_b)
model = struct();
model.mets = {'a'; 'b'};
model.rxns = {'EX_a'; 'R1'; 'EX_b'; 'sink_b'; 'DM_b'; 'REV_b'};
model.rxnNames = model.rxns;
model.S = sparse([1 -1 0 0 0 0; 0 1 -1 -1 -1 1]);
model.lb = [-10; 0; -10; -1; 0; -10];
model.ub = [10; 100; 10; 1; 10; 0];
model.c = zeros(6, 1);
model.b = zeros(2, 1);
model.csense = ['E'; 'E'];
model.osenseStr = 'max';
model.SIntRxnBool = [false; true; false; false; false; false];
model.SinkRxnBool = [false; false; false; true; false; false];
model.DMRxnBool = [false; false; false; false; true; false];
end

function model = buildStarModel(exchanges, coefficients)
% one metabolite between an internal reaction (first column) and many exchanges
nRxn = numel(exchanges) + 1;
model = struct();
model.mets = {'x'};
model.rxns = [{'R1'}; exchanges];
model.rxnNames = model.rxns;
model.S = sparse(coefficients);
model.lb = zeros(nRxn, 1);
model.ub = 10 * ones(nRxn, 1);
model.c = zeros(nRxn, 1);
model.b = 0;
model.csense = 'E';
model.osenseStr = 'max';
model.SIntRxnBool = [true; false(nRxn - 1, 1)];
model.SinkRxnBool = false(nRxn, 1);
model.DMRxnBool = false(nRxn, 1);
end

function [printedText, newModel, rxnsConstrained, rxnBoundsCorrected, newSpecificData] = runCapturingOutput(varargin)
% run constrainRxns and return what it printed: with printLevel > 0 the text is the behaviour under
% test, and warnings are read from it. It cannot be obtained otherwise (Constitution VII-A); white
% space is normalised because long warnings wrap at the width of the command window
printedText = evalc('[newModel, rxnsConstrained, rxnBoundsCorrected, newSpecificData] = constrainRxns(varargin{:});');
printedText = regexprep(printedText, '\s+', ' ');
end
