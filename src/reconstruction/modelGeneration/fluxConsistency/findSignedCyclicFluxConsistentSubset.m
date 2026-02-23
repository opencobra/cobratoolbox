function [signedCyclicFluxConsistentMetBool, signedCyclicFluxConsistentRxnBool, modelOut, fluxConsistModel] = findSignedCyclicFluxConsistentSubset(model, param)
% Find the subset of reactions that is signed, cyclically flux consistent
% Reaction j is said to be signed, cyclically flux consistent if 
%  (1) there exists a v, such that N*v = 0
% and either (2.1) or (2.2) hold, where
%  (2.1) v(j) >= param.epsilon
%  (2.2) v(j) <= -param.epsilon
% and either (3.1) or (3.2) hold, where
%  (3.1) v(k) >= 0, for all k \in 1..n, except k = j
%  (3.2) v(k) <= 0, for all k \in 1..n, except k = j
% where N is an (internal) stoichiometric matrix
% 
% USAGE:
%
%    [signedCyclicFluxConsistentMetBool, signedCyclicFluxConsistentRxnBool, model, fluxConsistModel] = findSignedCyclicFluxConsistentSubset(model, param)
%
% INPUTS:
%    model:                      structure with field:
%
%                                  * .S - `m` x `n` stoichiometric matrix
%
% OPTIONAL INPUTS:
%    param:                      can contain:
%                                  * param.LPsolver - the LP solver to be used
%                                  * param.epsilon -  minimum nonzero flux, default feasTol*10
%                                                     Note that fastcc is very sensitive to the value of parm.epsilon
%                                  * param.modeFlag - {(0),1} 1 = return flux modes
%                                  * printLevel - verbose level
%
%
% OUTPUTS:
%    signedCyclicFluxConsistentMetBool:      `m` x 1 boolean vector indicating flux consistent `mets`
%    signedCyclicFluxConsistentRxnBool:      `n` x 1 boolean vector indicating flux consistent `rxns`
%
%    model:                      structure with fields duplicating the single output arguments:
%                                  * .signedCyclicFluxConsistentMetBool
%                                  * .signedCyclicFluxConsistentRxnBool
%
% .. Authors:
%       - Ronan Fleming, 2026

if ~exist('param','var') || isempty(param)
    param = struct();
end
if ~isfield(param,'epsilon')
    param.internal =1; %internal (stoichiometrically) consistent reactions only
end
if ~isfield(param,'nullspaceBasis')
    param.nullspaceBasis =1; %compute nullspace
end
if ~isfield(param,'method')
    param.method ='2LP'; 
end
if ~isfield(param,'testModelFeasibility')
    param.testModelFeasibility =0; 
end
if ~isfield(param,'testModelFeasibility')
    param.testModelFeasibility =0; 
end


if ~isfield(param,'epsilon')
    feasTol = getCobraSolverParams('LP', 'feasTol');
    epsilon=feasTol*10;
else
    epsilon=param.epsilon;
end

if ~exist('printLevel','var')
    if ~isfield(param,'printLevel')
        param.printLevel=0;
    end
end
if param.printLevel>0
    fprintf('%s\n','--- findFluxConsistentSubset START ----')
end

modelOrig = model;

[nMet,nRxn]=size(model.S);

if param.internal
    model.S(:,~model.SConsistentRxnBool)=0;
    skipReactionBool = ~model.SConsistentRxnBool;
else
    skipReactionBool = false(nRxn,1);
end

%only some methods support additional constraints
if isfield(model,'C') || isfield(model,'E')
    if ~any(ismember({'fastcc'},param.method))
        error('model contains additional constraints, switch to: param.method = ''fastcc''')
    end
end

if ~isfield(model,'c')
    model.c = zeros(size(model.S,2),1);
end

if param.testModelFeasibility
    sol = optimizeCbModel(model);
    firstStat = sol.stat;
else
    %assume it is feasible
    firstStat=1;
end


%                          * stat - Solver status in standardized form:
%                               * 0 - Infeasible problem
%                               * 1 - Optimal solution
%                               * 2 - Unbounded solution
%                               * 3 - Almost optimal solution
%                               * -1 - Some other problem (timelimit, numerical problem etc)
switch firstStat
    case 0
        disp(sol.stat)
        error('input model is infeasible')

    case {1,3}
        if firstStat==3
            warning('Numerical difficulties')
        end
        if ~isfield(model,'b')
            model.b=zeros(size(model.S,1),1);
        end
        
        %identify reactions that have no support in
        if param.nullspaceBasis
            %the right nullspace of S, if b = 0
            %Find the reactions that are flux inconsistent (upto orientation, without bounds)
            %compute the nullspace of the stoichiometric matrix and identify the
            %reactions without support in the nullspace basis
            [Z,rankS]=getNullSpace(model.S,0);
            nullFluxInConsistentRxnBool=~any(Z,2);
            if param.printLevel>0
                if any(nullFluxInConsistentRxnBool)
                    disp([int2str(nnz(nullFluxInConsistentRxnBool)) ' of ' int2str(length(nullFluxInConsistentRxnBool))  ' reactions with no support in nullspace'])
                end
            end
            skipReactionBool = skipReactionBool | nullFluxInConsistentRxnBool;
        end
        
        signedCyclicFluxConsistentRxnBool=false(size(model.S,2),1);
        
        switch param.method
            case '2LP'
                model.c(:)=0;
                model.osenseStr='min';
                if isfield(model,'F')
                    model = rmfield(model,'F');
                end
                LPproblem = buildOptProblemFromModel(model, 0);
                lb = LPproblem.lb;
                ub = LPproblem.ub;
                for j = 1:nRxn

                    %skip if no support in nullspace basis or if elected to
                    %skip internal reactions, or if already known to be
                    %consistent
                    if ~skipReactionBool(j) || signedCyclicFluxConsistentRxnBool(j)

                        %forward
                        LPproblem.lb(1:nRxn) = 0;
                        LPproblem.lb(j)=1;
                        sol = solveCobraLP(LPproblem);
                        switch sol.stat
                            case {0,2,3,-1}
                                %reverse
                                LPproblem.lb = lb;
                                LPproblem.ub(1:nRxn) = 0;
                                LPproblem.ub(j) = -1;
                                sol = solveCobraLP(LPproblem);
                                switch sol.stat
                                    case 0
                                    case 1
                                        signedCyclicFluxConsistentRxnBool = signedCyclicFluxConsistentRxnBool | sol.full(1:nRxn) <= -epsilon;
                                    case 2
                                        error(['unbounded in findSignedCyclicFluxConsistentSubset'])
                                    case 3
                                        error('almost optimal solution in findSignedCyclicFluxConsistentSubset')
                                    case -1
                                        error([sol.origStat])
                                end
                                LPproblem.ub=ub;
                            case 1
                                signedCyclicFluxConsistentRxnBool = signedCyclicFluxConsistentRxnBool | sol.full(1:nRxn) >= epsilon;
                        end
                        LPproblem.lb=lb;

                        if param.printLevel>0 && mod(j,10)==10
                            % fprintf('%u%g%s\n',nnz(signedCyclicFluxConsistentRxnBool),...
                            %     (nnz(signedCyclicFluxConsistentRxnBool)/length(signedCyclicFluxConsistentRxnBool)),'nnz')
                            fprintf('%8u %6.0f%% %s\n', ...
                                nnz(signedCyclicFluxConsistentRxnBool), ...
                                100 * nnz(signedCyclicFluxConsistentRxnBool) / length(signedCyclicFluxConsistentRxnBool), ...
                                'nnz');

                        end
                    end

                end
        end


    case 2
        disp(firstStat)
        error('input model is unbounded')
    otherwise
        disp(firstStat)
        error(['input model could not be solved: sol.origStat:' sol.origStat])
end

%metabolites inclusively involved in flux consistent reactions are deemed flux consistent also
signedCyclicFluxConsistentMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),signedCyclicFluxConsistentRxnBool,'inclusive');

if any(~signedCyclicFluxConsistentRxnBool)
    if param.printLevel>0
        fprintf('%u%s\n',nnz(signedCyclicFluxConsistentMetBool),' signed, cyclically flux consistent metabolites')
        fprintf('%u%s\n',nnz(~signedCyclicFluxConsistentMetBool),' signed, cyclically flux inconsistent metabolites')
        fprintf('%u%s\n',nnz(signedCyclicFluxConsistentRxnBool),' signed, cyclically flux consistent reactions')
        fprintf('%u%s\n',nnz(~signedCyclicFluxConsistentRxnBool),' signed, cyclically flux inconsistent reactions')
    end
else
    if param.printLevel>0
        fprintf('%u%s\n',nnz(signedCyclicFluxConsistentMetBool),' all metabolites signed, cyclically flux consistent.')
        fprintf('%u%s\n',nnz(signedCyclicFluxConsistentRxnBool),' all reactions signed, cyclically flux consistent.')
    end
end

modelOrig.signedCyclicFluxConsistentMetBool=signedCyclicFluxConsistentMetBool;
modelOrig.signedCyclicFluxConsistentRxnBool=signedCyclicFluxConsistentRxnBool;

%Extract flux consistent submodel
if 0 && any(~model.signedCyclicFluxConsistentRxnBool)
    %removes reactions and maintains stoichiometric consistency
    [fluxConsistModel, ~] = removeRxns(modelOrig, modelOrig.rxns(~signedCyclicFluxConsistentRxnBool),'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
    try
        fluxConsistModel = removeUnusedGenes(fluxConsistModel);
    catch ME
        disp(ME.message)
    end
else
    fluxConsistModel = modelOrig;
end

modelOut = modelOrig;

if param.printLevel>0
    fprintf('%s\n','--- findSignedCyclicFluxConsistentSubset END ----')
end
