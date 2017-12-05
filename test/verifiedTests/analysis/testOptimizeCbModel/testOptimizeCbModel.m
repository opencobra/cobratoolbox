% The COBRAToolbox: testOptimizeCbModel.m
%
% Purpose:
%     - Tests the optimizeCbModel function
%
% Authors:
%     - CI integration: Laurent Heirendt
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeCbModel'));
cd(fileDir);

% set the tolerance
tol = 1e-6;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'glpk'};

% load the model
model = getDistributedModel('ecoli_core_model.mat');

osenseStr = 'max';
allowLoops = true;

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing optimizeCbModel using solver %s ... ', solverPkgs{k})

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

        % Minimise the zero norm
        minNorm = 'zero';
        L0solution = optimizeCbModel(model, osenseStr, minNorm, allowLoops);
        assert(L0solution.stat == 1);
        assert(norm(model.S * L0solution.x - model.b, 2) < tol);
        assert(abs(FBAsolution.f - L0solution.x'* model.c) < 0.01);
        
        %Test minimisation (objective should eb zero)
        %First by setting osenseStr:
        minSol = optimizeCbModel(model,'min');
        assert(minSol.f == 0);
        
        %Then by setting the osense of the model.
        modelMod = model;
        modelMod.osense = 1;        
        minSol = optimizeCbModel(model,'min');
        assert(minSol.f == 0);
        
        %Test the warning when maxmimisation is implicitly assumed:
        warnStat = warning;
        warning('on');
        modelMod = rmfield(model,'osense');
        maxSol = optimizeCbModel(modelMod,'',minNorm);
        warnstr = lastwarn;
        expectedWarn = 'Assuming maximisation';
        assert(abs(FBAsolution.f - maxSol.x' * model.c) < 0.01);
        assert(strncmp(warnstr,expectedWarn,length(expectedWarn)));
        warning(warnStat)
        
        if strcmp(solverPkgs{k}, 'tomlab_cplex')
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
