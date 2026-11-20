% The COBRAToolbox: testSetEcosystemPoolBounds.m
%
% Purpose:
%     - setEcosystemPoolBounds sets the [lower, upper] bounds of the pool exchange reaction of
%       each named exchanged metabolite of an ecosystem structure and, when bioCons is given and
%       the new pool lower bound is non-positive, sets the lower bound of the exchange reaction
%       of every member that has one to bioCons. Metabolites that are not in the pool are
%       skipped with a warning, and the list of non-blocked reactions is reset. This test
%       checks one and several metabolites, a single bounds row applied to all, the bioCons
%       rule on both sides of zero, a member without the exchange, the skip warning, and every
%       error the function raises. Expected bounds are the inputs themselves (the function
%       copies numbers, so comparisons are exact).
%
% Function under test:
%     src/analysis/ecosystem/setEcosystemPoolBounds.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; the ecosystem structure is hand-built with the fields the function
%     reads (model.rxns/lb/ub and exchangeInfo.mets/poolRxns/memberRxns) around an
%     eight-reaction community model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetEcosystemPoolBounds'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two members exchanging A_e and B_e through the pool; member 2 has no exchange of B_e
% reactions: 1 EX_A_e_pool, 2 EX_B_e_pool, 3 org1_EX_A_e, 4 org2_EX_A_e, 5 org1_EX_B_e,
% 6 org1_R1, 7 org2_R1, 8 org1_biomass
communityModel = struct();
communityModel.rxns = {'EX_A_e_pool'; 'EX_B_e_pool'; 'org1_EX_A_e'; 'org2_EX_A_e'; ...
    'org1_EX_B_e'; 'org1_R1'; 'org2_R1'; 'org1_biomass'};
communityModel.lb = [-1000; -1000; -1000; -1000; -1000; 0; 0; 0];
communityModel.ub = 1000 * ones(8, 1);
eco = struct();
eco.model = communityModel;
eco.exchangeInfo = struct('mets', {{'A_e'; 'B_e'}}, ...
    'poolRxns', {{'EX_A_e_pool'; 'EX_B_e_pool'}}, ...
    'memberRxns', {{'org1_EX_A_e', 'org2_EX_A_e'; 'org1_EX_B_e', ''}});
eco.nonBlocked = {'org1_R1'};

%% one metabolite, no bioCons: only the pool exchange changes, nonBlocked is reset

ecoOut = setEcosystemPoolBounds(eco, {'A_e'}, [-10 20]);
assert(ecoOut.model.lb(1) == -10 && ecoOut.model.ub(1) == 20);
% every other bound is unchanged
assert(isequal(ecoOut.model.lb(2:end), communityModel.lb(2:end)));
assert(isequal(ecoOut.model.ub(2:end), communityModel.ub(2:end)));
assert(isempty(ecoOut.nonBlocked));
% bioCons given as empty is the same as no bioCons; a character vector is one metabolite
assert(isequal(setEcosystemPoolBounds(eco, 'A_e', [-10 20], []), ecoOut));
assert(isequal(setEcosystemPoolBounds(eco, "A_e", [-10 20]), ecoOut));

%% bioCons with a non-positive pool lower bound: member exchanges get bioCons as lower bound

ecoOut = setEcosystemPoolBounds(eco, {'A_e'}, [0 1000], -5);
assert(ecoOut.model.lb(1) == 0 && ecoOut.model.ub(1) == 1000);
% both member exchanges of A_e, and nothing else, have the lower bound -5
assert(isequal(ecoOut.model.lb, [0; -1000; -5; -5; -1000; 0; 0; 0]));
assert(isequal(ecoOut.model.ub, communityModel.ub));

%% bioCons with a positive pool lower bound: member exchanges are not changed

ecoOut = setEcosystemPoolBounds(eco, {'A_e'}, [1 2], -5);
assert(isequal(ecoOut.model.lb, [1; -1000; -1000; -1000; -1000; 0; 0; 0]));
assert(ecoOut.model.ub(1) == 2);

%% several metabolites: one bounds row per metabolite, or one row for all

% B_e has an empty member entry for member 2, which is ignored
ecoOut = setEcosystemPoolBounds(eco, {'A_e', 'B_e'}, [-10 10; -3 4], -2);
assert(isequal(ecoOut.model.lb, [-10; -3; -2; -2; -2; 0; 0; 0]));
assert(isequal(ecoOut.model.ub, [10; 4; 1000; 1000; 1000; 1000; 1000; 1000]));

% a single row is applied to every metabolite
ecoOut = setEcosystemPoolBounds(eco, {'A_e', 'B_e'}, [-7 7]);
assert(isequal(ecoOut.model.lb(1:2), [-7; -7]) && isequal(ecoOut.model.ub(1:2), [7; 7]));

%% a metabolite that is not in the pool is skipped with a warning, the others are set

lastwarn('');
ecoOut = setEcosystemPoolBounds(eco, {'C_e', 'B_e'}, [-1 1]);
[warningText, ~] = lastwarn();
assert(strcmp(warningText, 'C_e is not a part of pool metabolites. Skipping it.'));
assert(isequal(ecoOut.model.lb, [-1000; -1; -1000; -1000; -1000; 0; 0; 0]));
assert(ecoOut.model.ub(2) == 1);

%% errors for missing or invalid inputs

assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}}, ...
    'testMessage', 'eco, poolMets and poolBounds must be provided.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {1, {'A_e'}, [0 1]}, ...
    'testMessage', 'eco must be an ecosystem structure created with createEcosystemModel.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', ...
    {struct('model', communityModel), {'A_e'}, [0 1]}, ...
    'testMessage', 'eco must be an ecosystem structure created with createEcosystemModel.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', ...
    {struct('exchangeInfo', eco.exchangeInfo), {'A_e'}, [0 1]}, ...
    'testMessage', 'eco must be an ecosystem structure created with createEcosystemModel.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, 1, [0 1]}, ...
    'testMessage', 'poolMets must be a cell array of strings.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [0 1 2]}, ...
    'testMessage', 'poolBounds must be a n x 2 numeric matrix.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, {0, 1}}, ...
    'testMessage', 'poolBounds must be a n x 2 numeric matrix.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', ...
    {eco, {'A_e', 'B_e', 'C_e'}, [0 1; 0 1]}, ...
    'testMessage', 'The number of rows of poolBounds must be equal to the number of metabolites.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [0 1], [1 2]}, ...
    'testMessage', 'bioCons must be a numeric scalar or empty.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [0 1], 'a'}, ...
    'testMessage', 'bioCons must be a numeric scalar or empty.'));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [1 0]}, ...
    'testMessage', 'Lower bounds must be lower than or equal to upper bounds.'));

% change the directory
cd(currentDir)
