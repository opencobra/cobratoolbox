% The COBRAToolbox: testClassifyRxns.m
%
% Purpose:
%     - classifyRxns scores, for each metabolite and each sampled flux point, the reactions
%       around the metabolite by the fraction of the total incoming (or outgoing) flux that they
%       carry, and records the direction of each reaction and whether the metabolite is used.
%       This test uses a five-reaction branch point A -> B, A -> C and hand-written flux points
%       whose scores, directions and usage flags are worked out by hand; it also checks the
%       truncation to maxNumPnts, the zeroing of fluxes below 1e-10, the exclusion of highly
%       connected metabolites and of metabolites touching loop reactions, the progress output
%       and the error for a flux point that does not balance a metabolite.
%
% Function under test:
%     src/analysis/rumba/classifyRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model and hand-written flux points, no solver.
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
fileDir = fileparts(which('testClassifyRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% showprogress (verboseTag = 1) creates globals; remove them at the end
globalsBefore = who('global');

% branch point: A is taken up (r1) and split into B (r2) and C (r3), which leave (r4, r5)
completeModel = createModel({'r1', 'r2', 'r3', 'r4', 'r5'}, {'r1', 'r2', 'r3', 'r4', 'r5'}, ...
    {' -> A', 'A -> B', 'A -> C', 'B -> ', 'C -> '}, 'printLevel', 0);
metA = 'Met_A_p1_c_p2_';
metB = 'Met_B_p1_c_p2_';
metC = 'Met_C_p1_c_p2_';

% flux points in the order r1..r5 (columns): point 1 splits 2:1 towards C, point 2 sends all
% flux to B (r3 and r5 carry 1e-12, below the 1e-10 threshold), point 3 is zero, and point 4
% does not balance A (in 5, out 2) and must be cut by maxNumPnts = 3
points = [3 1 2 1 2; 4 4 1e-12 4 1e-12; 0 0 0 0 0; 5 1 1 1 1]';
% the sampled model lists the reactions in reverse order: the scores must follow the names
sampledModel.rxns = flipud(completeModel.rxns);
sampledModel.points = flipud(points);

%% scores, directions and usage of every metabolite (maxNumPnts = 3)

[metConnectivity, connectedMet] = classifyRxns(completeModel, sampledModel, 30, 3, 0, {});

% bracket characters of the identifiers are replaced to make valid field names
assert(isequal(connectedMet, {metA; metB; metC}));
assert(isequal(sort(fieldnames(metConnectivity)), sort({metA; metB; metC})));

% A: produced by r1, consumed by r2 and r3. Point 1: in 3, out 1 + 2 -> r1 scores 3/3,
% r2 scores 1/3, r3 scores 2/3; point 2: r1 and r2 score 1, r3 carries 1e-12 -> 0; point 3: unused.
% tolerance 1e-12: the scores are ratios of small integers computed in double precision
connA = metConnectivity.(metA);
assert(isequal(connA.ConnRxns, {'r1'; 'r2'; 'r3'}));
assert(isequal(connA.Sij, [1; -1; -1]));
assert(max(max(abs(connA.RxnScore - [1 1 0; 1/3 1 0; 2/3 0 0]))) < 1e-12);
assert(isequal(connA.Direction, [1 1 0; -1 -1 0; -1 0 0]));
assert(isequal(connA.MetNotUsed, [0 0 1]));

% B: produced by r2, consumed by r4, balanced in points 1 and 2; scores are exact (1)
connB = metConnectivity.(metB);
assert(isequal(connB.ConnRxns, {'r2'; 'r4'}) && isequal(connB.Sij, [1; -1]));
assert(isequal(connB.RxnScore, [1 1 0; 1 1 0]));
assert(isequal(connB.Direction, [1 1 0; -1 -1 0]));
assert(isequal(connB.MetNotUsed, [0 0 1]));

% C: produced by r3, consumed by r5; the 1e-12 fluxes of point 2 are set to zero, so C is
% unused in points 2 and 3
connC = metConnectivity.(metC);
assert(isequal(connC.ConnRxns, {'r3'; 'r5'}) && isequal(connC.Sij, [1; -1]));
assert(isequal(connC.RxnScore, [1 0 0; 1 0 0]));
assert(isequal(connC.Direction, [1 0 0; -1 0 0]));
assert(isequal(connC.MetNotUsed, [0 1 1]));

%% highly connected metabolites and loop reactions are left out; progress output

% A is in 3 reactions (> maxMetConn = 2), so it gets no entry; C touches the loop reaction r5,
% so it keeps its connectivity entry but is not scored; only B is scored
[metConnectivity, connectedMet] = classifyRxns(completeModel, sampledModel, 2, 3, 1, {'r5'});
assert(isequal(connectedMet, {metB}));
assert(~isfield(metConnectivity, metA));
assert(isfield(metConnectivity, metC) && ~isfield(metConnectivity.(metC), 'RxnScore'));
assert(isequal(metConnectivity.(metC).ConnRxns, {'r3'; 'r5'}));
assert(isequal(metConnectivity.(metB).RxnScore, [1 1 0; 1 1 0]));

%% a flux point that does not balance a metabolite is an error

% with maxNumPnts = 4 the unbalanced point 4 is kept (A: in 5, out 2)
assert(verifyCobraFunctionError('classifyRxns', 'inputs', {completeModel, sampledModel, 30, 4, 0, {}}, ...
    'testMessage', ['ERROR: the flux in and out of ' metA ' isn''t equal']));

% remove the globals created by showprogress
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clear('global', newGlobals{k});
end

% change the directory
cd(currentDir)
