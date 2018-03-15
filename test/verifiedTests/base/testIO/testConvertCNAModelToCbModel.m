% The COBRAToolbox: testConvertCNAModelToCbModel.m
%
% Purpose:
%     - convert a CNA model to a COBRA model and vice versa
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteSBML'));
cd(fileDir);

% check if CNA is properly installed
statusCNA = checkCNAinstallation();

if statusCNA
    model = getDistributedModel('ecoli_core_model.mat');

    % load reference data
    load('refData_cnaModel.mat')

    % convert a COBRA model to a CNA model
    cnaModel_new = convertCbModelToCNAModel(model);

    % assert if the cnaModel_new is equal to the reference CNA model
    assert(isequaln(cnaModel_new, cnaModel));

    % convert the reference CNA model to the COBRA model
    model_new = convertCNAModelToCbModel(cnaModel);

    assert(isequal(model_new.rxns, model.rxns));
    assert(isequal(model_new.mets, model.mets));
    assert(isequal(model_new.S, model.S));
    assert(isequal(model_new.lb, model.lb));
    assert(isequal(model_new.ub, model.ub));
    %Osense is no longer a model field, so we need to check, whether the
    %generated LPproblems are the same (or we have to make a lot of if
    %statements...)
    LPproblemA = buildLPproblemFromModel(model_new);    
    LPproblemB = buildLPproblemFromModel(model);
    assert(isequal(LPproblemA.osense*LPproblemA.c, LPproblemB.osense*LPproblemB.c));
    assert(isequal(model_new.metNames, model.metNames));
    assert(isequal(model_new.b, model.b));
    % Note: rxnNames is different
end

% change the directory
cd(currentDir)