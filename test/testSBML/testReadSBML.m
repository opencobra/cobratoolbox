% COBRA Toolbox: testReadSBML.m
%
% Note:
% the solver libraries must be included separately

addpath(genpath([pwd '/../../']))

% set the solver
solverOK = changeCobraSolver('tomlab_cplex');
%solverOK = changeCobraSolver('cplex_direct');

if solverOK ~= 1
    error('Solver cannot be set properly.\n');
else
    % set the tolerance
    tol = 1e-9;

    % load the models
    modelArr = {'Abiotrophia_defectiva_ATCC_49176.xml', 'STM_v1.0.xml', 'iIT341.xml', 'Ec_iAF1260_flux1.xml'};

    % define the maximum objective values
    modelFBAf_max = [0.149475406282249; 0.477833660760744; 0.692812693473487; 0.736700938865275];

    % define the minimum objective values
    modelFBAf_min = [0.0; 0.0; 0.0; 0.0];

    % loop through the models
    for i = 1:length(modelArr)

        % output a line before launching the test for model i
        fprintf('Testing %s ...', [pwd '/../../test/models/' modelArr{i}]);

        % load the model
        model = readCbModel([pwd '/../../test/models/' modelArr{i}]);

        % solve the maximisation problem
        FBA = optimizeCbModel(model,'max');

        % test the maximisation solution
        assert(FBA.stat == 1);
        assert(abs(FBA.f - modelFBAf_max(i)) < tol);
        assert(norm(model.S*FBA.x) < tol);

        % solve the minimisation problem
        FBA = optimizeCbModel(model,'min');

        % test the minimisation solution
        assert(FBA.stat == 1);
        assert(abs(FBA.f - modelFBAf_min(i)) < tol);
        assert(norm(model.S*FBA.x) < tol);

        % print a line for success of loop i
        fprintf(' Done.\n');

    end
end
