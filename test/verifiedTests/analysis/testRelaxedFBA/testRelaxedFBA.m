% The COBRAToolbox: testRelaxedFBA.m
%
% Purpose:
%     - testRelaxedFBA tests the relaxedFBA functionality
%


solverPkgs = prepareTest('needsLP',true);

%Define Test Model 1
rxnForms = {' -> A[c]','A[c] -> B[c]','B[c] -> C[c]', 'B[c] -> D[c]','D[c] -> C[c]','C[c] ->'};
rxnNames = {'Ain','AB','BC','BD','DC', 'Cout'};
model = createModel(rxnNames, rxnNames,rxnForms);
model.lb(3) = 1; 
model.lb(4) = 2; %BD
model.ub(6) = 2;
modelWorking = changeRxnBounds(model,'Cout',1000,'u');
modelWithBlockedExport = changeRxnBounds(model,'Cout',0,'b');
modelWithPartiallyClosedExchangers = addReaction(modelWithBlockedExport,'Dout','reactionFormula','D[c] ->','lowerBound',0,'upperBound',2);
modelWithPartiallyClosedExchangers = changeRxnBounds(modelWithPartiallyClosedExchangers,'DC',-1000,'l');
modelWithOneFiniteBound = changeRxnBounds(model,model.rxns{3},30,'u');
modelWithFiniteBounds = changeRxnBounds(modelWithOneFiniteBound,model.rxns{4},30,'u');

%Save warnings settings.
warn = warning();
%Turn off warnings for the test.
warning('off')

for k = 1:numel(solverPkgs.LP)
    changeCobraSolver(solverPkgs.LP(k),'all');
    [relaxation,relaxmodel] = relaxedFBA(model);
    %only one modification is necessary.
    assert(nnz(relaxation.r)+nnz(relaxation.p)+nnz(relaxation.q)==1); 
    sol = optimizeCbModel(relaxmodel);
    % This model is now feasible.
    assert(sol.stat == 1); 
    [relaxation,relaxmodel] = relaxedFBA(modelWorking);
    sol = optimizeCbModel(modelWorking);
    assert(sol.stat == 1);
    %No relaxation necessary!
    assert(nnz(relaxation.r) == 0 && nnz(relaxation.p) == 0 && nnz(relaxation.q) == 0);

    %Use some parameters.
    
	%weighting on relaxation of steady state constraints S*v = b
    %Allow free relaxation on steady state constraints.
    param = struct();
    param.lambda0   = 0;
    param.lambda1   = 0;
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    %Nothing, but the steady state constraints should change...
    assert(nnz(relaxation.p) == 0 && nnz(relaxation.q) ==0);
    
    %Test, what happens, if we do not allow any relaxation
    param = struct();
    param.internalRelax = 0;
    param.exchangeRelax = 0;
    param.steadyStateRelax = 0;
    %This will indicate, that the problem is still infeasible.
    assert(verifyCobraFunctionError(@() relaxedFBA(model,param),'Problem infeasible !'));
    
    %Now, allow only relaxations on the Exchange reactions
    param.exchangeRelax = 2;
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(relaxation.q(6) >= 1)
    assert(nnz(relaxation.p) == 0 && nnz(relaxation.r) == 0);
    
    %Test that the model with blocked exchangers cannot be relaxed.
    param.exchangeRelax = 1;
    assert(verifyCobraFunctionError(@() relaxedFBA(modelWithBlockedExport,param),'Problem infeasible !'));
    
    %This should work with only one blocked exchanger and an alternative route ! But doesn't
    %currently
    %[relaxation,relaxmodel] = relaxedFBA(modelWithPartiallyClosedExchangers,param);
    %assert(relaxation.q(7) >= 1)
    %assert(nnz(relaxation.p) == 0 && nnz(relaxation.r) == 0);
    
    %Test internalRelax
    param.exchangeRelax = 0;
    param.internalRelax = 2;
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(nnz(relaxation.r) == 0)
    assert(nnz(relaxation.p(3:4)) == 1 || nnz(relaxation.q(3:4)) == 1);
    
    % Test that it does not work with reactions on finite bounds.    
    param.internalRelax = 1;
    param.minLB = -1000;    %Otherwise minLB would be 0 on the model, and the bounded reactions would not be considered as finite bounded.
    assert(verifyCobraFunctionError(@() relaxedFBA(modelWithFiniteBounds,param),'Problem infeasible !'));
    
    %But this works, if we allow relaxation on finite bound internals.
    param.internalRelax = 2;
    [relaxation,relaxmodel] = relaxedFBA(modelWithFiniteBounds,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(nnz(relaxation.r) == 0)
    assert(nnz(relaxation.p(3:4)) == 1 || nnz(relaxation.q(3:4)) == 1);

    %And test steady state relaxation
    param.internalRelax = 0;
    param.steadyStateRelax = 1;
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(relaxation.r(4) == -1); %This is the smallest relaxation.
    assert(nnz(relaxation.p) == 0 && nnz(relaxation.q) == 0);
    
    %Now lets also test exclude metabolites
    param.excludedMetabolites = false(size(model.mets));
    param.excludedMetabolites(4) = true; %exclude the previous solution.
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(nnz(relaxation.r) == 1); %Some other minimal solution should be found.
    assert(relaxation.r(4) == 0); %This is the smallest relaxation.
    assert(nnz(relaxation.p) == 0 && nnz(relaxation.q) == 0);
    
    %Lets test excludeReactions
    param = struct();
    param.internalRelax = 1; %Only reaction infinite bounds i.e. R4
    param.steadyStateRelax = 0; %No steady sttestate relaxation
    param.excludedReactions = false(size(model.rxns));
    param.excludedReactions(6) = true; %Exclude Cout.
    [relaxation,relaxmodel] = relaxedFBA(modelWithOneFiniteBound,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(nnz(relaxation.r) == 0); %Some other minimal solution should be found.
    assert(relaxation.p(4) == 1); %This is the only possible relaxation.
    assert(nnz(relaxation.p) == 1); %And nothing else.
    assert(nnz(relaxation.q) == 0);    
    
end
%restore warnings settings.
warning(warn)

