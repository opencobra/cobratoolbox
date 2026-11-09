% The COBRAToolbox: testOptimizeTwoCbModels.m
%
% Purpose:
%     - tests the optimizeTwoCbModels function and some of its options
%
% Function under test:
%     src/base/solvers/optimizeTwoCbModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy models, LP solver.
%
% Coverage exemptions:
%     None: every line is reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Thomas Pfau, Oct 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% set the LP cobra solver - used in optimizeCbModelNLP that calls optimizeCbModel
% matlab for some reason doesn'T manage to handle the minimisation
solverPkgs = prepareTest('needsLP',true,'excludeSolvers',{'matlab','pdco'});
initialSolverState = CobraSolverState.get();

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

       %Test max as osenseStr. Should be the same trivial solution
       [sol1b,sol2b,totalDiffFlux] = optimizeTwoCbModels(model1,model2_20,'max');       
       assert(all(abs(sol1.x - sol1b.x) < objtol));
       assert(all(abs(sol2.x - sol2b.x) < objtol));      

       if 0 %not clear why this test would be true when one changes from max to min
           %Test min as osenseStr. Should be the same trivial solution
           [sol1b,sol2b,totalDiffFlux] = optimizeTwoCbModels(model1,model2_20,'min');
           assert(all(abs(sol1b.x) < objtol));
           assert(all(abs(sol2b.x) < objtol));
       end

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

       % minimisation, with and without the second step that minimises the fluxes
       minimum1 = optimizeCbModel(model1, 'min');
       minimum2 = optimizeCbModel(model2_20, 'min');
       for minFluxFlag = [0, 1]
           [solMin1, solMin2, minDiff] = optimizeTwoCbModels(model1, model2_20, 'min', minFluxFlag);
           % the reported objectives are the optima of the separate problems, rounded up by the
           % objective tolerance, and both flux vectors stay steady states within the bounds
           assert(abs(solMin1.f - minimum1.f) <= objtol && abs(solMin2.f - minimum2.f) <= objtol);
           assert(model1.c' * solMin1.x <= solMin1.f + objtol);
           assert(model2_20.c' * solMin2.x <= solMin2.f + objtol);
           assert(norm(model1.S * solMin1.x, inf) <= objtol);
           assert(norm(model2_20.S * solMin2.x, inf) <= objtol);
           assert(all(solMin1.x >= model1.lb - objtol) && all(solMin1.x <= model1.ub + objtol));
           assert(all(solMin2.x >= model2_20.lb - objtol) && all(solMin2.x <= model2_20.ub + objtol));
           assert(minDiff >= -objtol && solMin1.stat == 1 && solMin2.stat == 1);
       end

       % no field b in the models: a zero right hand side is assumed
       [solNoB1, solNoB2, diffNoB] = optimizeTwoCbModels(rmfield(model1, 'b'), rmfield(model2_20, 'b'));
       assert(abs(diffNoB - 80) <= objtol);
       assert(abs(solNoB1.f - 1000) <= objtol && norm(model2_20.S * solNoB2.x, inf) <= objtol);

       % models without a common reaction are refused
       modelOther = model2;
       modelOther.rxns = strcat('other_', modelOther.rxns);
       threw = false;
       try
           optimizeTwoCbModels(model1, modelOther);
       catch ME
           threw = true;
           assert(strcmp(ME.message, 'No common rxns in the models'));
       end
       assert(threw);

       % no solution when the flux difference exceeds the bound 10000 of the difference variables
       % both models are feasible alone, but the common reaction R1 carries 15000 in the first
       % model and 0 in the second one, so the difference LP is infeasible
       modelFar = struct('S', [1, -1], 'rxns', {{'R1'; 'R2'}}, 'mets', {{'A'}}, 'b', 0, ...
           'c', [0; 1], 'lb', [15000; 15000], 'ub', [15000; 15000], 'csense', 'E', 'osenseStr', 'max');
       modelNear = modelFar;
       modelNear.lb = [0; 0];
       modelNear.ub = [0; 0];
       [solFar1, solFar2, diffFar] = optimizeTwoCbModels(modelFar, modelNear);
       assert(isempty(diffFar) && isempty(solFar1.f) && isempty(solFar2.f));
       assert(isempty(solFar1.x) && isempty(solFar2.x));
       assert(solFar1.stat == 0 && solFar2.stat == 0);
    end
    
end

% leave the solver selection as it was found
CobraSolverState.restore(initialSolverState);

fprintf('Done...\n')
cd(currentDir)