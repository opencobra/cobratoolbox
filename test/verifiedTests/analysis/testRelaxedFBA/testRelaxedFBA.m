% The COBRAToolbox: testRelaxedFBA.m
%
% Purpose:
%     - testRelaxedFBA tests the relaxedFBA functionality
%
% Function under test:
%     src/analysis/relaxedFBA/relaxedFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation on a toy model and on the toy GECKO model with extra variables.
%
% Coverage exemptions:
%     Line 336: unreachable, it follows the error statement of the same branch.
%     Lines 729-740: dead code on the MATLAB releases in use, this branch is only taken before R2022a.
%     Lines 745-746: defective input skipped, a non-finite S goes to the solver first: gurobi stops with a solver error at the feasibility check and glpk can end the MATLAB session.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Extra variables given only by model.D stop with an error
%       SEVERITY: error
%       TRIGGER: a model with the field D and without the fields C and E
%       OBSERVED: only a pair of C, D and E gets the third matrix filled with zeros, so the
%         expansion of the model reads the absent field C and stops with "Unrecognized field name C"
%       EXPECTED: the missing C and E filled with zeros, as for the other combinations
%       LINES: 380
%     - DEFECT: A generic LP without rxns and mets stops with an error
%       SEVERITY: limitation
%       TRIGGER: relaxedFBA(struct with A, b, c, lb, ub, csense and SIntRxnBool only)
%       OBSERVED: the feasibility check calls optimizeCbModel, whose model check stops with "The
%         input model does have inconsistent fields", although the help says that mets and rxns are
%         only required if SIntRxnBool is absent. The generic LP below therefore has mets and rxns.
%       EXPECTED: a relaxation of the generic LP
%       LINES: 704
%
% Authors:
%     - Thomas Pfau 18/04/2018
%     - Farid Zare  04/06/2025 Improved formatting
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% add path to toy gecko model
dirToy = fileparts(which('createToyGeckoModel'));
addpath(dirToy);

% initialize the test
fileDir = fileparts(which('testRelaxedFBA'));
cd(fileDir);

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

%Define Test Model 2: load gecko style model
[geckoToyMd, ~, ~] = createToyGeckoModel();

% the infeasible toy model is kept for the sections after the loop
toyModel = model;

for k = 1:numel(solverPkgs.LP)
    changeCobraSolver(solverPkgs.LP{k},'all');
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
    sol = relaxedFBA(model, param);
    assert(~sol.stat); % An infeasible solution
    
    %Now, allow only relaxations on the Exchange reactions
    param.exchangeRelax = 2;
    [relaxation,relaxmodel] = relaxedFBA(model,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(relaxation.q(6) >= 1)
    assert(nnz(relaxation.p) == 0 && nnz(relaxation.r) == 0);
    
    %Test that the model with blocked exchangers cannot be relaxed.
    param.exchangeRelax = 1;
    sol = relaxedFBA(modelWithBlockedExport, param);
    assert(~sol.stat); % An infeasible solution
        
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
    sol = relaxedFBA(modelWithFiniteBounds, param);
    assert(~sol.stat); % An infeasible solution
    
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
    assert(relaxation.r(3) == -1); %This is the smallest relaxation.
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
    param.steadyStateRelax = 0; %No steady state relaxation
    param.excludedReactions = false(size(model.rxns));
    param.excludedReactions(6) = true; %Exclude Cout.
    [relaxation,relaxmodel] = relaxedFBA(modelWithOneFiniteBound,param);
    sol = optimizeCbModel(relaxmodel);
    assert(sol.stat == 1);
    assert(nnz(relaxation.r) == 0); %Some other minimal solution should be found.
    assert(relaxation.p(4) == 1); %This is the only possible relaxation.
    assert(nnz(relaxation.p) == 1); %And nothing else.
    assert(nnz(relaxation.q) == 0);    

    % test extra variables
    model = geckoToyMd;
    model.lb = [0.6; 0.6]; % forces model to become unfeasible: epool = e1 + e2  = 0.6 + 0.6 = 1.2 contradicts epool < 1 (its evarub =1)
    LP0 = buildOptProblemFromModel(model, true, struct());
    LPsol0 = solveCobraLP(LP0); % do not use optimizeCbModel as it does not consider extra variables
    assert(LPsol0.stat ~=1) % assert model is infeasible before
    param = struct();
    param.excludedReactions = true(numel(model.rxns), 1); % no relaxation flux bounds
    param.excludedEvarLB = true(numel(model.evars), 1); % no relaxation on LB of evars (always positive)
    param.steadyStateRelax = 0; % no relaxation of steady-sate
    param.extraConstraintRelax = 0; % no relaxation of extra constraint
    [sol, rlxMd] = relaxedFBA(model, param);
    LP1 = buildOptProblemFromModel(rlxMd, true, struct());
    LPsol1 = solveCobraLP(LP1); % do not use optimizeCbModel as it does not consider extra variables
    assert(LPsol1.stat == 1 | LPsol1.stat == 3) % model is feasible after relaxation
    assert(nnz(sol.r) == 0) % no relaxation on steady state happened
    assert(nnz(sol.rCtrs) == 0) % no relaxation of extra constraints happened
    assert(nnz(sol.p)== 0) % no relaxation on flux lower bounds
    assert(nnz(sol.q) == 0) % no relaxation on flux upper bounds
    assert(nnz(sol.pEvar) == 0) % no relaxation on extra variables lower bounds
    assert(nnz(sol.qEvar) ~= 0) % relaxation on extra variables upper bounds
    disp(table(model.evars, sol.qEvar, 'VariableNames', {'Evar', 'qEvar'}));
end

%% the sections below use the first solver

changeCobraSolver(solverPkgs.LP{1}, 'all', 0);
[nMetsToy, nRxnsToy] = size(toyModel.S);

% a relaxed model is feasible if its full problem, with extra variables and constraints, is solved
isFeasible = @(relaxed) getfield(solveCobraLP(buildOptProblemFromModel(relaxed, true, struct())), 'stat') == 1;

%% values of the relaxation parameters that are out of range are refused

for field = {'internalRelax', 'exchangeRelax', 'steadyStateRelax', 'extraVarRelax', 'extraConstraintRelax'}
    assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {toyModel, struct(field{1}, 3)}, ...
                                    'testMessage', ['Incorrect input : ', field{1}]));
end

%% a generic LP: the matrix A is used as S

genericLP = struct('A', toyModel.S, 'b', toyModel.b, 'c', toyModel.c, 'lb', toyModel.lb, 'ub', toyModel.ub, ...
                   'csense', toyModel.csense, 'rxns', {toyModel.rxns}, 'mets', {toyModel.mets});
[relaxation, relaxedLP] = relaxedFBA(genericLP);
assert(relaxation.stat == 1);
assert(isfield(relaxedLP, 'S') && ~isfield(relaxedLP, 'A'));
assert(isFeasible(relaxedLP));

% without SIntRxnBool every column counts as internal, so nothing is left to relax here ...
sol = relaxedFBA(genericLP, struct('internalRelax', 0, 'steadyStateRelax', 0));
assert(~sol.stat);

% ... and a given SIntRxnBool is kept: the exchange reactions can be relaxed
genericLP.SIntRxnBool = [false; true; true; true; true; false];
relaxation = relaxedFBA(genericLP, struct('internalRelax', 0, 'steadyStateRelax', 0));
assert(relaxation.stat == 1);
assert(relaxation.q(6) >= 1);

%% internal and external reactions can be given by the fields of the model

% SConsistentRxnBool replaces SIntRxnBool: only Ain and Cout are left to relax
modelFlags = toyModel;
modelFlags.SConsistentRxnBool = [false; true; true; true; true; false];
relaxation = relaxedFBA(modelFlags, struct('internalRelax', 0, 'steadyStateRelax', 0));
assert(relaxation.stat == 1);
assert(relaxation.q(6) >= 1);

% without any exchange relaxation that is infeasible, ...
sol = relaxedFBA(modelFlags, struct('internalRelax', 0, 'exchangeRelax', 0, 'steadyStateRelax', 0));
assert(~sol.stat);

% ... unless SExtRxnBool says that only Ain is external: Cout is then neither internal nor external
modelFlags.SExtRxnBool = [true; false; false; false; false; false];
relaxation = relaxedFBA(modelFlags, struct('internalRelax', 0, 'exchangeRelax', 0, 'steadyStateRelax', 0));
assert(relaxation.stat == 1);
assert(relaxation.q(6) >= 1);

%% coupling constraints C*v <= d: inconsistent input is refused

% at most 100 units through Ain
modelC = toyModel;
modelC.C = sparse(1, 1, 1, 1, nRxnsToy);
modelC.d = 100;
modelC.dsense = 'L';
modelC.ctrs = {'limitAin'};
modelC.ctrNames = {'limit on Ain'};

assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {rmfield(modelC, 'd')}, ...
                                'testMessage', 'For the constraints C*v <= d, both must be present'));
badModel = modelC;
badModel.C = sparse(1, nRxnsToy + 1);
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, ...
                                'testMessage', 'For the constraints C*v <= d the number of columns of S and C are inconsisent'));
badModel = modelC;
badModel.d = [100; 100];
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, ...
                                'testMessage', 'For the constraints C*v <= d, the number of rows of C and d are inconsisent'));
badModel = modelC;
badModel.d = [100, 100];
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, ...
                                'testMessage', 'For the constraints C*v <= d, d must have only one column'));
badModel = modelC;
badModel.csense = 'EE';
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, 'testMessage', 'Length of csense is invalid!'));
badModel = modelC;
badModel.dsense = 'LL';
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, ...
                                'testMessage', 'Length of dsense is invalid! Defaulting to equality constraints.'));

% without C a csense of the wrong length is refused as well
badModel = toyModel;
badModel.csense = 'EE';
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, ...
                                'testMessage', 'The length of csense does not match the number of rows of model.S.'));

%% coupling constraints: csense and dsense are completed

% a row vector csense for the metabolites only; the names of the constraints are joined to metNames
modelSense = modelC;
modelSense.csense = columnVector(toyModel.csense)';
[relaxation, relaxedModel] = relaxedFBA(modelSense);
assert(relaxation.stat == 1 && numel(relaxation.rCtrs) == 1);
assert(isFeasible(relaxedModel));

% one csense for metabolites and constraints: the last part becomes dsense
modelSense = rmfield(modelC, 'dsense');
modelSense.csense = [columnVector(toyModel.csense); 'L'];
[relaxation, relaxedModel] = relaxedFBA(modelSense);
assert(relaxation.stat == 1);
assert(isequal(relaxedModel.dsense, 'L') && numel(relaxedModel.csense) == nMetsToy);

% neither csense nor dsense: equalities and <=, which is printed at a high print level; the
% parameters are also printed
modelSense = rmfield(modelC, {'csense', 'dsense'});
printed = evalc('[relaxation, relaxedModel] = relaxedFBA(modelSense, struct(''printLevel'', 2));');
assert(contains(printed, 'No defined csense.') && contains(printed, 'No defined dsense.'));
assert(contains(printed, 'relaxedPrintLevel'));
assert(relaxation.stat == 1);
assert(all(relaxedModel.csense == 'E') && isequal(relaxedModel.dsense, 'L'));

% no coupling constraints and no csense
printed = evalc('relaxation = relaxedFBA(rmfield(toyModel, ''csense''), struct(''printLevel'', 2));');
assert(contains(printed, 'We assume that all mass balance constraints are equalities'));
assert(relaxation.stat == 1);

%% extra variables and constraints: the fields that are absent get their default

% only E: one extra variable that takes part in the balance of the first metabolite. Its bounds,
% objective coefficient and name are the defaults
modelE = toyModel;
modelE.E = sparse(1, 1, 1, nMetsToy, 1);
[relaxation, relaxedModel] = relaxedFBA(modelE);
assert(relaxation.stat == 1);
assert(numel(relaxation.vEvar) == 1 && numel(relaxation.pEvar) == 1 && numel(relaxation.qEvar) == 1);
assert(~isfield(relaxation, 'rCtrs'));
assert(strcmp(relaxedModel.evars{1}, 'evar_1') && relaxedModel.evarc == 0);
assert(isFeasible(relaxedModel));

% E and C without D: D is filled with zeros, with a warning
modelEC = modelC;
modelEC.E = modelE.E;
lastwarn('');
[relaxation, relaxedModel] = relaxedFBA(modelEC);
assert(contains(lastwarn, 'model.D will be filled with 0s'));
assert(relaxation.stat == 1);
assert(isequal(size(relaxedModel.D), [1, 1]) && nnz(relaxedModel.D) == 0);

% E and D without C: C is filled with zeros and d, dsense and ctrs get their default
modelED = modelE;
modelED.D = sparse(1, 1, 1, 1, 1);
lastwarn('');
[relaxation, relaxedModel] = relaxedFBA(modelED);
assert(contains(lastwarn, 'model.C will be filled with 0s'));
assert(relaxation.stat == 1);
assert(nnz(relaxedModel.C) == 0 && isequal(size(relaxedModel.C), [1, nRxnsToy]));
assert(relaxedModel.d == 0 && isequal(relaxedModel.dsense, 'L') && strcmp(relaxedModel.ctrs{1}, 'ctrs_1'));

% C and D without E: E is filled with zeros
modelCD = modelC;
modelCD.D = sparse(1, 1, 1, 1, 1);
lastwarn('');
[relaxation, relaxedModel] = relaxedFBA(modelCD);
assert(contains(lastwarn, 'model.E will be filled with 0s'));
assert(relaxation.stat == 1);
assert(nnz(relaxedModel.E) == 0 && isequal(size(relaxedModel.E), [nMetsToy, 1]));

%% bounds that cannot be relaxed are refused

badModel = toyModel;
badModel.lb(1) = Inf;
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, 'testMessage', 'Infinite lower bounds causing infeasibility.'));
badModel = toyModel;
badModel.ub(1) = -Inf;
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, 'testMessage', 'Negative infinite upper bounds causing infeasibility.'));

%% non-finite entries of the problem are refused

badModel = toyModel;
badModel.b(1) = Inf;
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, 'testMessage', 'model.b has non-finite entries'));
badModel = toyModel;
badModel.c(1) = Inf;
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {badModel}, 'testMessage', 'model.c has non-finite entries'));

%% relaxation of the extra variables of the GECKO model

geckoInfeasible = geckoToyMd;
geckoInfeasible.lb = [0.6; 0.6];

% by default the extra variable bounds are relaxed
relaxation = relaxedFBA(geckoInfeasible, struct('excludedReactions', true(numel(geckoInfeasible.rxns), 1), ...
                                                'steadyStateRelax', 0, 'extraConstraintRelax', 0));
assert(relaxation.stat == 1 && nnz(relaxation.qEvar) ~= 0);

% extraVarRelax = 0 and 1 keep the bounds of the extra variables, here all finite, so the
% relaxation goes elsewhere
for extraVarRelax = [0, 1]
    [relaxation, relaxedModel] = relaxedFBA(geckoInfeasible, struct('extraVarRelax', extraVarRelax));
    assert(relaxation.stat == 1);
    assert(nnz(relaxation.pEvar) == 0 && nnz(relaxation.qEvar) == 0);
    assert(isFeasible(relaxedModel));
end

%% a feasible model with extra variables and constraints needs no relaxation

[relaxation, relaxedModel] = relaxedFBA(geckoToyMd);
assert(relaxation.stat == 1);
assert(nnz(relaxation.r) == 0 && nnz(relaxation.p) == 0 && nnz(relaxation.q) == 0);
assert(nnz(relaxation.pEvar) == 0 && nnz(relaxation.qEvar) == 0 && nnz(relaxation.rCtrs) == 0);
assert(numel(relaxation.vEvar) == numel(geckoToyMd.evars) && all(isnan(relaxation.vEvar)));
assert(isequal(relaxedModel.evarub, geckoToyMd.evarub));

%% the relaxations are reported at relaxedPrintLevel 1

% a lower bound of an internal reaction
printed = evalc('relaxedFBA(toyModel, struct(''relaxedPrintLevel'', 1));');
assert(contains(printed, 'Relaxed model is feasible.'));
assert(contains(printed, '1 lower bound relaxation(s)'));
assert(contains(printed, 'The lower bound of these reactions had to be relaxed:'));
assert(contains(printed, '... done.'));

% an upper bound of an exchange reaction
printed = evalc('relaxedFBA(toyModel, struct(''relaxedPrintLevel'', 1, ''internalRelax'', 0, ''steadyStateRelax'', 0));');
assert(contains(printed, '1 upper bound relaxation(s)'));
assert(contains(printed, 'The upper bound of these reactions had to be relaxed:'));

% a steady state constraint
printed = evalc('relaxedFBA(toyModel, struct(''relaxedPrintLevel'', 1, ''internalRelax'', 0, ''exchangeRelax'', 0));');
assert(contains(printed, '1 steady state relaxation(s)'));
assert(contains(printed, 'The  steady state constraints on these metabolites had to be relaxed:'));

%% a relaxed model without an optimal solution is an error

% the objective is unbounded: within relaxedFBA the infinite bounds are finite, in the relaxed model
% they are infinite again
unboundedModel = addReaction(toyModel, 'Xin', 'reactionFormula', ' -> X[c]', 'lowerBound', 0, 'upperBound', Inf);
unboundedModel = addReaction(unboundedModel, 'Xout', 'reactionFormula', 'X[c] -> ', 'lowerBound', 0, 'upperBound', Inf);
unboundedModel = changeObjective(unboundedModel, 'Xout');
assert(verifyCobraFunctionError('relaxedFBA', 'inputs', {unboundedModel}, ...
                                'testMessage', 'Relaxed model may not admit a steady state. relaxedFBA failed'));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
