% The COBRAToolbox: testOptimizeTwoCbModels.m
%
% Purpose:
%     - tests the optimizeTwoCbModels function and some of its options
%
% Authors:
%     - Thomas Pfau, Oct 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% set the LP cobra solver - used in optimizeCbModelNLP that calls optimizeCbModel
% matlab for some reason doesn'T manage to handle the minimisation
solverPkgs = prepareTest('needsLP',true,'excludeSolvers',{'matlab'});

% initialize the test
fileDir = fileparts(which('testOptimizeTwoCbModels'));
cd(fileDir);

model1 = createToyModelForAltOpts();
model2 = createToyModelForAltOpts();
model1 = changeObjective(model1,'R3');
model2 = changeObjective(model2,'R6');

objtol = 1e-4;

for k = 1:length(solverPkgs.LP)
    
    solverOk = changeCobraSolver(solverPkgs.LP{k},'LP',0);
    
    if solverOk
        fprintf('   Running optimizeTwoCbModels using %s ... \n', solverPkgs.LP{k});
       [sol1,sol2,totalDiffFlux] = optimizeTwoCbModels(model1,model2);       
       %There is a difference of 4 reactions carrying a flux of 1000. 
       assert(abs((totalDiffFlux - 4000)) <= objtol);
       %And the objective is 1000;
       assert(abs(sol1.f-1000) <= objtol);
       assert(abs(sol2.f-1000) <= objtol);
       
       %Now, The difference drops to 80, as the four reactions only need to
       %carry a difference of 20 flux units.       
       model2_20 = changeRxnBounds(model2,'R7',20,'u');
       [sol1,sol2,totalDiffFlux] = optimizeTwoCbModels(model1,model2_20);       
       assert(abs((totalDiffFlux - 80)) <= objtol);
       
       %Test min as osenseStr. Should be the same trivial solution
       [sol1,sol2,totalDiffFlux] = optimizeTwoCbModels(model1,model2_20,'min');       
       assert(all(abs(sol1.x) < objtol));
       assert(all(abs(sol2.x ) < objtol));       
       
       %Now, we will add a reaction that allows higher conversion with
       %lower flux
       %And run this with verbose output.
       model1_Add = addReaction(model1,'R5a','reactionFormula','3 D -> 3 F');       
       model2_Add = addReaction(model2,'R5a','reactionFormula','3 D -> 3 F');       
       [sol1,sol2,totalDiffFlux] = optimizeTwoCbModels(model1_Add,model2_Add,'max',1,1);       
       %The difference is still 80 (this did not change)
       assert(abs((totalDiffFlux - 4000)) <= objtol);
       %But R5 should now not be used, and instead R5a
       assert(abs(sol1.x(ismember(model1_Add.rxns,'R5'))) <= objtol );
       assert(abs(sol2.x(ismember(model2_Add.rxns,'R5')) ) <= objtol );
       assert(sol1.x(ismember(model1_Add.rxns,'R5a')) >= 0);
       assert(sol2.x(ismember(model2_Add.rxns,'R5a')) >= 0);
    end
    
end

fprintf('Done...\n')
cd(currentDir)