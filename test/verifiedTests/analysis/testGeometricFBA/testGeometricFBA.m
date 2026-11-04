% The COBRAToolbox: testGeometricFBA.m
%
% Purpose:
%     - Tests whether geometricFBA works as intended.
%
% Function under test:
%     src/analysis/geometricFBA/geometricFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on toy models.
%
% Coverage exemptions:
%     Line 178: unreachable, this LP keeps the feasible point of the previous LP and limits every variable through the sum of deviations, so it always converges.
%     Line 184: unreachable, this LP keeps the feasible point of the previous LP and limits every variable through the sum of deviations, so it always converges.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model with a unique optimum stops with an error
%       SEVERITY: error
%       TRIGGER: geometricFBA(model) when every reaction is fixed by the first flux variability
%         loop, for example -> A, A -> with the second reaction as objective and a finite uptake
%       OBSERVED: the output is only assigned in the iteration loop, which is then not entered, so
%         the call stops with "Output argument flux (and possibly others) not assigned a value"
%       EXPECTED: the unique flux vector
%       LINES: 215
%
% Authors:
%     - Thomas Pfau, Oct 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.


% save the current path
currentDir = pwd;

% The testmodel used is structured as follows:
%
%   <-> A -> B ---> C --> E <->
%        \               ^
%         \             /
%           -> F -->  G
%
% Thus the flux can be split between A -> B -> C -> E and A -> F -> G -> E

% load the test models
model = createToyModelForGeoFBA();
% model with Constraints
modelWConst = addCOBRAConstraints(model,{'R1'},400); % R1 restricted to a maximum flux of 400

%When detectDeadEnds is changed according to Ronans suggestion, we need to test
%multiple solvers.
solverPkgs = prepareTest('needsLP', true, 'minimalMatlabSolverVersion',8.0, 'excludeSolvers',{'pdco','ddqMinos','quadMinos','matlab'});
tol = 1e-4;
for k = 1:length(solverPkgs.LP)
    % set the solver
    changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    fprintf('Testing geometricFBA with solver %s ...\n',solverPkgs.LP{k});    
    sol = geometricFBA(model);
    assert(all(abs(sol(1:6) - 500) < tol))
    sol = geometricFBA(modelWConst);
    % flux is now centered between 0 and 400 for R11.. R3 and between 600
    % and 1000 for R4..6
    assert(all(abs(sol(1:3) - 200) < tol))
    assert(all(abs(sol(4:6) - 800) < tol))    

    %% reactions whose range collapses to zero, and reactions without any limit

    % in, ab and out carry the fixed flux of 10. Reaction dead is blocked: its range is [0, 0] in the
    % first loop. The loop l1 to l3 has the range [-1000, 1000] and the cycle u1, u2 has no limit at
    % all, so its LPs do not converge; both are fixed at 0 by minimising the sum of absolute fluxes
    toyRxns = {'in', 'ab', 'out', 'dead', 'l1', 'l2', 'l3', 'u1', 'u2'};
    toyFormulas = {' -> A', 'A -> B', 'B -> ', 'A <=> X', 'P <=> Q', 'Q <=> R', 'R <=> P', 'S <=> T', 'T <=> S'};
    toyModel = createModel(toyRxns, toyRxns, toyFormulas);
    toyModel = changeRxnBounds(toyModel, 'in', 10, 'u');
    toyModel = changeObjective(toyModel, 'out');
    toyModel = changeRxnBounds(toyModel, {'u1', 'u2'}, -Inf, 'l');
    toyModel = changeRxnBounds(toyModel, {'u1', 'u2'}, Inf, 'u');
    expectedFlux = [10; 10; 10; zeros(6, 1)];
    sol = geometricFBA(toyModel);
    assert(norm(sol - expectedFlux) < tol);

    %% parameters given by name: the same result with a smaller tolerance and without output

    printed = evalc('sol = geometricFBA(toyModel, ''epsilon'', 1e-7, ''flexRel'', 1e-3, ''printLevel'', 0);');
    assert(norm(sol - expectedFlux) < tol);
    assert(~contains(printed, 'iteration'));

    %% a parameter without a value is refused

    assert(verifyCobraFunctionError('geometricFBA', 'inputs', {toyModel, 'epsilon'}, ...
                                    'testMessage', 'incorrect number of input parameters'));
end

fprintf('Done...\n');
cd(currentDir)
