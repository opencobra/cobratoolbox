% The COBRAToolbox: testTheoretMaxProd.m
%
% Purpose:
%     - test the theoretMaxProd function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTheoretMaxProd'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);

% function calls
[ExRxns, MaxTheoOut] = theoretMaxProd(model, '', model.rxns(20)); % 'EX_ac(e)'
[ExRxns1, MaxTheoOut1] = theoretMaxProd(model, '', model.rxns(20), true, findExcRxns(model,0,0)); % not default options
[ExRxns2, MaxTheoOut2] = theoretMaxProd(model, 'pr_mw', model.rxns(20));
[ExRxns3, MaxTheoOut3] = theoretMaxProd(model, 'pr_other_mol', model.rxns(20));
[ExRxns4, MaxTheoOut4] = theoretMaxProd(model, 'pr_other_mw', model.rxns(20));
[ExRxns5, MaxTheoOut5] = theoretMaxProd(model, 'x', model.rxns(20)); % bad criterion

% tests
assert(isequal(MaxTheoOut(1), 20)); % 'EX_ac(e)'
assert(isequal(MaxTheoOut1(1), 1)); % the same but scaled to 0-1
assert(isequal(MaxTheoOut2(1), 1180)); % 'EX_ac(e)' in weight
assert(isequal(MaxTheoOut3(1), 20)); % 'EX_ac(e)'
assert(isequal(MaxTheoOut4(1), 900)); % 'EX_ac(e)' in weight yield
assert(isequal(MaxTheoOut5, zeros(20, 1))); % bad criterion returns only 0s

% change to old directory
cd(currentDir);
