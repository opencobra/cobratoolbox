% The COBRAToolbox: testloadBiGGModel.m
%
% Purpose:
%     - reads models from BiGG and the previously downloaded version in
%       the models directory and compares them.
%     - tests one model for equivalence wrt FBA results.
%     - tests how the models are selected, without a network: the BiGG service (webread, websave)
%       and the prompt (input, listdlg) are replaced by test doubles in a temporary folder, which
%       is on the path for that section only.
%
% Coverage exemptions:
%     Lines 73-74: GUI, the selection dialog of a desktop session. Headless, as in CI, the
%     function asks through input instead.
%
% Authors:
%     - Thomas Pfau
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR
global CBT_MISSING_REQUIREMENTS_ERROR_ID

%Check the requirements (a LP solver is necessary)
solverPkgs = prepareTest('needsLP',true,'requireOneSolverOf',{'gurobi','ibm_cplex','glpk','mosek','quadMinos'});

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadBiGGModel.m'));
cd(fileDir);

%% Selecting models, with a fake BiGG service holding three models
doubleFolder = tempname;
mkdir(doubleFolder);

% every model the fake service hands out is this small model
serverModelFile = [doubleFolder filesep 'serverModel.mat'];
model = createModel({'R1'}, {'Reaction 1'}, {'a[c] -> b[c]'});
save(serverModelFile, 'model');
serverRxns = model.rxns;

fid = fopen([doubleFolder filesep 'webread.m'], 'w');
fprintf(fid, 'function data = webread(url)\n');
fprintf(fid, 'data.results = struct(''bigg_id'', {''modelB'', ''modelA'', ''3modelC''}, ''organism'', {''Beta'', ''Alpha'', ''Gamma''});\n');
fprintf(fid, 'end\n');
fclose(fid);
fid = fopen([doubleFolder filesep 'websave.m'], 'w');
fprintf(fid, 'function fileName = websave(fileName, url)\ncopyfile(''%s'', fileName);\nend\n', serverModelFile);
fclose(fid);

% the prompt and the dialog both answer: all three models. They have their own folder because
% MATLAB warns about the input double whenever the path is searched.
promptFolder = [doubleFolder filesep 'prompt'];
mkdir(promptFolder);
fid = fopen([promptFolder filesep 'input.m'], 'w');
fprintf(fid, 'function answer = input(prompt, varargin)\nanswer = ''[1 2 3]'';\nend\n');
fclose(fid);
fid = fopen([promptFolder filesep 'listdlg.m'], 'w');
fprintf(fid, 'function [selection, ok] = listdlg(varargin)\nselection = [1 2 3];\nok = 1;\nend\n');
fclose(fid);

addpath(doubleFolder);
clear loadBiGGModel
try
    % the default format is mat
    loadedModel = loadBiGGModel('modelA');
    assert(isequal(loadedModel.rxns, serverRxns));

    % an unknown id is reported and skipped, the known ids are still loaded
    capturedOutput = evalc('loadedModel = loadBiGGModel({''modelB'', ''unknownId''});');
    assert(contains(capturedOutput, 'Could not find the following model ids in BiGG'));
    assert(contains(capturedOutput, 'unknownId'));
    assert(isequal(loadedModel.rxns, serverRxns));

    % nothing is left to load: a warning, and no output
    lastwarn('');
    loadBiGGModel('unknownId');
    assert(strcmp(lastwarn, 'No model selected.'));

    % without an id the user selects: several models come back as one struct, and a field
    % name cannot start with a digit
    addpath(promptFolder);
    selectedModels = loadBiGGModel();
    rmpath(promptFolder);
    assert(isequal(sort(fieldnames(selectedModels)), {'M_3modelC'; 'modelA'; 'modelB'}));
    assert(isequal(selectedModels.M_3modelC.rxns, serverRxns));
catch ME
    rmpath(doubleFolder);
    if contains(path, promptFolder)
        rmpath(promptFolder);
    end
    clear input listdlg webread websave
    rmdir(doubleFolder, 's');
    rethrow(ME);
end
rmpath(doubleFolder);
clear input listdlg webread websave
rmdir(doubleFolder, 's');

% the rest of the test compares against the real BiGG database
prepareTest('needsWebAddress','http://bigg.ucsd.edu/api/v2/models');

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);

% Models: FileName of local file, model ID and type for BiGG, along with
% FBA Min and Max value.
modelArr = {'iIT341.xml','iIT341','sbml','BiGGSBML',0,0.692812693473487;...
    'iJO1366.mat','iJO1366','mat','BiGG',NaN,NaN};

% set the tolerance
tol = 1e-6;

tested = false;

%loop through the models
for i = 1:size(modelArr,1)
    %reading the models takes quite a bit of time, so only do it once for
    %all solvers.
    % output a line before launching the test for model i
    fprintf('   Testing %s ...\n', modelArr{i,2});
    
    % load the model (actually supply the full filename of the path
    % where the model is found)
    model1 = getDistributedModel(modelArr{i,1});
    try
        model2 = loadBiGGModel(modelArr{i,2},modelArr{i,3});
        tested = true;
    catch ME
        if strcmp(ME.identifier,'MATLAB:webservices:Timeout')
            %Could not load the model, skip.
            continue;
        end
    end
        
    model3 = readCbModel(modelArr{i,2},'fileType',modelArr{i,4});
    
    %Check that the direct load is the same
    if 1
        printLevel=1;
        [isSame, nDiff, commonFields] = isSameCobraModel(model1, model2, printLevel);
        assert(isSame)
    else
        assert(isSameCobraModel(model1,model2));
    end
    
    
    %Check that the model loaded through readCbModel is the same.
    
    if 1
        printLevel=1;
        [isSame, nDiff, commonFields] = isSameCobraModel(model1, model3, printLevel);
        assert(isSame)
    else
        assert(isSameCobraModel(model1,model3));
    end

    
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
%This should only ever happen, if the BiGG db could not be contacted.
if ~tested
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID,'Could not connect to BiGG Database');
end
% change the directory
cd(currentDir)

