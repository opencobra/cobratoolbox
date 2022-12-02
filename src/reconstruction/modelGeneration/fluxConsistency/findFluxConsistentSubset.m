function [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model, fluxConsistModel] = findFluxConsistentSubset(model, param, printLevel)
% Finds the subset of `S` that is flux consistent using various algorithms,
% but `fastcc` from `fastcore` by default
%
% USAGE:
%
%    [fluxConsistentMetBool, fluxConsistentRxnBool, fluxInConsistentMetBool, fluxInConsistentRxnBool, model] = findFluxConsistentSubset(model, param, printLevel)
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
%                                  * param.method - {'swiftcc', ('fastcc'), 'dc','fastB'}
%                                  * param.reduce - {(0),1} 1 = return fluxConsistModel
%
%    printLevel:                 verbose level
%
%    model.rev - the 0-1 vector with 1's corresponding to the reversible reactions (if using swiftcc)
%
%
% OUTPUTS:
%    fluxConsistentMetBool:      `m` x 1 boolean vector indicating flux consistent `mets`
%    fluxConsistentRxnBool:      `n` x 1 boolean vector indicating flux consistent `rxns`
%    fluxInConsistentMetBool:    `m` x 1 boolean vector indicating flux inconsistent `mets`
%    fluxInConsistentRxnBool:    `n` x 1 boolean vector indicating flux inconsistent `rxns`
%    model:                      structure with fields duplicating the single output arguments:
%
%                                  * .fluxConsistentMetBool
%                                  * .fluxConsistentRxnBool
%                                  * .fluxInConsistentMetBool
%                                  * .fluxInConsistentRxnBool
%
% .. Authors:
%       - Ronan Fleming, 2017
%       - Mojtaba Tefagh, March 2019 - integration of swiftcc
%       - Ines Thiele, Dec 2022 - integration of fastB 

% .. Author: - Ronan Fleming 2022
% .. Please cite:
% Fleming RMT, Haraldsdottir HS, Le HM, Vuong PT, Hankemeier T, Thiele I.
% Cardinality optimisation in constraint-based modelling: Application to human metabolism, 2022 (submitted).

if ~exist('param','var') || isempty(param)
    param = struct();
end
if ~isfield(param,'epsilon')
    feasTol = getCobraSolverParams('LP', 'feasTol');
    epsilon=feasTol*10;%warning, if method fastcc, it is very sensitive to the value of epsilon
else
    epsilon=param.epsilon;
end
if ~isfield(param,'modeFlag')
    modeFlag=0;
else
    modeFlag=param.modeFlag;
end
if ~isfield(param,'method')
    param.method='fastcc';
end
if ~exist('printLevel','var')
    if ~isfield(param,'printLevel')
        printLevel=0;
    else
        printLevel=param.printLevel;
    end
end
if printLevel>0
    fprintf('%s\n','--- findFluxConsistentSubset START ----')
end

[nMet,nRxn]=size(model.S);

%only some methods support additional constraints
if isfield(model,'C') || isfield(model,'E')
    if ~any(ismember({'fastcc'},param.method))
        error('model contains additional constraints, switch to: param.method = ''fastcc''')
    end
end

if ~isfield(model,'c')
    model.c = zeros(size(model.S,2),1);
end
sol = optimizeCbModel(model);

switch sol.stat
    case {1,3}
        if sol.stat==3
            warning('Numerical difficulties')
        end
        if ~isfield(model,'b')
            model.b=zeros(size(model.S,1),1);
        end
        
        %speeds up fast cc if one can remove the reactions that have no support in
        %the right nullspace of S
        if strcmp(param.method,'null_fastcc')
            
            
            %Find the reactions that are flux inconsistent (upto orientation, without bounds)
            %compute the nullspace of the stoichiometric matrix and identify the
            %reactions without support in the nullspace basis
            [Z,rankS]=getNullSpace(model.S,0);
            nullFluxInConsistentRxnBool=~any(Z,2);
            
            if any(nullFluxInConsistentRxnBool)
                modelOrig=model;
                nullFluxInConsistentMetBool = getCorrespondingRows(model.S,true(nMet,1),nullFluxInConsistentRxnBool,'exclusive');
                model.S=model.S(~nullFluxInConsistentMetBool,~nullFluxInConsistentRxnBool);
                model.mets=model.mets(~nullFluxInConsistentMetBool);
                
                model.b=model.b(~nullFluxInConsistentMetBool);
                if isfield(model,'csense')
                    model.csense=model.csense(~nullFluxInConsistentMetBool);
                end
                model.c=model.c(~nullFluxInConsistentRxnBool);
                model.lb=model.lb(~nullFluxInConsistentRxnBool);
                model.ub=model.ub(~nullFluxInConsistentRxnBool);
                model.rxns=model.rxns(~nullFluxInConsistentRxnBool);
            end
        end
        
        fluxConsistentRxnBoolTemp=false(size(model.S,2),1);
        
        switch param.method
            case 'swiftcc'
                if ~isfield(param,'LPsolver')
                    solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi'});
                    param.LPsolver = solvers.LP{1};
                end
                if ~isfield(model,'rev')
                    model.rev = model.lb<0 & model.ub>0;
                end
                indFluxConsist = swiftcc(model.S, model.rev, param.LPsolver);
                fluxConsistentRxnBoolTemp(indFluxConsist) = 1;
            case {'fastcc','null_fastcc'}
                %fast consistency check code from Nikos Vlassis et al
                % INPUT
                % model         cobra model structure containing the fields
                %   S           m x n stoichiometric matrix
                %   lb          n x 1 flux lower bound
                %   ub          n x 1 flux uppper bound
                %   rxns        n x 1 cell array of reaction abbreviations
                %
                % epsilon
                % printLevel    0 = silent, 1 = summary, 2 = debug
                [indFluxConsist,~,V0]=fastcc(model,epsilon,printLevel-1,modeFlag,'original');
                fluxConsistentRxnBoolTemp(indFluxConsist)=1;
            case 'nonconvex'
                [indFluxConsist,V0] = fastcc(model,epsilon,printLevel-1,modeFlag,'nonconvex');
                fluxConsistentRxnBoolTemp(indFluxConsist)=1;
            case 'dc'
                % DC programming for solving the cardinality optimization problem
                % The l0 norm is approximated by capped-l1 function.
                % min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
                % s.t.      A*(x,y,z) <= b
                %           l <= (x,y,z) <=u
                %           x in R^p, y in R^q, z in R^r
                %
                % solution = optimizeCardinality(problem,params)
                %
                %  problem                  Structure containing the following fields describing the problem
                %       p                   size of vector x
                %       q                   size of vector y
                %       r                   size of vector z
                %       c                   (p+q+r) x 1 linear objective function vector
                %       lambda              trade-off parameter of ||x||_0
                %       delta               trade-off parameter of ||y||_0
                %       A                   s x (p+q+r) LHS matrix
                %       b                   s x 1 RHS vector
                %       csense              s x 1 Constraint senses, a string containting the constraint sense for
                %                           each row in A ('E', equality, 'G' greater than, 'L' less than).
                %       lb                  (p+q+r) x 1 Lower bound vector
                %       ub                  (p+q+r) x 1 Upper bound vector
                %
                % OPTIONAL INPUTS
                % params                    parameters structure
                %       nbMaxIteration      stopping criteria - number maximal of iteration (Defaut value = 1000)
                %       epsilon             stopping criteria - (Defaut value = 10e-6)
                %       theta               parameter of the approximation (Defaut value = 2)
                %
                % OUTPUT
                % solution                  Structure containing the following fields
                %       x                   p x 1 solution vector
                %       y                   q x 1 solution vector
                %       z                   r x 1 solution vector
                %       stat                status
                %                           1 =  Solution found
                %                           2 =  Unbounded
                %                           0 =  Infeasible
                %                           -1=  Invalid input
                
                %bound the fluxes finitely
                if ~isfinite(min(model.lb))
                    model.lb(model.lb<-1/epsilon)=-1/epsilon;
                end
                if ~isfinite(min(model.ub))
                    model.ub(model.ub>1/epsilon)=1/epsilon;
                end
                
                cardPrb.p       = 0; %size of vector x
                cardPrb.q       = size(model.S,2); %size of vector y
                cardPrb.r       = 0; %size of vector z
                cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
                cardPrb.lambda  = 0;
                cardPrb.delta   = 1;
                cardPrb.A       = model.S;
                cardPrb.b       = model.b;
                cardPrb.csense  = repmat('E',size(model.S,1), 1);
                cardPrb.lb      = model.lb;
                cardPrb.ub      = model.ub;
                
                %Call the cardinality optimisation solver
                solutionCard = optimizeCardinality(cardPrb);
                if solutionCard.stat == 1
                    stat   = 1;
                    v = solutionCard.y;
                    fluxConsistentRxnBoolTemp=abs(v)>=epsilon;
                else
                    fprintf('%s\n','Infeasibility while testing for flux consistency.');
                    stat   = 0;
                    v = [];
                end
            case 'fastB'
                % use fastBlockedRxns to identify flux consistent rxns
                printLevel = 0;
                [BlockedRxns] = identifyFastBlockedRxns(model,model.rxns,printLevel);
                fluxConsistentRxnBoolTemp = true(size(model.S,2),1);
                fluxConsistentRxnBoolTemp(ismember(model.rxns,BlockedRxns)) = false;
        end
    case 0
        disp(sol.stat)
        error('model is infeasible')
    case 2
        disp(sol.stat)
        error('model is unbounded')
    otherwise
        disp(sol.stat)
        error('model is infeasible/unbounded')
end


%pad out to the original model if it had been reduced
if strcmp(param.method,'null_fastcc') && any(nullFluxInConsistentRxnBool)
    model=modelOrig;
    fluxConsistentRxnBool=false(nRxn,1);
    fluxConsistentRxnBool(~nullFluxInConsistentRxnBool)=fluxConsistentRxnBoolTemp;
else
    fluxConsistentRxnBool=fluxConsistentRxnBoolTemp;
end

%metabolites inclusively involved in flux consistent reactions are deemed flux consistent also
fluxConsistentMetBool = getCorrespondingRows(model.S,true(size(model.S,1),1),fluxConsistentRxnBool,'inclusive');

if any(~fluxConsistentRxnBool)
    if printLevel>0
        fprintf('%u%s\n',nnz(fluxConsistentMetBool),' flux consistent metabolites')
        fprintf('%u%s\n',nnz(~fluxConsistentMetBool),' flux inconsistent metabolites')
        fprintf('%u%s\n',nnz(fluxConsistentRxnBool),' flux consistent reactions')
        fprintf('%u%s\n',nnz(~fluxConsistentRxnBool),' flux inconsistent reactions')
    end
else
    if printLevel>0
        fprintf('%u%s\n',nnz(fluxConsistentMetBool),' all metabolites flux consistent.')
        fprintf('%u%s\n',nnz(fluxConsistentRxnBool),' all reactions flux consistent.')
    end
end

fluxInConsistentMetBool=~fluxConsistentMetBool;
fluxInConsistentRxnBool=~fluxConsistentRxnBool;
model.fluxConsistentMetBool=fluxConsistentMetBool;
model.fluxConsistentRxnBool=fluxConsistentRxnBool;
model.fluxInConsistentMetBool=fluxInConsistentMetBool;
model.fluxInConsistentRxnBool=fluxInConsistentRxnBool;

%Extract flux consistent submodel
if any(~model.fluxConsistentRxnBool)
    %removes reactions and maintains stoichiometric consistency
    [fluxConsistModel, ~] = removeRxns(model, model.rxns(~fluxConsistentRxnBool),'metRemoveMethod','exclusive','ctrsRemoveMethod','inclusive');
    try
        fluxConsistModel = removeUnusedGenes(fluxConsistModel);
    catch ME
        disp(ME.message)
    end
else
    fluxConsistModel = model;
end

if printLevel>0
    fprintf('%s\n','--- findFluxConsistentSubset END ----')
end
