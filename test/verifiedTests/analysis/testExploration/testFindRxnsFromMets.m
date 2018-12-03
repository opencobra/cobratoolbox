% The COBRAToolbox: testFindRxnsFromMets.m
%
% Purpose:
%     - Tests the functionality of findRxnFromMets with all available
%     parameters
%
% Authors:
%     - Original file: Thomas Pfau Jan 2018
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsFromMets'));
cd(fileDir);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% First, find all reactions involved with 3pg
singleTestMet = model.mets{3};
involvedReacs = {'Biomass_Ecoli_core_w_GAM';'PGK';'PGM'};
consuming = involvedReacs;
producing = involvedReacs(2:3);
reacs = findRxnsFromMets(model,singleTestMet);
assert(isempty(setxor(involvedReacs,reacs)));
reacs = findRxnsFromMets(model,singleTestMet,'consumersOnly',true);
assert(isempty(setxor(consuming,reacs)));
reacs = findRxnsFromMets(model,singleTestMet,'producersOnly',true);
assert(isempty(setxor(producing,reacs)));

% now, we change the bounds of PGK to not function in the forward direction
modelChanged = changeRxnBounds(model,'PGK',0,'l');
modelChanged = changeRxnBounds(modelChanged,'PGM',0,'u');
reacs = findRxnsFromMets(modelChanged,singleTestMet,'producersOnly',true);
assert(isempty(reacs));

% now, test the same with consumers and the PGM reaction, only biomass is
% left.
modelChanged = changeRxnBounds(model,'PGM',0,'l');
modelChanged = changeRxnBounds(modelChanged,'PGK',0,'u');
reacs = findRxnsFromMets(modelChanged,singleTestMet,'consumersOnly',true);
assert(isempty(setxor(involvedReacs(1),reacs)));

% lets test 2 metabolites (2pg and 3pg)
dualTestMet = model.mets(2:3);
involvedReacs = {'Biomass_Ecoli_core_w_GAM';'ENO';'PGM';'PGK'};
consuming = involvedReacs;
producing = involvedReacs(2:4);
reacs = findRxnsFromMets(model,dualTestMet);
assert(isempty(setxor(involvedReacs,reacs)));
reacs = findRxnsFromMets(model,dualTestMet,'consumersOnly',true);
assert(isempty(setxor(consuming,reacs)));
reacs = findRxnsFromMets(model,dualTestMet,'producersOnly',true);
assert(isempty(setxor(producing,reacs)));

% test printout.
% build comparison text
res = printRxnFormula(model,'PGM');
compText = res{1}; % this is sufficient;

% create diary
diaryFile = 'RxnsFromMetTest';
diary(diaryFile)
reacs = findRxnsFromMets(model,dualTestMet,'containsAll',true,'printFlag',1);
assert(isempty(setxor({'PGM'},reacs)));
diary off
text = importdata(diaryFile);
assert(~isempty(strfind(strrep(text,'\n',''),compText)));
%cleanup
delete(diaryFile);


% test implicit printOut is silent, if no output is created
diary(diaryFile)
[reacs,forms] = findRxnsFromMets(model,dualTestMet,'containsAll',true);
diary off;
text = importdata(diaryFile);
% ITs not found in the output
assert(isempty(strfind(text,compText)));
% but is equal to printRxnFormula
assert(isequal(forms,res))
%cleanup
delete(diaryFile);




% change the directory
cd(currentDir)
