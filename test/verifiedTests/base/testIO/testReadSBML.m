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

%Check the requirements (a LP solver is necessary)
solvers = prepareTest('needsLP',true,'requireOneSolverOf',{'gurobi','ibm_cplex','glpk','mosek','quadMinos'});

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSBML'));
cd(fileDir);

%Check if the model contains the same information

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);


% load the models
modelArr = { 'Abiotrophia_defectiva_ATCC_49176.xml', 'STM_v1.0.xml', 'iIT341.xml'};

%loop through the models
for i = 1:length(modelArr)
    %reading the models takes quite a bit of time, so only do it once for
    %all solvers.
    % output a line before launching the test for model i
    fprintf('   Testing %s ...\n', modelArr{i});
    
    % load the model (actually supply the full filename of the path
    % where the model is found)
    model = getDistributedModel(modelArr{i});
    for k = 1:length(solvers.LP)
        fprintf(' -- Running testReadSBML using the solver interface: %s ... ', solvers.LP{k});
        solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
        
        fprintf('   Testing loaded model ... \n');
        
        % set the tolerance
        tol = 1e-6;
        
        
        % define the maximum objective values calculated from pre-converted .mat files
        modelFBAf_max = [0.149475406282249; 0.477833660760744; 0.692812693473487];
        
        % define the minimum objective values
        modelFBAf_min = [0.0; 0.0; 0.0];
        
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
        
        
        % test that gene rules are generated correctly
        % needs testing on model with large number of genes, i.e.,
        % 'Abiotrophia_defectiva_ATCC_49176.xml'
        if strcmp(modelArr{i}, 'Abiotrophia_defectiva_ATCC_49176.xml')
            % test that rules are correctly generated, i.e. no gene partially matched
            % no indication of x(1)23 instead of x(123).
            assert(~any(~cellfun(@isempty, regexp(model.rules, '\(\d+\)\d+')))) %incorrect
        end
    end
end

% test reading COBRA models with symbols in objective reactions and multiple objective reactions
for jTest = 1:2
    if jTest == 1
        % test objective reactions with symbols
        fprintf('   Testing readSBML for models with symbols in objective reactions ...\n');
        model = createModel({'EX_a(e)'; 'EX_b(e)'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; 0];

    elseif jTest == 2
        % test more than one objective reactions with >1 objective reactions
        fprintf('   Testing readSBML for models with >1 objective reactions ...\n');
        model = createModel({'EX_a'; 'EX_b'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; -2];
    end

    model.lb = model.lb(:);
    model.ub = model.ub(:);
    model.comps = {'e'};
    model.compNames = {'ExtraCellular'};
    % add the fields outputted by readSBML
    [model.modelVersion.SBML_level, model.modelVersion.SBML_version, model.modelVersion.fbc_version] = deal(3, 1, 2);
    model.metCharges = zeros(numel(model.mets), 1);
    model.metFormulas = {'C'; 'C'};
    model.osense = -1;
    model.description = 'test_sbml_obj.xml';
    model.genes = {'gene1'; 'gene2'};
    model.rules = {''; ''};
    model.rxnGeneMat = zeros(2, 2);

    model = convertOldStyleModel(model);

    % write the model
    writeCbModel(model, 'sbml', 'test_sbml_obj');


    % read in the model
    model2 = readCbModel('test_sbml_obj.xml');    
    %We are creating a few default fields in readCbModel. 
    DefaultFields = {'S','b','csense','lb','ub','c','osense','rxns','mets','genes','rules'};

    modelFields = fieldnames(model);    
    modelFields = setdiff(modelFields,'rxnGeneMat'); %rxnGeneMat did not contain any information and is not created by readCbModel.
    for i = 1:numel(modelFields)
        if iscell(model.(modelFields{i}))
            if ~all(cellfun(@isempty, model.(modelFields{i})))  || any(ismember(modelFields{i},DefaultFields))
                assert(isequal(model.(modelFields{i}),model2.(modelFields{i})));
            else
                assert(~isfield(model2, modelFields{i}));
            end
        else
            if isnumeric(model.(modelFields{i}))
                if ~all(isnan(model.(modelFields{i})(:))) || any(ismember(modelFields{i},DefaultFields))                                        
                    assert(isequal(model.(modelFields{i})(~isnan(model.(modelFields{i}))),model2.(modelFields{i})(~isnan(model.(modelFields{i})))));
                    assert(isequal(~isnan(model.(modelFields{i})),~isnan(model2.(modelFields{i}))));
                else
                    assert(~isfield(model2, modelFields{i}));
                end
            else
                %Not numeric, i.e. another field.
                assert(isequal(model.(modelFields{i}),model2.(modelFields{i})));
            end
        end
    end
    fprintf(' Done.\n\n');
end
delete('test_sbml_obj.xml')

% change the directory
cd(currentDir)
