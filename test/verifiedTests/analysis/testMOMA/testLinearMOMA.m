% The COBRAToolbox: testLinearMOMA.m
%
% Purpose:
%     - linearMOMA solves the linear version of MOMA: among the optimal wild type flux
%       distributions and the feasible deletion strain flux distributions it finds the pair
%       with the smallest sum of absolute flux differences over the common reactions,
%       optionally followed by a second LP that minimises the absolute fluxes of that pair.
%       Quarantined: no behaviour of linearMOMA is asserted until the defects below are fixed.
%
% Function under test:
%     src/analysis/MOMA/linearMOMA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP on a toy model.
%
% Coverage exemptions:
%     every line - linearMOMA is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An infeasible wild type model stops with an error instead of returning a status
%       SEVERITY: error
%       TRIGGER: a wild type model without a feasible flux, e.g. the toy model EX_A ( -> A, ub
%         10), R1 and R2 (A -> B), EX_B (B -> ) with EX_A fixed to -5:
%         linearMOMA(changeRxnBounds(model, 'EX_A', -5, 'b'), modelDel)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the warning "Wild type FBA problem is infeasible
%         or unconstrained" (line 218), then MATLAB:UndefinedFunction "Unrecognized function or
%         variable 'LPsolution'." at line 221: LPsolution is only set inside the branch of a
%         feasible wild type
%       EXPECTED: the warning and solutions with stat ~= 1 (solutionWT and solutionDel are
%         initialised with stat -1 at lines 83-88 for this case), as the warning intends
%       LINES: 217-223
%     - DEFECT: An infeasible deletion model stops with an error when totalFluxDiff or solStatus
%       is requested
%       SEVERITY: error
%       TRIGGER: [solDel, solWT, totalFluxDiff, solStatus] = linearMOMA(model,
%         changeRxnBounds(model, 'EX_A', -5, 'b')) on the toy model above (any call with three
%         or four outputs whose MOMA LP has stat ~= 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:unassignedOutputs "Output argument
%         "totalFluxDiff" (and possibly others) not assigned a value in the execution with
%         "linearMOMA" function."; with two outputs the call returns solDel.stat = 0
%       EXPECTED: totalFluxDiff empty (or NaN) and solStatus = the LP status, so that the
%         documented status output can report the infeasible deletion strain
%       LINES: 163-170
%     - DEFECT: verbFlag together with minFluxFlag stops with an error
%       SEVERITY: error
%       TRIGGER: linearMOMA(model, modelDel, 'max', true, true) with model the toy model above
%         and modelDel = changeRxnBounds(model, 'R1', 0, 'b')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:UndefinedFunction "Unrecognized function
%         or variable 'A'." at line 203: the message prints size(A, 1) and size(A, 2), but the
%         matrix is LPproblem.A
%       EXPECTED: the message with the size of LPproblem.A and the minimal-flux solution
%       LINES: 202-203
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLinearMOMA'));
cd(fileDir);

% declare the requirements of this test; nothing that calls linearMOMA runs while it is
% quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
