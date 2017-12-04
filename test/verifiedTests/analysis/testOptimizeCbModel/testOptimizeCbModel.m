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
origmodel = getDistributedModel('ecoli_core_model.mat');

osenseStr = 'max';
allowLoops = true;

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    model = origmodel;
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
        
        %% Test some error cases. 
        %wrong size of csense
        model = origmodel;
        model.csense(4) = [];        
        assert(verifyCobraFunctionError(@() optimizeCbModel(model)));
        %Test S of different Size
        model = origmodel;
        model.S(:,3) = [];
        assert(verifyCobraFunctionError(@() optimizeCbModel(model)));
        
        %% Test additional constraints
        %get two random reactions which carried flux. in the basic
        %FBASolution
        PositiveFluxes = find(FBAsolution.full > 1); %Take something with clearly positive flux
        selectedFluxes = PositiveFluxes(randperm(numel(PositiveFluxes),2));
        totalFlux = sum(FBAsolution.full(selectedFluxes)) / 2;
        %Add A Constraint that makes this lower than half the flux before.
        model = addCOBRAConstraint(origmodel,origmodel.rxns(selectedFluxes),totalFlux,'c',[1 1]);
        ConstraintSolution = optimizeCbModel(model);
        assert(sum(ConstraintSolution.full(selectedFluxes)) - totalFlux <= tol);
        
        % And test some inconsistency cases
        %Wrong size of C
        incModel = model;
        incModel.C(:,6) = [];
        assert(verifyCobraFunctionError(@() optimizeCbModel(incModel)));
        %wrong size of d
        incModel = model;
        incModel.d(end+1) = 2;
        assert(verifyCobraFunctionError(@() optimizeCbModel(incModel)));        
        %wrong size of dsense
        incModel = model;
        incModel.dsense(end+1) = 'G';
        assert(verifyCobraFunctionError(@() optimizeCbModel(incModel)));        
        % missing field
        incModel = rmfield(model,'dsense');
        assert(verifyCobraFunctionError(@() optimizeCbModel(incModel)));               
        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
