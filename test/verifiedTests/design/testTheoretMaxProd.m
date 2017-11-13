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
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat']);

% change solver since qpng is unstable - to be changed after installation of gurobi
changeCobraSolver('pdco', 'QP');

% function calls
[ExRxns, MaxTheoOut] = theoretMaxProd(model, model.rxns(20)); % 'EX_ac(e)'
[ExRxns1, MaxTheoOut1] = theoretMaxProd(model, model.rxns(20), '', true, findExcRxns(model,0,0)); % not default options
[ExRxns2, MaxTheoOut2] = theoretMaxProd(model, model.rxns(20), 'pr_mw');
[ExRxns3, MaxTheoOut3] = theoretMaxProd(model, model.rxns(20), 'pr_other_mol');
[ExRxns4, MaxTheoOut4] = theoretMaxProd(model, model.rxns(20), 'pr_other_mw');
[ExRxns5, MaxTheoOut5] = theoretMaxProd(model, model.rxns(20), 'x'); % bad criterion

% tests
assert(abs(MaxTheoOut(1) - 20) < 1e-4); % 'EX_ac(e)'
assert(abs(MaxTheoOut1(1) - 1) < 1e-4); % the same but scaled to 0-1
assert(abs(MaxTheoOut2(1) - 1180) < 1e-4); % 'EX_ac(e)' in weight
assert(abs(MaxTheoOut3(1) - 20) < 1e-4); % 'EX_ac(e)'
assert(abs(MaxTheoOut4(1) - 900) < 1e-4); % 'EX_ac(e)' in weight yield
assert(isequal(MaxTheoOut5, zeros(20, 1))); % bad criterion returns only 0s

% change to old directory
cd(currentDir);
