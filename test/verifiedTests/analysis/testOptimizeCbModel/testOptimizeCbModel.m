% The COBRAToolbox: testOptimizeCbModel.m
%
% Purpose:
%     - Tests the optimizeCbModel function
%
% Authors:
%     - CI integration: Laurent Heirendt, Ronan Fleming
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

% change the directory
cd(currentDir)
