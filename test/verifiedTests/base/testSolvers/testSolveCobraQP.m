% The COBRAToolbox: testSolveCobraQP.m
%
% Purpose:
%     - testSolveCobraQP tests the SolveCobraQP function and its different methods
%     - Solver names that the interface refuses (cplex_direct, an unknown name) are selected with
%       validationLevel -1: no solver is imitated, the branch does not call one. All other
%       branches run with the real gurobi and pdco.
%
% Function under test:
%     src/base/solvers/solveCobraQP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy QPs, gurobi and pdco.
%
% Coverage exemptions:
%     Lines 131-145: unreachable, the branch of an if 0.
%     Line 163: unreachable, ~find(regexp(...)) is empty or false, so the condition is never true.
%     Line 172: ibm_cplex branch, solver not available.
%     Lines 186-248: tomlab_cplex branch, solver not available.
%     Lines 251-302: tomlab_cplex_tomRun branch, solver not available.
%     Lines 307-340: ibm_cplex branch, solver not available.
%     Line 351: unreachable, follows the error call of line 350.
%     Lines 363-376: defective input skipped, see the defect on qpng below.
%     Lines 380-480: mosek branch, solver not available.
%     Line 604: unreachable, the branch of an if 0.
%     Line 676: unreachable, gurobi always returns a point with the status OPTIMAL.
%     Lines 711-718: optarrow branch, the OptArrow backend is not available.
%     Lines 721-1034: dqqMinos branch, solver not available (needs csh, not installed).
%     Lines 1051-1054: unreachable, s is initialised at line 124, so it always exists.
%     Line 1073: mosek and optarrow branch, only they set qpmethod, not available.
%     Lines 1078-1079: ibm_cplex and tomlab_cplex branch, solvers not available.
%     Lines 1131-1133: ibm_cplex branch, only it can report status 1 without a point, not available.
%     Lines 1159-1161: mosek, ibm_cplex and tomlab_cplex branch, only they return a point with another status.
%     Lines 1179-1192: dqqMinos branch, solver not available (needs csh, not installed).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The qpng interface reads the problem after it was cleared
%       SEVERITY: error
%       TRIGGER: the solver qpng
%       OBSERVED: QPproblem is cleared at line 178 for every solver except three, so line 368
%         stops with Reference to a cleared variable QPproblem
%       EXPECTED: the qpng branch uses the local A, b, c, F, lb and ub, or QPproblem is kept
%       LINES: 178, 363-376
%     - DEFECT: A nonconvex QP solved to optimality by gurobi stops the function
%       SEVERITY: error
%       TRIGGER: a QP with an indefinite F, with the default gurobi parameter NonConvex
%       OBSERVED: gurobi returns OPTIMAL from its global search without duals, so reading
%         resultgurobi.pi stops with Unrecognized field name pi
%       EXPECTED: the solution returned with empty duals, or an explicit message
%       LINES: 679
%
% Author:
%     - CI integration: Laurent Heirendt, April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraQP'));
cd(fileDir);

printLevel=0;
        
% set the tolerance
tol = 1e-4;

if 1
    % test solver packages
    useIfAvailable = {'tomlab_cplex','ibm_cplex','gurobi','mosek'};
    %useIfAvailable = {'pdco'};
    solverPkgs = prepareTest('needsQP',true,'useSolversIfAvailable', useIfAvailable,'excludeSolvers',{'qpng','pdco','dqqMinos'});
else
    % test solver packages
    useIfAvailable = {'pdco'};
    %useIfAvailable = {'tomlab_cplex','ibm_cplex', 'gurobi','qpng','ibm_cplex','mosek','pdco'};
    solverPkgs = prepareTest('needsQP',true,'useSolversIfAvailable', useIfAvailable);
end

if 0
    %when adding a new solver, it may not be working initially so it will
    %not appear in solverPkgs so bypass it temporarily to run the tests to
    %debug the interface to the solver
    %solverPkgs.QP{end}='gurobi';
    solverPkgs.QP={'gurobi'};
end

initialSolverState = CobraSolverState.get();

clear QPproblem QPproblem2 QPproblem3 QPproblem4 QPproblem5

%QP Solver test: http://tomopt.com/docs/quickguide/quickguide005.php

% set up QP problem
QPproblem.F = [8, 1; 1, 8];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem.c = [3, -4]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem.A = [1, 1; 1, -1];  % Constraint matrix
QPproblem.b = [5, 0]';
QPproblem.lb = [0, 0]';
QPproblem.ub = [inf, inf]';
QPproblem.x0 = [0, 1]';  % starting point
QPproblem.osense = 1;
QPproblem.csense = ['L'; 'E'];

QPproblem2.F = [1, 0, 0; 0, 1, 0; 0, 0, 1];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem2.osense = 1;
QPproblem2.c = -1*[0, 0, 0]';  %Test solving maximisation of linear part
QPproblem2.A = [1, -1, -1 ; 0, 0, 1];  % Constraint matrix
QPproblem2.b = [0, 5]'; %Accumulate 5 B
QPproblem2.lb = [0, -inf, 0]';
QPproblem2.ub = [inf, inf, inf]';
QPproblem2.csense = ['E'; 'E'];


QPproblem3.F = [1, 0, 0; 0, 1, 0; 0, 0, 1];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem3.osense = 1; 
QPproblem3.c = -1*[1, 1, 1]';  %Test solving maximisation of linear part
QPproblem3.A = [1, -1, 0 ; 0, 1, -1];  % Constraint matrix
QPproblem3.b = [0, 0]'; % Steady State
QPproblem3.lb = [0, 0, 0]';
QPproblem3.ub = [inf, inf, inf]';
QPproblem3.csense = ['E'; 'E'];

% http://www2.isye.gatech.edu/~spyros/LP/node2.html
QPproblem4.c = [200; 400];
QPproblem4.A = [1 / 40, 1 / 60; 1 / 50, 1 / 50];
QPproblem4.b = [1; 1];
QPproblem4.lb = [0; 0];
QPproblem4.ub = [1; 1];
QPproblem4.osense = -1;
QPproblem4.csense = ['L'; 'L'];
QPproblem4.F = zeros(size(QPproblem4.A,2));

% set up QP problem
QPproblem5.F = -1*[8, 1; 1, 8];  %Test solving maximisation
QPproblem5.c = [3, -4]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem5.A = [1, 1; 1, -1];  % Constraint matrix
QPproblem5.b = [5, 0]';
QPproblem5.lb = [0, 0]';
QPproblem5.ub = [inf, inf]';
QPproblem5.x0 = [0, 1]';  % starting point
QPproblem5.osense = -1; %Maximise whole objective
QPproblem5.csense = ['L'; 'E'];


for k = 1:length(solverPkgs.QP)
    
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverOK

        fprintf('   Running testSolveCobraQP using %s ... ', solverPkgs.QP{k});
       fprintf('\n')
        QPsolution = solveCobraQP(QPproblem, 'printLevel', printLevel);

        if strcmp(solverPkgs.QP{k},'dqqMinos')
            disp(0.1)
        end


        if ~strcmp('mosek',solverPkgs.QP{k}) %| 1
            %TODO - skip this check of mosek as the solution is the right
            %sign but numerically off by 2 digitis. Why?

            % Check QP results with expected answer.
            %QPsolution.obj
            %QPsolution.full
            %QPproblem.F
            bool = any(abs(QPsolution.obj + 0.0278)  < tol & abs(QPsolution.full - 0.0556) < [tol; tol]);
            if ~bool
                disp(bool)
            end
            assert(bool);
        end
        
        if strcmp(solverPkgs.QP{k}, 'ibm_cplex') && isunix
            % Note: On windows, the timelimit parameter has no effect
            % test IBM-Cplex-specific parameters. No good example for testing this. Just test time limit
            QPsolution = solveCobraQP(QPproblem, struct('timelimit', 0.0), 'printLevel', printLevel);
            % no solution because zero time is given and cplex status = 11
            assert(isempty(QPsolution.full) & isnan(QPsolution.obj) & QPsolution.origStat == 11)
        end
        
        QPsolution2 = solveCobraQP(QPproblem2,'printLevel', printLevel);
        
        assert(abs(QPsolution2.obj - 37.5 / 2) < tol); %Objective value
        assert(all( abs(QPsolution2.full - [2.5;-2.5;5]) < tol)); % Flux distribution

        %Test solving maximisation of linear part
        QPsolution3 = solveCobraQP(QPproblem3,'printLevel', printLevel);
        assert(all(abs(QPsolution3.full - 1)< tol)); %We optimize for 0.5x^2 not x^2
        
        
        QPsolution4 = solveCobraQP(QPproblem4,'printLevel', printLevel);
        
        %QPsolution4.obj
        %QPsolution4.full
        %QPsolution4.obj
        bool = abs(QPsolution4.obj - 600)< tol;
        if ~bool
            disp(bool)
        end
        assert(bool);

        % Depreciated this option because only LP part of objective can
        % have a sign change. 
        % %Test solving maximisation of whole function
        % QPsolution5 = solveCobraQP(QPproblem5,'printLevel', printLevel);
        % %QPsolution5.obj
        % %QPsolution5.full
        % assert(abs(QPsolution5.obj - 2.3065e-09)< tol);
        
    else
        fprintf('   Could not run testSolveCobraQP using %s ... ', solverPkgs.QP{k});
        fprintf('\n')
    end
end
fprintf('...Done.\n\n');

%% Interface branches: solver state, inputs, the status of each available solver
coverageTol = 1e-6;
coverageDir = tempname;
mkdir(coverageDir);
coverageError = [];
try
    coverageSolvers = prepareTest('needsQP', true, 'useSolversIfAvailable', {'gurobi', 'pdco'});
    isAvailable = @(solverName) any(strcmp(coverageSolvers.QP, solverName));

    %% an explicit solver state selects the solver of one call only
    if isAvailable('gurobi') && isAvailable('pdco')
        changeCobraSolver('gurobi', 'QP', 0);
        explicitState = CobraSolverState.get();
        explicitState.solver.QP = 'pdco';
        solution = solveCobraQP(QPproblem, 'cobraSolverState', explicitState);
        assert(strcmp(solution.solver, 'pdco') && abs(solution.obj + 0.0278) < tol);
        assert(strcmp(CobraSolverState.getSolver('QP'), 'gurobi'));
    end

    changeCobraSolver(coverageSolvers.QP{1}, 'QP', 0);

    %% the input is saved on request
    savedFile = fullfile(coverageDir, 'savedQP.mat');
    solveCobraQP(QPproblem, 'saveInput', savedFile);
    savedInput = load(savedFile);
    assert(isequal(savedInput.QPproblem.F, QPproblem.F));

    %% solver names that the interface refuses without calling a solver
    refusedSolvers = {'', 'There is no solver for QP problems available'; ...
                      'nonsense', 'Unknown solver: nonsense'; ...
                      'cplex_direct', 'not setup for QP in general'};
    for i = 1:size(refusedSolvers, 1)
        changeCobraSolver(refusedSolvers{i, 1}, 'QP', 0, -1);
        assertErrorContains(@() solveCobraQP(QPproblem), refusedSolvers{i, 2});
    end

    %% pdco
    if isAvailable('pdco')
        changeCobraSolver('pdco', 'QP', 0);

        % equalities only: min 0.5 * (x1^2 + x2^2) + x1 + x2 subject to x1 + x2 = 1
        equalities = struct('F', eye(2), 'c', [1; 1], 'A', [1, 1], 'b', 1, 'lb', [-10; -10], ...
            'ub', [10; 10], 'osense', 1, 'csense', 'E');
        printedText = evalc('solution = solveCobraQP(equalities, ''printLevel'', 1);');
        assert(solution.stat == 1 && abs(solution.obj - 1.25) < 1e-4);
        assert(norm(solution.full - [0.5; 0.5], inf) < 1e-4);
        assert(contains(printedText, 'Primal optimality condition in solveCobraQP satisfied'));

        % inequalities of both senses get slack variables; the optimum is the one of QPproblem
        greaterThan = QPproblem;
        greaterThan.A(1, :) = -greaterThan.A(1, :);
        greaterThan.b(1) = -greaterThan.b(1);
        greaterThan.csense = ['G'; 'E'];
        solution = solveCobraQP(greaterThan);
        assert(solution.stat == 1 && abs(solution.obj + 0.0278) < tol);

        % the solver parameters given explicitly; large d1 and d2 give a point of the
        % regularised problem, which fails the primal check of solveCobraQP
        pdcoParams = struct('d1', 1, 'd2', 1, 'x0', ones(3, 1), 'y0', ones(2, 1), 'z0', ones(3, 1), ...
            'xsize', 1, 'zsize', 1);
        printedText = evalc('solution = solveCobraQP(QPproblem, pdcoParams);');
        assert(solution.stat == 1 && contains(printedText, 'Primal optimality condition in solveCobraQP not satisfied'));

        % one iteration is not enough: there is no point, so the objective is not a number
        solution = solveCobraQP(QPproblem, struct('MaxIter', 1));
        assert(solution.stat == 0 && solution.origStat == 1 && isempty(solution.full));
        assert(isnan(solution.obj) && isnan(solution.objLinear) && isnan(solution.objQuadratic));
    end

    %% gurobi
    if isAvailable('gurobi')
        changeCobraSolver('gurobi', 'QP', 0);

        % a negative diagonal is refused when nonconvex problems are not allowed
        concave = QPproblem;
        concave.F = -eye(2);
        assertErrorContains(@() solveCobraQP(concave, struct('NonConvex', 0)), 'Gurobi error 10020');
        assert(contains(lastwarn, 'Gurobi cannot solve a QP problem'));

        % gurobi 11 answers INF_OR_UNBD from presolve and the second solve without objective tells
        % which it is; the native status depends on the version, the canonical one not
        unbounded = struct('F', sparse([1, 0; 0, 0]), 'c', [0; -1], 'A', sparse([1, 0]), 'b', 0, ...
            'lb', [-inf; -inf], 'ub', [inf; inf], 'osense', 1, 'csense', 'L');
        solution = solveCobraQP(unbounded);
        assert(solution.stat == 2);
        infeasible = struct('F', eye(2), 'c', [3; -4], 'A', [1, 1; 1, 1], 'b', [1; 2], ...
            'lb', [-inf; -inf], 'ub', [inf; inf], 'osense', 1, 'csense', ['E'; 'E']);
        solution = solveCobraQP(infeasible);
        assert(solution.stat == 0);

        % the checks are reported with printLevel above 0
        printedText = evalc('solution = solveCobraQP(QPproblem, ''printLevel'', 1);');
        assert(solution.stat == 1 && contains(printedText, 'Primal optimality condition in solveCobraQP satisfied'));
        assert(contains(printedText, 'Dual optimality condition in solveCobraQP satisfied'));

        % the diagnostics of printLevel 3, with a zero and with a nonzero quadratic term, on
        % costs near 1e10: their residual is a rounding error above the 1e-8 at which they pause
        largeCosts = struct('F', sparse(3, 3), 'c', 1e10 * [pi; exp(1); sqrt(2)], ...
            'A', [sqrt(3), 1 / 7, 2.3; 1 / 3, sqrt(5), 1.7], 'b', [1; 2], 'lb', [0; 0; 0], ...
            'ub', [inf; inf; inf], 'osense', -1, 'csense', ['L'; 'L']);
        printedText = evalc('solution = solveCobraQP(largeCosts, ''printLevel'', 3);');
        assert(solution.stat == 1 && contains(printedText, 'Check osense*c - A''*lam - w = 0 (stationarity):'));
        largeCosts.F = 1e-6 * speye(3);
        printedText = evalc('solution = solveCobraQP(largeCosts, ''printLevel'', 3);');
        assert(solution.stat == 1 && contains(printedText, 'Check 2*Q*x + c - A''*lam = 0 (stationarity):'));

        % a maximisation with a nonzero F: gurobi minimises 0.5*x'*F*x - c'*x, so the objective
        % reported by the function differs from the one of the solver, and both checks say so.
        % The optimum x = [1; 1] does not depend on this difference.
        mixedSense = struct('F', speye(2), 'c', [1; 1], 'A', [1, 1], 'b', 10, 'lb', [-inf; -inf], ...
            'ub', [inf; inf], 'osense', -1, 'csense', 'L');
        printedText = evalc('solution = solveCobraQP(mixedSense);');
        assert(solution.stat == 1 && norm(solution.full - [1; 1], inf) < 1e-4);
        assert(contains(lastwarn, 'Objectives do not match'));
        assert(contains(printedText, 'Dual optimality condition in solveCobraQP not satisfied'));
    end
catch coverageError
end
CobraSolverState.restore(initialSolverState);
rmdir(coverageDir, 's');
if ~isempty(coverageError)
    rethrow(coverageError);
end

% change the directory
cd(currentDir)

function assertErrorContains(functionHandle, expectedText)
    % The call has to stop with an error whose message contains expectedText.
    threw = false;
    try
        functionHandle();
    catch ME
        threw = true;
        assert(contains(ME.message, expectedText), 'unexpected error: %s', ME.message);
    end
    assert(threw, 'no error was thrown');
end

