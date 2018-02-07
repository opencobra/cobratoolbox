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

%Check the requirements (a LP solver is necessary)
solverPkgs = COBRARequisitesFullfilled('needsLP',true);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadBiGGModel.m'));
cd(fileDir);

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);

% Models: FileName of local file, model ID and type for BiGG, along with
% FBA Min and Max value.
modelArr = {'iIT341.xml','iIT341','sbml','BiGGSBML',0,0.692812693473487;...
    'iJO1366.mat','iJO1366','mat','BiGG',NaN,NaN};

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
    model1 = getDistributedModel(modelArr{i,1});
    model2 = loadBiGGModel(modelArr{i,2},modelArr{i,3});
    model3 = readCbModel(modelArr{i,2},'fileType',modelArr{i,4});
    %Check that the direct load is the same
    assert(isSameCobraModel(model1,model2));
    %Check that the model loaded through readCbModel is the same.
    assert(isSameCobraModel(model1,model3));
    
    if ~isnan(modelArr{i,5})
        for k = 1:length(solverPkgs.LP)
            fprintf(' -- Running testLoadBiGGModel using the solver interface: %s ... ', solverPkgs.LP{k});
            changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
            
            fprintf('   Testing loaded model ... \n');
            
            
            % solve the maximisation problem
            FBA = optimizeCbModel(model2, 'max');
            
            % test the maximisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelArr{i,6}) < tol);
            assert(norm(model2.S * FBA.x) < tol);
            
            % solve the minimisation problem
            FBA = optimizeCbModel(model2, 'min');
            
            % test the minimisation solution
            assert(FBA.stat == 1);
            assert(abs(FBA.f - modelArr{i,5}) < tol);
            assert(norm(model2.S * FBA.x) < tol);
            
            % print a line for success of loop i
            fprintf(' Done.\n');
        end
    end
end
% change the directory
cd(currentDir)

