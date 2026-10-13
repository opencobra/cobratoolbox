% The COBRAToolbox: testProcessConcConstraints.m
%
% Purpose:
%     - processConcConstraints derives the concentration bounds, weights, external stoichiometry and
%     mass-balance bounds that an entropic flux balance problem needs from a COBRA model and a
%     parameter structure, applying defaults and checking options.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/entropicFBA/processConcConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 261-278, the statements of the case externalNetFluxBounds = dxReplacement below its
%     first statement: the case starts with an error call, so they can never run. Lines 374,
%     379-382, the defaults for the gas constant and the temperature: they sit inside a block that
%     is only entered when both are present in the model.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The default row selection indexes the first row repeatedly
%       SEVERITY: wrong-result
%       TRIGGER: a model without the field pp, with external reactions
%       OBSERVED: the default pp is a numeric vector of ones, and indexing the external
%         stoichiometric matrix with it repeats row 1 for every metabolite instead of selecting all
%         rows
%       EXPECTED: the default pp should be a logical vector of ones (true for all rows) so that all
%         rows are kept
%       LINES: 116-118, 297
%     - DEFECT: The parameter printLevel is required although it is documented as optional
%       SEVERITY: error
%       TRIGGER: a parameter structure without printLevel when the model has external reactions and
%         externalNetFluxBounds is original or none
%       OBSERVED: the field is read without a default, so the call stops with "Unrecognized field
%         name printLevel"
%       EXPECTED: printLevel defaulting to 0
%       LINES: 161, 224
%     - DEFECT: The case dxReplacement always stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: param.externalNetFluxBounds = dxReplacement, or model.dcl or model.dcu present
%         without an explicit option
%       OBSERVED: the case begins with error(revise how net initial and final conc bounds are dealt
%         with), so the option can never be used; this is also the default when model.dcl or
%         model.dcu exists
%       EXPECTED: the external net flux bounds replaced by concentration differences, as documented
%       LINES: 245-262
%     - DEFECT: Documented defaults for the concentration unit and the maximum concentration differ
%         from the code
%       SEVERITY: cosmetic
%       TRIGGER: param without concUnit and maxConc
%       OBSERVED: concUnit is set to 10-3, which evaluates to 7, and maxConc is set to infinity,
%         while the header states 1e-3 and 1e4
%       EXPECTED: the documented defaults
%       LINES: 131-137
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProcessConcConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% three metabolites, two internal reactions and one external reaction (an exchange of metabolite 1)
model.S = [-1  0 -1; ...
            1 -1  0; ...
            0  1  0];
model.rxns = {'r1'; 'r2'; 'EX_m1'};
model.mets = {'m1'; 'm2'; 'm3'};
model.c = [0; 0; 0];
model.lb = [0; 0; -10];
model.ub = [100; 100; 10];
model.SConsistentRxnBool = [true; true; false];
model.pp = true(3, 1);
param = struct('printLevel', 0);

%% defaults

[f, u0, c0l, c0u, l_c, u_c, dcl, dcu, l_w, u_w, B, b, l_r, u_r, paramOut] = processConcConstraints(model, param);
assert(isequal(f, ones(3, 1)) && isequal(u0, zeros(3, 1)));
assert(isequal(c0l, zeros(3, 1)) && all(isinf(c0u)) && all(c0u > 0));
assert(isequal(l_c, zeros(3, 1)) && all(isinf(u_c)) && all(u_c > 0));
% the original external bounds and no concentration differences
assert(l_w == -10 && u_w == 10);
assert(isequal(dcl, zeros(3, 1)) && isequal(dcu, zeros(3, 1)));
assert(isequal(B, [-1; 0; 0]) && isequal(b, zeros(3, 1)));
% no mass balance penalty: the regularisation term is fixed at zero
assert(isequal(l_r, zeros(3, 1)) && isequal(u_r, zeros(3, 1)));
assert(strcmp(paramOut.externalNetFluxBounds, 'original') && strcmp(paramOut.massBalancePenalty, 'none'));
assert(strcmp(paramOut.concentrationBounds, 'none'));

%% model with the right-hand side of the mass balance

withB = model;
withB.b = [1; 2; 3];
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, b, ~, ~] = processConcConstraints(withB, param);
assert(isequal(b, [1; 2; 3]));
% only the independent rows
withB.pp = [true; false; true];
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, B, b, l_r, u_r] = processConcConstraints(withB, param);
assert(isequal(b, [1; 3]) && isequal(B, [-1; 0]) && isequal(size(l_r), [2 1]) && isequal(size(u_r), [2 1]));

%% messages for the external net flux bounds at print level 1

text = evalc("processConcConstraints(model, struct('printLevel', 1));");
assert(contains(text, 'Using existing external net flux bounds without modification.'));
text = evalc("processConcConstraints(model, struct('printLevel', 1, 'externalNetFluxBounds', 'none'));");
assert(contains(text, 'Using no external net flux bounds.'));

%% external net flux options

[~, ~, ~, ~, ~, ~, dcl, dcu, l_w, u_w, ~, ~, ~, ~] = processConcConstraints(model, struct('printLevel', 0, 'externalNetFluxBounds', 'none'));
assert(isinf(l_w) && l_w < 0 && isinf(u_w) && u_w > 0 && isequal(dcl, zeros(3, 1)) && isequal(dcu, zeros(3, 1)));
[~, ~, ~, ~, ~, ~, dcl, dcu, l_w, u_w, B, ~, ~, ~] = processConcConstraints(model, struct('printLevel', 0, 'externalNetFluxBounds', 'bReplacingB'));
assert(l_w == 0 && u_w == 0 && isequal(B, zeros(3, 1)) && isequal(dcl, zeros(3, 1)));

%% identities: single-metabolite external reactions become concentration differences

text = evalc("[~, ~, ~, ~, ~, ~, dcl, dcu, l_w, u_w, B] = processConcConstraints(model, struct('printLevel', 0, 'externalNetFluxBounds', 'identities'));");
% the exchange removes metabolite 1: concentration difference between -ub and -lb
assert(isequal(dcl, [-10; 0; 0]) && isequal(dcu, [10; 0; 0]));
assert(isequal(size(l_w), [6 1]) && all(isinf(l_w)) && all(isinf(u_w)));
assert(isequal(full(B), [-eye(3), eye(3)]));
assert(contains(text, 'Ingnoring the following external reactions'));

%% identities with an import reaction (positive coefficient)

importModel = model;
importModel.S(:, 3) = [1; 0; 0];
evalc("[~, ~, ~, ~, ~, ~, dcl, dcu] = processConcConstraints(importModel, struct('printLevel', 0, 'externalNetFluxBounds', 'identities'));");
% a positive coefficient takes the bounds of the reaction as they are
assert(isequal(dcl, [-10; 0; 0]) && isequal(dcu, [10; 0; 0]));

%% a model without the field pp still gives results of the right size

noPP = rmfield(model, 'pp');
[f, u0, ~, ~, ~, ~, ~, ~, ~, ~, B, b] = processConcConstraints(noPP, param);
assert(numel(f) == 3 && numel(u0) == 3 && size(B, 2) == 1 && numel(b) == 3);

%% no external reactions

internalOnly = model;
internalOnly.S = model.S(:, 1:2);
internalOnly.c = internalOnly.c(1:2);
internalOnly.lb = internalOnly.lb(1:2);
internalOnly.ub = internalOnly.ub(1:2);
internalOnly.SConsistentRxnBool = [true; true];
internalOnly.rxns = internalOnly.rxns(1:2);
[~, ~, ~, ~, ~, ~, dcl, dcu, l_w, u_w] = processConcConstraints(internalOnly, param);
assert(isempty(l_w) && isempty(u_w) && all(isinf(dcl)) && all(dcl < 0) && all(isinf(dcu)) && all(dcu > 0));

%% inconsistent reactions with several metabolites are reported

multi = model;
multi.S(:, 3) = [-1; 1; 0];
text = evalc("processConcConstraints(multi, param);");
assert(contains(text, '1 stoichiometrically inconsistent reactions involving more than one metabolite'));
% more than ten of them: only the first ten are listed
many = model;
many.S = [model.S(:, 1:2), repmat([-1; 1; 0], 1, 12)];
many.rxns = [model.rxns(1:2); arrayfun(@(i) sprintf('x%d', i), 1:12, 'UniformOutput', false)'];
many.c = zeros(14, 1);
many.lb = zeros(14, 1);
many.ub = ones(14, 1);
many.SConsistentRxnBool = [true; true; false(12, 1)];
text = evalc("processConcConstraints(many, param);");
assert(contains(text, '12 stoichiometrically inconsistent reactions involving more than one metabolite'));
assert(contains(text, 'x10') && ~contains(text, 'x11'));

%% unrecognised or unusable options

verifyCobraFunctionError('processConcConstraints', 'inputs', {model, struct('printLevel', 0, 'externalNetFluxBounds', 'bad')}, ...
    'testMessage', 'is an unrecognised input');
verifyCobraFunctionError('processConcConstraints', 'inputs', {model, struct('printLevel', 0, 'externalNetFluxBounds', 'dxReplacement')}, ...
    'testMessage', 'revise how net initial and final conc bounds are dealt with');
% the original bounds clash with concentration differences
clash = model;
clash.dcl = [1; 0; 0];
verifyCobraFunctionError('processConcConstraints', 'inputs', {clash, struct('printLevel', 0, 'externalNetFluxBounds', 'original')}, ...
    'testMessage', 'Option clash between param.externalNetFluxBounds');
% the default option becomes dxReplacement when concentration differences are given
verifyCobraFunctionError('processConcConstraints', 'inputs', {clash, struct('printLevel', 0)}, ...
    'testMessage', 'revise how net initial and final conc bounds are dealt with');

%% mass balance penalty

[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, l_r, u_r] = processConcConstraints(model, struct('printLevel', 0, 'massBalancePenalty', 'quadratic'));
assert(all(isinf(l_r)) && all(l_r < 0) && all(isinf(u_r)) && all(u_r > 0) && numel(l_r) == 3);
% the older option names
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, l_r, ~, paramOut] = processConcConstraints(model, struct('printLevel', 0, 'qpMassBalance', 'quadratic'));
assert(all(isinf(l_r)) && strcmp(paramOut.massBalancePenalty, 'quadratic'));
[~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, ~, l_r, ~, paramOut] = processConcConstraints(model, struct('printLevel', 0, 'strictMassBalance', true));
% the older flag only sets qpMassBalance in the output, the penalty stays at none
assert(all(l_r == 0) && paramOut.qpMassBalance == false);
verifyCobraFunctionError('processConcConstraints', 'inputs', {model, struct('printLevel', 0, 'massBalancePenalty', 'cubic')}, ...
    'testMessage', 'is an unrecognised input');

%% concentration bounds

withBounds = model;
withBounds.c0l = [1; 1; 1];
withBounds.c0u = [5; 5; 5];
withBounds.l_c = [2; 2; 2];
withBounds.u_c = [4; 4; 4];
[~, ~, c0l, c0u, l_c, u_c, ~, ~, ~, ~, ~, ~, ~, ~, paramOut] = processConcConstraints(withBounds, param);
assert(isequal(c0l, [1; 1; 1]) && isequal(c0u, [5; 5; 5]) && isequal(l_c, [2; 2; 2]) && isequal(u_c, [4; 4; 4]));
assert(strcmp(paramOut.concentrationBounds, 'setToGiven'));
% finite range from the parameters
[~, ~, c0l, c0u, l_c, u_c] = processConcConstraints(model, struct('printLevel', 0, 'concentrationBounds', 'maximimumFiniteRange', 'minConc', 1e-4, 'maxConc', 1e4));
assert(isequal(l_c, 1e-4 * ones(3, 1)) && isequal(u_c, 1e4 * ones(3, 1)) && isequal(c0u, 1e4 * ones(3, 1)) && isequal(c0l, zeros(3, 1)));
verifyCobraFunctionError('processConcConstraints', 'inputs', {model, struct('printLevel', 0, 'concentrationBounds', 'wrong')}, ...
    'testMessage', 'unrecognised option for param.concentrationBounds');

%% standard transformed Gibbs energy u0

[~, u0] = processConcConstraints(setfield(model, 'u0', 'one'), param); %#ok<SFLD>
assert(isequal(u0, ones(3, 1)));
[~, u0] = processConcConstraints(setfield(model, 'u0', 'zero'), param); %#ok<SFLD>
assert(isequal(u0, zeros(3, 1)));
[~, u0] = processConcConstraints(setfield(model, 'u0', 'rand'), param); %#ok<SFLD>
assert(isequal(size(u0), [3 1]) && all(u0 >= 0 & u0 <= 1));
[~, u0] = processConcConstraints(setfield(model, 'u0', [1 2 3]), param); %#ok<SFLD>
assert(isequal(u0, [1; 2; 3]));
[~, u0] = processConcConstraints(setfield(model, 'u0', 2), param); %#ok<SFLD>
assert(isequal(u0, [2; 2; 2]));
% divided by gas constant times temperature when both are given
scaled = model;
scaled.u0 = [1; 2; 3];
scaled.gasConstant = 8.3144621e-3;
scaled.T = 300;
[~, u0] = processConcConstraints(scaled, param);
assert(norm(u0 - [1; 2; 3] / (8.3144621e-3 * 300)) < tol);
verifyCobraFunctionError('processConcConstraints', 'inputs', {setfield(model, 'u0', 'bad'), param}, ...
    'testMessage', 'unrecognised option for model.u0'); %#ok<SFLD>
verifyCobraFunctionError('processConcConstraints', 'inputs', {setfield(model, 'u0', [1 2]), param}, ...
    'testMessage', 'model.u0 is of incorrect dimension'); %#ok<SFLD>
verifyCobraFunctionError('processConcConstraints', 'inputs', {setfield(model, 'u0', [1 Inf 3]), param}, ...
    'testMessage', 'u0 must be finite'); %#ok<SFLD>

%% weights f

[f] = processConcConstraints(setfield(model, 'f', 'two'), param); %#ok<SFLD>
assert(isequal(f, 2 * ones(3, 1)));
[f] = processConcConstraints(setfield(model, 'f', 'one'), param); %#ok<SFLD>
assert(isequal(f, ones(3, 1)));
f = processConcConstraints(setfield(model, 'f', 'rand'), param); %#ok<SFLD>
% the random weights are N' * rand(m,1) and have the length of the internal reactions
assert(numel(f) == 2);
f = processConcConstraints(setfield(model, 'f', [1; 2; 3]), param); %#ok<SFLD>
assert(isequal(f, [1; 2; 3]));
f = processConcConstraints(setfield(model, 'f', 4), param); %#ok<SFLD>
assert(isequal(f, 4 * ones(3, 1)));
verifyCobraFunctionError('processConcConstraints', 'inputs', {setfield(model, 'f', [1; Inf; 3]), param}, ...
    'testMessage', 'f must all be finite'); %#ok<SFLD>

% change the directory
cd(currentDir)
