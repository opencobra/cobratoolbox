% The COBRAToolbox: testFindExcRxns.m
%
% Purpose:
%     - findExcRxns flags the exchange reactions (one non-zero coefficient of +1 or -1 in the
%       column of S, objective reactions removed unless inclObjFlag) and the uptake reactions
%       (exchanges with a negative lower bound; in irreversible format the single +1 columns).
%       This test checks every branch on a hand-built eight-reaction model that holds one column
%       of each kind (single -1 with and without a negative lower bound, single +1, internal
%       columns, a single coefficient of -2, an objective exchange, an empty column), with and
%       without the fields c and lb, in reversible and irreversible format, and then on the
%       E. coli core model where the 20 EX_ reactions must be the exchanges and the 7 with a
%       negative lower bound the uptakes. Expected values are worked out by hand from S, c and lb.
%
% Function under test:
%     src/analysis/exploration/findExcRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a hand-built eight-reaction model reaches every
%     branch, and ecoli_core_model (getDistributedModel, loaded once) confirms the rule on a
%     real model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindExcRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: eight reactions, one column of each kind

%                   EX_A EX_B SK_C  R1  R2 DM_A2 OBJ ZERO
model.S = sparse([   -1    0    0   1   0   -2    0   0;    % A[e]
                      0   -1    0  -1   1    0    0   0;    % B[e]
                      0    0    1   0  -1    0   -1   0]);  % C[e]
model.mets = {'A[e]'; 'B[e]'; 'C[e]'};
model.rxns = {'EX_A'; 'EX_B'; 'SK_C'; 'R1'; 'R2'; 'DM_A2'; 'OBJ'; 'ZERO'};
model.lb = [-10; 0; -5; 0; -1000; 0; -1; 0];
model.ub = 1000 * ones(8, 1);
model.c = [0; 0; 0; 0; 0; 0; 1; 0];
model.b = zeros(3, 1);
model.csense = repmat('E', 3, 1);
% structural consistency of the fixture
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(isequal(numel(model.lb), numel(model.ub), numel(model.c), numel(model.rxns)));
assert(numel(model.b) == numel(model.mets) && numel(model.csense) == numel(model.mets));

% by hand: EX_A, EX_B, SK_C and OBJ have a single coefficient of +1 or -1; R1 and R2 are
% internal, DM_A2 has a single coefficient of -2, ZERO has none
isSingleUnitColumn = logical([1; 1; 1; 0; 0; 0; 1; 0]);

%% reversible format, default flags: objective removed, uptakes need a negative lower bound

[selExc, selUpt] = findExcRxns(model);
% the outputs are logical columns with one entry per reaction
assert(islogical(selExc) && iscolumn(selExc) && numel(selExc) == numel(model.rxns));
assert(islogical(selUpt) && iscolumn(selUpt) && numel(selUpt) == numel(model.rxns));
% OBJ carries the objective, so it is removed from the exchanges
assert(isequal(selExc, logical([1; 1; 1; 0; 0; 0; 0; 0])));
% EX_A (lb -10) and SK_C (lb -5) are the uptakes; EX_B has lb 0; OBJ is no longer an exchange
assert(isequal(selUpt, logical([1; 0; 1; 0; 0; 0; 0; 0])));
% the same result with the flags given explicitly
[selExcExplicit, selUptExplicit] = findExcRxns(model, false, false);
assert(isequal(selExcExplicit, selExc) && isequal(selUptExplicit, selUpt));

%% reversible format, inclObjFlag: the objective reaction is added to the exchanges

[selExc, selUpt] = findExcRxns(model, true);
assert(isequal(selExc, isSingleUnitColumn));
% OBJ has lb -1, so once it counts as an exchange it is also an uptake
assert(isequal(selUpt, logical([1; 0; 1; 0; 0; 0; 1; 0])));

%% a model without c: no objective handling; without lb: no uptake vector

modelNoObjective = rmfield(model, 'c');
[selExc, selUpt] = findExcRxns(modelNoObjective);
% nothing is removed, so OBJ stays an exchange and (lb -1) an uptake
assert(isequal(selExc, isSingleUnitColumn));
assert(isequal(selUpt, logical([1; 0; 1; 0; 0; 0; 1; 0])));
modelNoBounds = rmfield(model, 'lb');
[selExc, selUpt] = findExcRxns(modelNoBounds);
assert(isequal(selExc, logical([1; 1; 1; 0; 0; 0; 0; 0])));
% without lower bounds the uptakes cannot be determined and the output is empty
assert(isempty(selUpt));

%% irreversible format: uptakes are the single +1 columns, whatever the bounds and objective

[selExc, selUpt] = findExcRxns(model, false, true);
assert(isequal(selExc, logical([1; 1; 1; 0; 0; 0; 0; 0])));
% only SK_C has a single coefficient of +1
assert(islogical(selUpt) && isequal(selUpt, logical([0; 0; 1; 0; 0; 0; 0; 0])));
% with the objective included
[selExc, selUpt] = findExcRxns(model, true, true);
assert(isequal(selExc, isSingleUnitColumn));
assert(isequal(selUpt, logical([0; 0; 1; 0; 0; 0; 0; 0])));
% without c nothing is removed
[selExc, selUpt] = findExcRxns(modelNoObjective, false, true);
assert(isequal(selExc, isSingleUnitColumn));
assert(isequal(selUpt, logical([0; 0; 1; 0; 0; 0; 0; 0])));

%% E. coli core: the 20 EX_ reactions are the exchanges, the 7 with lb < 0 the uptakes

ecoliModel = getDistributedModel('ecoli_core_model.mat');
isExchangeByName = ~cellfun(@isempty, regexp(ecoliModel.rxns, '^EX_', 'once'));
[selExc, selUpt] = findExcRxns(ecoliModel);
% every EX_ reaction has a single coefficient of -1 and no other reaction has a single
% coefficient, so the structural rule reproduces the naming convention
assert(isequal(selExc, isExchangeByName) && sum(selExc) == 20);
assert(isequal(selUpt, isExchangeByName & ecoliModel.lb < 0) && sum(selUpt) == 7);
assert(isequal(ecoliModel.rxns(selUpt), {'EX_co2(e)'; 'EX_glc(e)'; 'EX_h(e)'; 'EX_h2o(e)'; ...
    'EX_nh4(e)'; 'EX_o2(e)'; 'EX_pi(e)'}));
% including the objective adds the biomass reaction, whose lower bound is 0
[selExcWithObjective, selUptWithObjective] = findExcRxns(ecoliModel, true);
assert(isequal(selExcWithObjective, isExchangeByName | ecoliModel.c ~= 0) && sum(selExcWithObjective) == 21);
assert(isequal(selUptWithObjective, selUpt));
clear ecoliModel

% change the directory
cd(currentDir)
