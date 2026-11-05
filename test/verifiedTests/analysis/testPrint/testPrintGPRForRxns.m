% The COBRAToolbox: testPrintGPRForRxns.m
%
% Purpose:
%     - To test the printOut functionality for printGPRForRxns (and its
%     wrapper findGPRsFromRxns
%
% Function under test:
%     src/analysis/exploration/printGPRForRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Thomas Pfau December 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintGPRForRxns'));
cd(fileDir);

% this test needs no solver, toolbox or particular operating system
prepareTest();

model = getDistributedModel('ecoli_core_model.mat');

% remove old generated file
delete('printGPR.txt');

diary('printGPR.txt');
printGPRForRxns(model,model.rxns(1:5));
diary off
text1 = importdata('refData_printGPRForRxns.txt');
text2 = importdata('printGPR.txt');

assert(isequal(text1, text2));

% remove the generated file
delete('printGPR.txt');

%Now, we have tested, that the printout matches. So now we will test
%different options.
modelTemp = rmfield(model,'grRules'); %remove the grRules.

gprs = printGPRForRxns(model,model.rxns(1:5));
gprs2 = findGPRFromRxns(modelTemp,model.rxns(1:5));
%We assume, that the rules field has the same structure. Not necessarily
%true but works here. Normally, to check equality, it would be necessary to
%parse the formulas and then check their equality.
assert(isequal(gprs,gprs2));
    
%Now, this cannot give a result any more
modelTemp2 = rmfield(modelTemp,'genes');
gprs = findGPRFromRxns(modelTemp2,modelTemp2.rxns(1:5));
assert(all(cellfun(@isempty, gprs)));

%The same for a missing rules field:
modelTemp2 = rmfield(modelTemp,'rules');
gprs = findGPRFromRxns(modelTemp2,modelTemp2.rxns(1:5));
assert(all(cellfun(@isempty, gprs)));

%Give an error, if a reaction is not present
assert(verifyCobraFunctionError('findGPRFromRxns','inputs',{model,'A'}));

% Finally test, that no output is generated from findGPRFromRxns
diary findGPR.txt
findGPRFromRxns(modelTemp2,modelTemp2.rxns(1:5));
diary off 
text = importdata('findGPR.txt');
assert(isempty(text));
delete('findGPR.txt');

%% reactions can be given by their position; a position outside the model is refused
gprs = printGPRForRxns(model, [1, 3], 0);
assert(isequal(gprs, model.grRules([1, 3])));
assert(verifyCobraFunctionError('printGPRForRxns', 'inputs', {model, numel(model.rxns) + 1}, ...
    'testMessage', 'Some indices provided are larger than the number of reactions.'));

% change the directory
cd(currentDir)
