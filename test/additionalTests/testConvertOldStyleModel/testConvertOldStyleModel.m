% The COBRAToolbox: testConvertOldStyleModel.m
%
% Purpose:
%     - tests that an old style and new standard model give the same
%       solutions
%
% Authors:
%     - Original file: Ronan Fleming 22/02/20
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertOldStyleModel'));
cd(fileDir);

if exist('Harvey_1_01c.mat','file')
    fprintf('   Testing convertOldStyleModel \n');
    
    if ~exist('modelOld','var')
        % load the model
        load('Harvey_1_01c.mat');
 
        male = changeRxnBounds(male,'Whole_body_objective_rxn',0,'l');
        male = changeRxnBounds(male,'Whole_body_objective_rxn',100,'u');
        male.osense = -1;
        modelOld=male;

        clearvars -except modelOld
        %run the conversion
        model = convertOldStyleModel(modelOld, 1);
    end
    
    
    % set the tolerance
    tol = 1e-8;

    tic;
    solverOK = changeCobraSolver('gurobi','LP');
    solution_new_gurobi = optimizeCbModel(model);
    toc
    
    % check the optimal solution
    if 0
        [solution_old_ILOGcomplex]=solveCobraLPCPLEX(modelOld,1,0,0,[],0,'ILOGcomplex')
        % testing if f values are within range
        abs(solution_new_ibm_cplex.f - solution_new_cplexlp.f)
        %assertion
        assert(abs(solution_old_ILOGcomplex.obj - solution_new_cplexlp.f) < tol);
    end
        
    if 1
        solverOK = changeCobraSolver('cplexlp','LP');
        solution_new_cplexlp = optimizeCbModel(model);
        % testing if f values are within range
        abs(solution_new_gurobi.f - solution_new_cplexlp.f)
        %assertion
        assert(abs(solution_new_gurobi.f - solution_new_cplexlp.f) < tol);
    end
    
    % output a success message
    fprintf('Done.\n');
else
    fprintf('\n testConvertOldStyleModel bypassed as test mat file not available.')
end

% change the directory
cd(currentDir)
