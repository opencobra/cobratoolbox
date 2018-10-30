% The COBRAToolbox: testFASTCC.m
%
% Purpose:
%     - test FASTCC algorithm
%
% Authors:
%     - Original file: Thomas Pfau, May 2016
%     - Fix by @fplanes July 2017
%     - CI integration: Laurent Heirendt July 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFASTCC'));
cd(fileDir);

%load a model
model = getDistributedModel('ecoli_core_model.mat');
% create a model with fructose
modelWithFru = changeRxnBounds(model,'EX_fru(e)',-100,'l');

% set paarmeters
epsilon = 1e-4;
printLevel = 2;
modeFlag = 0;

%by default, fructose updatek, fumarate uptake and corresponding reactions
%cannot be used.
inactives = {'EX_fru(e)', 'EX_fum(e)','EX_gln_L(e)', 'EX_mal_L(e)', 'FRUpts2', 'FUMt2_2', 'GLNabc','MALt2_2' };
fructoseRelated = {'EX_fru(e)', 'FRUpts2'};

% define the solver packages to be used to run this test
solverPkgs = prepareTest('needsLP',true);

for k = 1:length(solverPkgs.LP)
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    fprintf('   Testing FASTCC using %s ... \n', solverPkgs.LP{k});
    A = fastcc(model, epsilon, printLevel,modeFlag);
    assert(isempty(setxor(setdiff(model.rxns,model.rxns(A)),inactives)));
    % Open up the Fructose channel
    A = fastcc(modelWithFru, epsilon, printLevel,modeFlag);
    % now, everything from the inactives except the fructose reactions are
    % not in A
    assert(isempty(setxor(setdiff(modelWithFru.rxns,modelWithFru.rxns(A)),setdiff(inactives,fructoseRelated))));
    % output a success message
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
