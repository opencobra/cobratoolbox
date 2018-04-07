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
model = getDistributedModel('ecoli_core_model.mat');

% change solver since qpng is unstable - to be changed after installation of gurobi
% TODO: test this for multiple solvers. 
changeCobraSolver('pdco', 'QP');

%Get the molecular weights of the compounds in the model.
[mw,EMatrix,elements] = computeMW(model, [], false);

%lets calc a simple optimization
tempModel = model;
acExPos = ismember(model.rxns,'EX_ac(e)');
tempModel.c = double(acExPos);
FBAsol = optimizeCbModel(tempModel);

% function calls
[ExRxns, MaxTheoOut] = theoretMaxProd(model, 'EX_glc(e)'); % Max 'EX_ac(e)' flux (unique)
allExPos = ismember(model.rxns,ExRxns);
%Determine the Exchangers and their respective exchanged metabolite +
%Weights
exWeights = cellfun(@(x) mw(find(model.S(:,ismember(model.rxns,x)))),ExRxns);
carbEx = cellfun(@(x) EMatrix(find(model.S(:,ismember(model.rxns,x))),ismember(elements,'C')) > 0 ,ExRxns);
carbExPos = ismember(model.rxns, ExRxns(carbEx));
acPosInExch = ismember(ExRxns,'EX_ac(e)');

%Alternative calls
[ExRxns1, MaxTheoOut1] = theoretMaxProd(model, 'EX_glc(e)', '', true, findExcRxns(model,0,0)); % Scaled to 0-1
[ExRxns2, MaxTheoOut2] = theoretMaxProd(model, 'EX_glc(e)', 'pr_mw'); %Compared to other mw
[ExRxns3, MaxTheoOut3] = theoretMaxProd(model, 'EX_glc(e)', 'pr_other_mol');
[ExRxns4, MaxTheoOut4] = theoretMaxProd(model, 'EX_glc(e)', 'pr_other_mw');
[ExRxns5, MaxTheoOut5] = theoretMaxProd(model, 'EX_glc(e)', 'x'); % bad criterion

% We assume, that the solver is deterministic, i.e. the solution found for
% the basic call is the same as for all the other calls.
assert(abs(MaxTheoOut(1) - 20) < 1e-4); % 'EX_ac(e)'
assert(abs(MaxTheoOut1(1) - 2) < 1e-4); % the same but scaled to glucose uptake flux (10)

assert(abs(MaxTheoOut2(1) - FBAsol.x(acExPos)*exWeights(1)) < 1e-4); % 'EX_ac(e)' in weight
%All (molar) exports (>0) without acetate and with 
assert(abs(MaxTheoOut3(1) - sum(FBAsol.x(allExPos & ~acExPos & FBAsol.x > 0 & carbExPos) )) < 1e-4); % 'EX_ac(e)'
% Sum of Molecular weights of all Carbon Exporters ( > 0) without Acetate
assert(abs(MaxTheoOut4(1) - sum(FBAsol.x(allExPos).*(FBAsol.x(allExPos)>0).*exWeights.*carbEx.*~acPosInExch)) < 1e-4); % 'EX_ac(e)' in weight yield
assert(isequal(MaxTheoOut5, zeros(20, 1))); % bad criterion returns only 0s

% change to old directory
cd(currentDir);
