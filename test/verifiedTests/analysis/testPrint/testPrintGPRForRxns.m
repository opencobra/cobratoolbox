% The COBRAToolbox: testPrintGPRForRxns.m
%
% Purpose:
%     - To test the printOut functionality for printGPRForRxns (and its
%     wrapper findGPRsFromRxns
%
% Authors:
%     - Thomas Pfau December 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintGPRForRxns'));
cd(fileDir);

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

% change the directory
cd(currentDir)
