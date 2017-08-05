% The COBRAToolbox: testWriteCbModel.m
%
% Purpose:
%     - test the writeCbModel function
%
% Authors:
%     - Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteCbModel'));
cd(fileDir);

% Note: test is only compatible with Matlab R2015b or later
if ~verLessThan('matlab', '8.6')
    % define tolerance
    tol = 1e-6;

    % load the model
    load('ecoli_core_model.mat', 'model');

    %system('cp refXLSX.xlsx testData.xlsx');

    % write the model to an xls file
    writeCbModel(model, 'xlsx', 'testData.xlsx');

    % read in the xls model file
    modelIn = xls2model('testData.xlsx');

    % convert an old style model
    model = convertOldStyleModel(model);

    % test
    assert(isequal(model.lb, modelIn.lb))
    assert(isequal(model.b, modelIn.b))
    assert(isequal(model.ub, modelIn.ub))
    assert(isequal(sort(model.mets), sort(modelIn.mets)))
    assert(isequal(model.csense, modelIn.csense))
    assert(isequal(model.osense, modelIn.osense))
    assert(isequal(model.rxns, modelIn.rxns))
    assert(isequal(sort(model.genes), sort(modelIn.genes)))
    assert(isequal(model.c, modelIn.c))

    % NOTE: model.rules and model.S are different from modelIn.S and modelIn.rules
    %       as the metabolites are not ordered in the same way.

    solverOK = changeCobraSolver('glpk');

    if solverOK
        % run an LP and compare the solutions
        solModel = optimizeCbModel(model);
        solModelIn = optimizeCbModel(modelIn);

        assert(abs(solModel.f - solModelIn.f) < tol)
        assert(solModel.stat == solModelIn.stat)
    end

    % remove the generated file
    delete('testData.xlsx');
else
    fprintf('\ntestWriteCbModel is not compatible with this version of MATLAB. Please upgrade your version of MATLAB.\n\n');
end

% change to old directory
cd(currentDir);

% Kill the workers
poolobj = gcp('nocreate');
delete(poolobj);
