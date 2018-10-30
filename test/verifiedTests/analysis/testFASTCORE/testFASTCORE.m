% The COBRAToolbox: testFASTCORE
%
% Purpose:
%     - test FASTCORE algorithm
%
% Authors:
%     - Ronan Fleming, August 2015
%     - Modified by Thomas Pfau, May 2016
%     - Fix by @fplanes July 2017
%     - CI integration: Laurent Heirendt July 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFASTCORE'));
cd(fileDir);


% define the solver packages to be used to run this test
% for some reason, linprog cannot cope with fastcore LP9
% quadMinos and dqqMinos don't work with parallel processing
solverPkgs = prepareTest('needsLP',true,'excludeSolvers',{'matlab','dqqMinos','quadMinos'});

% load a model
model = getDistributedModel('ecoli_core_model.mat');

% inactives (these are known inactive reactions under the normal conditions
inactives = {'EX_fru(e)', 'EX_fum(e)','EX_gln_L(e)', 'EX_mal_L(e)', 'FRUpts2', 'FUMt2_2', 'GLNabc','MALt2_2' };

% eliminate these reactions so that the model is consistent
model = removeRxns(model,inactives);
% test a reduction to the glycolytic pathway (+ exchanges)
glycolysis = findRxnsFromSubSystem(model,'Glycolysis/Gluconeogenesis');

% set parameters
epsilon = 1e-4;
printLevel = 2;
modeFlag = 0;


for k = 1:length(solverPkgs.LP)
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    fprintf('   Testing FASTCORE using %s ... \n', solverPkgs.LP{k});
    fcModel = fastcore(model,find(ismember(model.rxns,glycolysis)),epsilon,printLevel);
    assert(all(ismember(glycolysis,fcModel.rxns)));    
    [mins,maxs] = fluxVariability(fcModel,0);
    assert(all(max([abs(mins),abs(maxs)],[],2)>epsilon));
end

% change the directory
cd(currentDir)
