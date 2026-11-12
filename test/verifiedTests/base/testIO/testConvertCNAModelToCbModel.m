% The COBRAToolbox: testConvertCNAModelToCbModel.m
%
% Purpose:
%     - convert a CNA model to a COBRA model and vice versa
%     CellNetAnalyzer is not distributed with the toolbox. Without it, the conversion is run
%     through the real interface function CNAcna2cobra, with the two CellNetAnalyzer pieces it
%     needs (startcna, CNAgetMFNetwork) replaced by test doubles in a temporary folder.
%
% Function under test:
%     src/base/io/convertCNAModelToCbModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model conversion, no solver.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Without CellNetAnalyzer an output is never assigned
%       SEVERITY: error
%       TRIGGER: model = convertCNAModelToCbModel(cnaModel) when CellNetAnalyzer is not installed
%       OBSERVED: MATLAB stops with "Output argument model not assigned"; only with no output
%         requested does the call return, after the message of checkCNAinstallation
%       EXPECTED: an error that says CellNetAnalyzer is needed
%       LINES: 31
%
% Authors:
%     - Original file: COBRA Toolbox
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteSBML'));
cd(fileDir);

% no solver, toolbox or operating system requirement
prepareTest();

% check if CNA is properly installed
statusCNA = checkCNAinstallation();

model = getDistributedModel('ecoli_core_model.mat');

% load reference data
load('refData_cnaModel.mat')

if statusCNA
    % convert a COBRA model to a CNA model
    cnaModel_new = convertCbModelToCNAModel(model);
    
    % assert if the cnaModel_new is equal to the reference CNA model
    if 0
        assert(isequaln(cnaModel_new, cnaModel));
    else
        % function [cnap, errval]= CNAgenerateMFNetwork(cnap,nodisp) in CellNetAnalyzer: API function CNAgenerateMFNetwork
        % has been updated to include new default fields, that do not
        % match, so remove them. Probably cnaModel_new needs to be updated.
        if isfield(cnaModel_new,'color1')
            cnaModel_new= rmfield(cnaModel_new,{'color1','color2','color3','color4','textColor','macroSynthColor','specBoxColor','unsaved_changes'});
        end
        assert(isequaln(cnaModel_new, cnaModel));
    end

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
    LPproblemA = buildOptProblemFromModel(model_new);    
    LPproblemB = buildOptProblemFromModel(model);
    assert(isequal(LPproblemA.osense*LPproblemA.c, LPproblemB.osense*LPproblemB.c));
    assert(isequal(model_new.metNames, model.metNames));
    assert(isequal(model_new.b, model.b));
    % Note: rxnNames is different
else
    %% without CellNetAnalyzer the call only reports it, at the default and at a given printLevel
    capturedOutput = evalc('convertCNAModelToCbModel(cnaModel)');
    assert(contains(capturedOutput, 'CellNetAnalyzer is not properly installed'));
    capturedOutput = evalc('convertCNAModelToCbModel(cnaModel, 0)');
    assert(isempty(capturedOutput));

    %% the conversion, with the CellNetAnalyzer functions replaced by test doubles
    doubleFolder = tempname;
    mkdir(doubleFolder);
    fid = fopen([doubleFolder filesep 'startcna.m'], 'w');
    fprintf(fid, 'function startcna()\nend\n');
    fclose(fid);
    fid = fopen([doubleFolder filesep 'CNAgetMFNetwork.m'], 'w');
    fprintf(fid, 'function cnap = CNAgetMFNetwork(cnap)\nend\n');
    fclose(fid);
    addpath(doubleFolder);
    try
        model_new = convertCNAModelToCbModel(cnaModel, 0);
    catch ME
        rmpath(doubleFolder);
        rmdir(doubleFolder, 's');
        rethrow(ME);
    end
    rmpath(doubleFolder);
    rmdir(doubleFolder, 's');

    % the reference CNA project is the core model: the network and the bounds must come back
    assert(isequal(model_new.rxns, model.rxns));
    assert(isequal(model_new.mets, model.mets));
    assert(isequal(model_new.S, model.S));
    assert(isequal(model_new.lb, model.lb));
    assert(isequal(model_new.ub, model.ub));
    assert(isequal(model_new.metNames, model.metNames));
    assert(isequal(model_new.b, model.b));
end

% change the directory
cd(currentDir)