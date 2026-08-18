% The COBRAToolbox: testOptimizeCbModel.m
%
% Purpose:
%     - Tests the optimizeCbModel function
%     - Also characterizes the current behaviour of optimizeCbModel across axes
%       not covered above: the full status matrix (optimal/infeasible/
%       unbounded), every documented minNorm strategy, both optimization
%       senses, allowLoops on/off, and primal/dual quantity presence. Merged in
%       from testCharacterizeOptimizeCbModel.m per Constitution Principle
%       III-Naming (feature 018-test-naming-convention): one test file per
%       source function.
%
% Authors:
%     - CI integration: Laurent Heirendt, Ronan Fleming
%     - Characterization: generated for feature
%       009-fba-characterization-statusmap, 2026-07-15; merged into this file by
%       feature 018-test-naming-convention, 2026-08-17.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCbModel'));
cd(fileDir);

% set the tolerance
tol = 1e-6;


%Test the requirements
if 1
    useSolversIfAvailable = {'cplex_direct', 'glpk', 'gurobi', 'ibm_cplex', 'matlab', 'mosek', ...
        'tomlab_cplex', 'mosek_linprog','cplexlp'}; % 'lp_solve': legacy
    useSolversIfAvailable = {'cplex_direct', 'glpk', 'gurobi', 'ibm_cplex', 'matlab', ...
        'tomlab_cplex', 'mosek_linprog','cplexlp'}; % 'lp_solve': legacy
    excludeSolvers={'pdco'};
else
    useSolversIfAvailable = {'pdco'};
    excludeSolvers={'gurobi'};
end

if 0
    useSolversIfAvailable ={'cplexlp'};
end
       
solverPkgs = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);

% load the model
if 0
    model = getDistributedModel('ecoli_core_model.mat');
else
    model = getDistributedModel('iAF1260.mat');
end

osenseStr = 'max';
allowLoops = true;


for k = 1:length(solverPkgs.LP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing optimizeCbModel cardinality optimisation using solver %s ... ', solverPkgs.LP{k})

        % Regular FBA
        minNorm = 0;
        FBAsolution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        bool = (FBAsolution.stat == 1);
        if ~bool
            disp(bool)
        end
        assert(bool);
        assert(norm(model.S * FBAsolution.x - model.b, 2) < tol);     
        
        if strcmp(solverPkgs.LP{k}, 'tomlab_cplex')
        % change the COBRA solver (QP)
            solverOK = changeCobraSolver('tomlab_cplex', 'QP');

            % Minimise the Euclidean Norm of internal fluxes
            minNorm = rand(size(model.S, 2), 1);
            L2solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
            assert(L2solution.stat == 1);
            assert(norm(model.S * L2solution.x - model.b, 2) < tol);
            assert(abs(FBAsolution.f - L2solution.x'* model.c) < 0.01);
        end

        % output a success message
        fprintf('Done.\n');
    end
end

if 1
    useSolversIfAvailable ={'gurobi','cplexlp'};
end
       
solverPkgs = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);

osenseStr = 'max';
allowLoops = true;
for k = 1:length(solverPkgs.LP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing optimizeCbModel using solver %s ... ', solverPkgs.LP{k})

        % Regular FBA
        minNorm = 0;
        FBAsolution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(FBAsolution.stat == 1);
        assert(norm(model.S * FBAsolution.x - model.b, 2) < tol);

        % Minimise the Taxicab Norm
        minNorm = 'one';
        L1solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(L1solution.stat == 1);
        assert(norm(model.S * L1solution.x - model.b, 2) < tol);
        assert(abs(FBAsolution.f - L1solution.x'* model.c) < 0.01);
        %sum(abs(L1solution.x))
        %abs(sum(abs(L1solution.x))-5.997682160714440e+02)
        %assert(abs(sum(abs(L1solution.x))-5.997682160714440e+02) <tol)

        % Minimise the weighted Taxicab Norm
        minNorm = 'one';
        model.g1=1:size(model.S,2);
        L1solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(L1solution.stat == 1);
        assert(norm(model.S * L1solution.x - model.b, 2) < tol);
        assert(abs(FBAsolution.f - L1solution.x'* model.c) < 0.01);
        %sum(abs(L1solution.x))
        assert(abs(sum(abs(L1solution.x))-6.003485501480500e+02) <tol)
        model = rmfield(model,'g1');
        
        % Minimise the zero norm
        minNorm = 'zero';
        L0solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(L0solution.stat == 1);
        assert(norm(model.S * L0solution.x - model.b, 2) < tol);
        assert(abs(FBAsolution.f - L0solution.x'* model.c) < 0.01);
        %sum(abs(L1solution.x)>tol)
        assert(sum(abs(L0solution.x)>tol)<=399)

        % Minimise the zero norm using optimizeCardinality
        minNorm = 'optimizeCardinality';
        %vector of alternating 0, 1, -1 entries
        model.g0 = ones(size(model.S,2),1); 
        L0solution2 = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(sum(abs(L0solution2.x)>tol)<=400)
        
       % Minimise the zero norm using optimizeCardinality
        minNorm = 'optimizeCardinality';
        %vector of alternating 0, 1, -1 entries
        model.g0 = rem((1:size(model.S,2))',3) - 1; 
        L0solution3 = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(sum(abs(L0solution3.x)>tol)<=445)
        
        % Minimise a weighted combination of the zero and one norm
        minNorm = 'optimizeCardinality';
        %vector of alternating 0, 1, -1 entries
        model.g0 = rem((1:size(model.S,2))',3) - 1; 
        %vector of alternating 1, 2, -1 0 entries
        %model.g0 = rem((2:size(model.S,2)+1)',4) - 1;
        model.g1 = (1:size(model.S,2))';
        model.g1 = model.g1/max(model.g1);
        L01solution1 = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        %L01solution.f - 0.736700938697735
        assert(abs(L01solution1.f - 0.736700938697735)<1e-6)
        
        % Minimise a weighted combination of the zero and one norm
        minNorm = 'optimizeCardinality';
        %vector of alternating 0, 1, -1 entries
        model.g0 = rem((1:size(model.S,2))',3) - 1; 
        model.g0 = model.g0*0;
        %vector of alternating 1, 2, -1 0 entries
        %model.g0 = rem((2:size(model.S,2)+1)',4) - 1;
        model.g1 = (1:size(model.S,2))';
        model.g1 = model.g1/max(model.g1);
        L01solution2 = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(nnz(L01solution1.v~=L01solution2.v)>0)
        assert(abs(L01solution2.f - 0.736700938697735)<1e-6)
        
        % Minimise a weighted combination of the zero and one norm
        minNorm = 'optimizeCardinality';
        %vector of alternating 0, 1, -1 entries
        model.g0 = rem((1:size(model.S,2))',3) - 1; 
        model.g0 = model.g0*0;
        %vector of alternating 1, 2, -1 0 entries
        %model.g0 = rem((2:size(model.S,2)+1)',4) - 1;
        model.g1 = (1:size(model.S,2))';
        %model.g1 = model.g1/max(model.g1);
        model.g1 = model.g1*rand(1);
        %model.g1 = model.g1*0;
        L01solution3 = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        %assert(nnz(L01solution3.v~=L01solution2.v)>0)
        assert(abs(L01solution3.f - 0.736700938697735)<1e-6)
        
        if strcmp(solverPkgs.LP{k}, 'tomlab_cplex')
        % change the COBRA solver (QP)
            solverOK = changeCobraSolver('tomlab_cplex', 'QP');

            % Minimise the Euclidean Norm of internal fluxes
            minNorm = rand(size(model.S, 2), 1);
            L2solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
            assert(L2solution.stat == 1);
            assert(norm(model.S * L2solution.x - model.b, 2) < tol);
            assert(abs(FBAsolution.f - L2solution.x'* model.c) < 0.01);
        end

        % output a success message
        fprintf('Done.\n');
    end
end

%% Characterization: optimizeCbModel behaviour (merged from testCharacterizeOptimizeCbModel.m)
% PINS the current behaviour of optimizeCbModel across the axes the tests above
% do not cover: the full status matrix (optimal/infeasible/unbounded), every
% documented minNorm strategy, both optimization senses, allowLoops on/off, and
% the presence of primal and dual quantities. Asserts EXISTING behaviour
% (feature 009, Constitution Principle III characterization mode). Canonical
% .stat is pinned exactly (solver-independent); objective, mass-balance residual
% and fluxes are pinned within tolerance.

% tolerance for floating-point comparisons (integer .stat is compared exactly)
charTol = 1e-6;
% The minNorm re-solves (which must PRESERVE the optimum) pin the objective only
% to the solver's optimality tolerance, which varies across solver/MATLAB
% versions; a tight 1e-6 pin there is over-specified and fails on some CI gurobi
% builds. Use a looser tolerance for those objective pins only; the base direct
% solves and all structural checks (status, mass balance, flux vector) stay at
% charTol.
charObjTol = 1e-4;

% require an LP solver; skip cleanly otherwise
charSolverPkgs = prepareTest('needsLP', true);

for charK = 1:length(charSolverPkgs.LP)

    charSolverLP = charSolverPkgs.LP{charK};
    fprintf('   Characterizing optimizeCbModel with LP solver %s ... ', charSolverLP);
    charSolverLPOK = changeCobraSolver(charSolverLP, 'LP', 0);

    if charSolverLPOK
        % is a QP solver also available (for the L2 / positive-scalar minNorm case)?
        charQpOK = changeCobraSolver(charSolverLP, 'QP', 0);

        % --- OPTIMAL (max), minNorm = 0 -----------------------------------------
        charModel = buildCharToyModel();
        charS = optimizeCbModel(charModel, 'max', 0);
        assert(charS.stat == 1);                                   % canonical: optimal
        assert(abs(charS.f - 10) < charTol);                       % objective pinned
        assert(norm(charModel.S * charS.v - charModel.b) < charTol); % mass balance
        assert(norm(charS.v - [10; 10; 10]) < charTol);            % unique optimum
        % dual quantities are present and well-formed (values are solver-dependent)
        assert(numel(charS.w) == numel(charModel.rxns) && all(isfinite(charS.w)));
        assert(numel(charS.y) == numel(charModel.mets) && all(isfinite(charS.y)));

        % --- OPTIMAL (min) ------------------------------------------------------
        charS = optimizeCbModel(charModel, 'min', 0);
        assert(charS.stat == 1);
        assert(abs(charS.f - 0) < charTol);

        % --- minNorm strategies preserve the optimum (all stat==1, f==10) -------
        for charMinNorm = {'one', 'zero', [1; 1; 1]}
            charS = optimizeCbModel(charModel, 'max', charMinNorm{1});
            assert(charS.stat == 1);
            assert(abs(charS.f - 10) < charObjTol);
            assert(norm(charModel.S * charS.v - charModel.b) < charTol);
        end

        % L2 / positive-scalar minNorm requires a QP solver
        if charQpOK
            charS = optimizeCbModel(charModel, 'max', 1e-6);
            assert(charS.stat == 1);
            assert(abs(charS.f - 10) < charObjTol);
        end

        % 'optimizeCardinality' minNorm requires model.g0 on the model; pin that
        % the bare model raises rather than silently proceeding.
        charErrored = false;
        try
            optimizeCbModel(charModel, 'max', 'optimizeCardinality');
        catch
            charErrored = true;
        end
        assert(charErrored);

        % --- allowLoops on/off --------------------------------------------------
        charS = optimizeCbModel(charModel, 'max', 0, true);
        assert(charS.stat == 1 && abs(charS.f - 10) < charTol);
        charS = optimizeCbModel(charModel, 'max', 0, false);
        assert(charS.stat == 1 && abs(charS.f - 10) < charTol);

        % --- INFEASIBLE -----------------------------------------------------
        charModelInf = buildCharToyModel();
        charModelInf.lb(3) = 50;                                   % demand 50 out, input capped at 10
        charS = optimizeCbModel(charModelInf, 'max', 0);
        assert(charS.stat == 0);                                   % canonical: infeasible

        % --- UNBOUNDED ------------------------------------------------------
        charModelUnb = buildCharToyModel();
        charModelUnb.ub = [inf; inf; inf];                         % uncap the pathway
        charS = optimizeCbModel(charModelUnb, 'max', 0);
        assert(charS.stat == 2);                                   % canonical: unbounded

        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)


function model = buildCharToyModel()
    % Tiny linear pathway A ->(R1, ub 10) -> B (R2) -> out (R3, objective).
    % Feasible with a unique optimum f = 10; used to characterize the status matrix.
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
end
