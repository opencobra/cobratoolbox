% The COBRAToolbox: testConstrainEcosystemPoint.m
%
% Purpose:
%     - constrainEcosystemPoint returns the community model of a two-member ecosystem
%       structure constrained to a point [f, mu] of the abundance-growth space: the objective
%       reaction of the first member is fixed to f*mu and that of the second to (1-f)*mu. By
%       default the bounds of every reaction of each member are first scaled by the member
%       fraction [f, 1-f] (or by a given pfraction, NaN read as zero); updateBounds false keeps
%       them. A structure without two objectives, or an objective that is not a reaction of the
%       community model, gives an error.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: every expected bound below is computed from the input bounds and the
%       point with the rule of the function header (no first-run value is needed).
%
% Function under test:
%     src/analysis/ecosystem/constrainEcosystemPoint.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the function takes an ecosystem structure, which
%     is hand-built below with the three fields the function reads (model, objectives,
%     memberRxns) around a five-reaction community model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConstrainEcosystemPoint'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a two-member community: member 1 owns org1_R and org1_biomass, member 2 owns org2_R and
% org2_biomass, and EX_A_e is the pool exchange that belongs to no member
communityModel = struct();
communityModel.rxns = {'org1_R'; 'org1_biomass'; 'org2_R'; 'org2_biomass'; 'EX_A_e'};
communityModel.lb = [-10; 0; -4; 0; -1000];
communityModel.ub = [10; 5; 4; 8; 1000];
eco = struct();
eco.model = communityModel;
eco.objectives = {'org1_biomass', 'org2_biomass'};
eco.memberRxns = {{'org1_R'; 'org1_biomass'}, {'org2_R'; 'org2_biomass'}};

% the point: 25% of the community is member 1, community growth rate 0.8
point = [0.25, 0.8];
memberGrowth = [0.25 * 0.8, 0.75 * 0.8];

%% default: member bounds scaled by [f, 1-f], objectives fixed to the member growth rates

modelPoint = constrainEcosystemPoint(eco, point);

% only the bounds change: the reactions and every other field are copied
assert(isequal(modelPoint.rxns, communityModel.rxns));
assert(isequal(size(modelPoint.lb), [5, 1]) && isequal(size(modelPoint.ub), [5, 1]));

% org1_R is scaled by 0.25 and org2_R by 0.75 (products of exactly representable numbers are
% exact, so the comparison is exact); the pool exchange is not scaled
assert(isequal(modelPoint.lb([1, 3, 5]), [-10 * 0.25; -4 * 0.75; -1000]));
assert(isequal(modelPoint.ub([1, 3, 5]), [10 * 0.25; 4 * 0.75; 1000]));

% the objective reactions are fixed to f*mu and (1-f)*mu (same arithmetic as the function)
assert(modelPoint.lb(2) == memberGrowth(1) && modelPoint.ub(2) == memberGrowth(1));
assert(modelPoint.lb(4) == memberGrowth(2) && modelPoint.ub(4) == memberGrowth(2));

% a column point is read as a row, and updateBounds true is the default
assert(isequal(constrainEcosystemPoint(eco, point'), modelPoint));
assert(isequal(constrainEcosystemPoint(eco, point, 'updateBounds', true), modelPoint));

%% updateBounds false: only the objective reactions change

modelPoint = constrainEcosystemPoint(eco, point, 'updateBounds', false);

isObjective = ismember(communityModel.rxns, eco.objectives);
assert(isequal(modelPoint.lb(~isObjective), communityModel.lb(~isObjective)));
assert(isequal(modelPoint.ub(~isObjective), communityModel.ub(~isObjective)));
assert(isequal(modelPoint.lb(isObjective), memberGrowth') && isequal(modelPoint.ub(isObjective), memberGrowth'));

%% pfraction: the given fractions scale the bounds, a NaN fraction counts as zero

modelPoint = constrainEcosystemPoint(eco, point, 'pfraction', [NaN, 0.5]);

% org1_R is closed (NaN read as 0) and org2_R is halved; the objectives still follow the point,
% not pfraction
assert(isequal(modelPoint.lb([1, 3]), [0; -2]) && isequal(modelPoint.ub([1, 3]), [0; 2]));
assert(modelPoint.lb(2) == memberGrowth(1) && modelPoint.ub(4) == memberGrowth(2));
assert(modelPoint.lb(5) == -1000 && modelPoint.ub(5) == 1000);

% an empty pfraction falls back to [f, 1-f]
assert(isequal(constrainEcosystemPoint(eco, point, 'pfraction', []), constrainEcosystemPoint(eco, point)));

%% errors: wrong number of members, unknown objective, invalid inputs

threeMembers = eco;
threeMembers.objectives = {'org1_biomass', 'org2_biomass', 'EX_A_e'};
assert(verifyCobraFunctionError('constrainEcosystemPoint', 'inputs', {threeMembers, point}, ...
    'testMessage', 'Only communities of two members are supported.'));

unknownObjective = eco;
unknownObjective.objectives = {'org1_biomass', 'org3_biomass'};
assert(verifyCobraFunctionError('constrainEcosystemPoint', 'inputs', {unknownObjective, point}, ...
    'testMessage', 'Objective reaction org3_biomass not found in the community model.'));

% the input parser rejects a structure without objectives and a point with three entries
assert(verifyCobraFunctionError('constrainEcosystemPoint', 'inputs', {rmfield(eco, 'objectives'), point}));
assert(verifyCobraFunctionError('constrainEcosystemPoint', 'inputs', {eco, [0.25, 0.8, 1]}));

% change the directory
cd(currentDir)
