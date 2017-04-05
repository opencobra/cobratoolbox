% The COBRAToolbox: testReadSBML.m
%
% Purpose:
%     - reads all the sbml files in this folder and
%       checks if all the parameters are correctly written
%     - loads certain xml files, runs and FBA, and compares the
%       solution to pre-calculated values from FBAs run with .mat files
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSBML'));
cd(fileDir);

% load the test models
testModel = readCbModel('Ec_iJR904.xml');
load('Ec_iJR904.mat', 'model');

% test the sizes of the .mat model and the .xml model
assert(length(model.rxns) == length(testModel.rxns))
assert(length(model.mets) == length(testModel.mets))
assert(size(model.S, 1) == size(testModel.S, 1))
assert(size(model.S, 2) == size(testModel.S, 2))
assert(length(model.rev) == length(testModel.rev))
assert(length(model.lb) == length(testModel.lb))
assert(length(model.ub) == length(testModel.ub))
assert(length(model.c) == length(testModel.c))
assert(length(model.rules) == length(testModel.rules))
assert(length(model.genes) == length(testModel.genes))
assert(length(model.rxnGeneMat) == length(testModel.rxnGeneMat))
assert(length(model.grRules) == length(testModel.grRules))
assert(length(model.subSystems) == length(testModel.subSystems))
assert(length(model.rxnNames) == length(testModel.rxnNames))
assert(length(model.metNames) == length(testModel.metNames))
assert(length(model.metFormulas) == length(testModel.metFormulas))
assert(length(model.b) == length(testModel.b))

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

for k = 1:length(solverPkgs)

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing readSBML using %s ... \n', solverPkgs{k});

        % set the tolerance
        tol = 1e-6;

        % load the models
        modelArr = {'Abiotrophia_defectiva_ATCC_49176.xml', 'STM_v1.0.xml', 'iIT341.xml', 'Ec_iAF1260_flux1.xml'};

        % define the maximum objective values calculated from pre-converted .mat files
        modelFBAf_max = [0.149475406282249; 0.477833660760744; 0.692812693473487; 0.736700938865275];

        % define the minimum objective values
        modelFBAf_min = [0.0; 0.0; 0.0; 0.0];

        % loop through the models
        for i = 1:length(modelArr)
            % output a line before launching the test for model i
            fprintf('   Testing %s ...', modelArr{i});

            % load the model (actually supply the full filename of the path
            % where the model is found)
            model = readCbModel(which(modelArr{i}));

            % solve the maximisation problem
            FBA = optimizeCbModel(model, 'max');

            % test the maximisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelFBAf_max(i)) < tol);
            assert(norm(model.S * FBA.x) < tol);

            % solve the minimisation problem
            FBA = optimizeCbModel(model, 'min');

            % test the minimisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelFBAf_min(i)) < tol);
            assert(norm(model.S * FBA.x) < tol);

            % print a line for success of loop i
            fprintf(' Done.\n');
        end
    end
end

% change the directory
cd(currentDir)
