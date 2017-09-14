% The COBRAToolbox: testloadBiGGModel.m
%
% Purpose:
%     - reads models from BiGG and the previously downloaded version in
%       the models directory and compares them.
%     - tests one model for equivalence wrt FBA results.
%
% Authors:
%     - Thomas Pfau
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadBiGGModel.m'));
cd(fileDir);

%Check if the model contains the same information

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};


% Models: FileName of local file, model ID and type for BiGG, along with
% FBA Min and Max value.
modelArr = {'iIT341.xml','iIT341','sbml',0,0.692812693473487;...
    'iJO1366.mat','iJO1366','mat',NaN,NaN};

% set the tolerance
tol = 1e-6;

%loop through the models
for i = 1:size(modelArr,1)
    %reading the models takes quite a bit of time, so only do it once for
    %all solvers.
    % output a line before launching the test for model i
    fprintf('   Testing %s ...\n', modelArr{i,2});
    
    % load the model (actually supply the full filename of the path
    % where the model is found)
    model1 = readCbModel(which(modelArr{i,1}));
    model2 = loadBiGGModel(modelArr{i,2},modelArr{i,3});
    assert(isSameCobraModel(model1,model2));
    if ~isnan(modelArr{i,4})
        for k = 1:length(solverPkgs)
            
            % set the solver
            solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
            
            if solverOK == 1
                fprintf('   Testing with solver %s ... \n', solverPkgs{k});
                
                
                % solve the maximisation problem
                FBA = optimizeCbModel(model2, 'max');
                
                % test the maximisation solution
                assert(FBA.stat == 1);
                assert(abs(FBA.f - modelArr{i,5}) < tol);
                assert(norm(model2.S * FBA.x) < tol);
                
                % solve the minimisation problem
                FBA = optimizeCbModel(model2, 'min');
                
                % test the minimisation solution
                assert(FBA.stat == 1);
                assert(abs(FBA.f - modelArr{i,4}) < tol);
                assert(norm(model2.S * FBA.x) < tol);
                
                % print a line for success of loop i
                fprintf(' Done.\n');
            end
        end
    end
end
% change the directory
cd(currentDir)

