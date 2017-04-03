function [vSparse,sparseRxnBool,essentialRxnBool]  = sparseFBA(model,osenseStr,checkMinimalSet,checkEssentialSet,zeroNormApprox,printLevel)
% Find the minimal set of reactions subject to a LP objective
% function [v]  = sparseFBA(model,osenseStr,checkMinimalSet,printLevel)
% min ||v||_0
% s.t   Sv <=> b
%       c'v = f* (optimal value of objective, default is max c'v)
%       l <= v <= u
%INPUT
% model                 (the following fields are required - others can be supplied)
%   S                   Stoichiometric matrix
%   b                   Right hand side = dx/dt
%   c                   Objective coefficients
%   lb                  Lower bounds
%   ub                  Upper bounds
%
%OPTIONAL INPUTS
% osenseStr             (default = 'max')
%   max                 f* = argmax {max c'v: Sv <=> b, l <= v <= u}
%   min                 f* = argmin {min c'v: Sv <=> b, l <= v <= u}
%   none                ignore the constraint c'v = f*
%
% checkMinimalSet       Heuristically check if the selected set of reactions is minimal
%                       by removing one by one the predicted active reaction
%                       true    check (default value)
%                       false   do not check
%
% zeroNormApprox    appoximation type of zero-norm (only available when minNorm='zero') (default = 'cappedL1')
%                           'cappedL1' : Capped-L1 norm
%                           'exp'      : Exponential function
%                           'log'      : Logarithmic function
%                           'SCAD'     : SCAD function
%                           'lp-'      : L_p norm with p<0
%                           'lp+'      : L_p norm with 0<p<1
%                           'l1'       : L1 norm
%                           'all'      : try all approximations and return the best result
% printLevel            Printing level
%                       0    Silent (Default)
%                       1    Summary information
%
%OUTPUT
%  v                    reaction rate vector

% Hoai Minh Le	23/10/2015
% Ronan Fleming 12/07/2016 nonzero flux is set according to current 
%                          feasibility tol. Default is 1e-9.


%% Check inputs

if exist('osenseStr', 'var')
    if isempty(osenseStr)
        osenseStr = 'max';
    end
else
    if isfield(model,'osenseStr')
        osenseStr = model.osenseStr;
    else
        osenseStr = 'max';
    end
end

if ~exist('checkMinimalSet', 'var')
    checkMinimalSet = true;
end

if ~exist('checkEssentialSet', 'var')
    checkEssentialSet = true;
end

if exist('zeroNormApprox', 'var')
    availableApprox = {'cappedL1','exp','log','SCAD','lp-','lp+','l1','all'};
    if ~ismember(zeroNormApprox,availableApprox)
        warning('Approximation is not valid. Default value will be used');
        zeroNormApprox = 'cappedL1';
    end
else
    zeroNormApprox = 'cappedL1';
end

%use global solver parameter for printLevel
if ~exist('printLevel', 'var')
    printLevel = 1;
end

%%%%%%%%%
feasTol = getCobraSolverParams('LP', 'feasTol');
optTol = getCobraSolverParams('LP', 'optTol');

% tolerance for non-zero flux
    epsilon = feasTol;
    %use the default feasTol
    params.feasTol=feasTol;
    params.optTol=optTol;
    %default feasibility and optimality tolerance is 1e-9, which is anyway lower than epislon
    CobraParams = struct('feasTol',params.feasTol,'optTol',params.optTol);
    
[m,n] = size(model.S);

if ~isfield(model,'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    if printLevel>1
        fprintf('%s\n','LP problem has no defined csense. We assume that all constraints are equalities.')
    end
    csense(1:m,1) = 'E';
else % if csense is in the model, move it to the lp problem structure
    if length(model.csense)~=m,
        warning('Length of csense is invalid! Defaulting to equality constraints.')
        csense(1:m,1) = 'E';
    else
        model.csense = columnVector(model.csense);
        csense = model.csense;
    end
end

% Fill in the RHS vector if not provided
if ~isfield(model,'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    b=zeros(m,1);
else
    b = model.b;
end

if ~isfield(model,'csense')
    % If csense is not declared in the model, assume that all constraints are equalities.
    fprintf('%s\n','csense is not defined. We assume that all constraints are equalities.')
    csense(1:m,1) = 'E';
else
    if length(model.csense)~=m,
        warning('Length of csense is invalid! Defaulting to equality constraints.')
        csense(1:m,1) = 'E';
    else
        model.csense = columnVector(model.csense);
        csense = model.csense;
    end
end

[c,S,b,lb,ub] = deal(model.c,model.S,model.b,model.lb,model.ub);


%% Compute f* = max c'v or f* = min c'v
if strcmpi(osenseStr,'max')
    osense = -1;
elseif strcmpi(osenseStr,'min')
    osense = +1;
elseif strcmpi(osenseStr,'none')
    osense = +1;
    c = zeros(n,1);
end

if nnz(c)~=0
    time=cputime;
    LPproblem = struct('c',c,'osense',osense,'A',S,'csense',csense,'b',b,'lb',lb,'ub',ub);
    FBAsolution = solveCobraLP(LPproblem,CobraParams);
    time = cputime-time;
else
    time=0;
    FBAsolution.stat=1;
    FBAsolution.full=zeros(size(model.lb));
end

    %       stat                status
    %                           1 =  Solution found
    %                           2 =  Unbounded
    %                           0 =  Infeasible
    %                           -1=  Invalid input
switch FBAsolution.stat
    case 2
        v = [];
        error('%s\n','FBA problem unbounded !')
    case 0
        v = [];
        error('%s\n','FBA problem infeasible !')
    case -1
        v = [];
        error('%s\n','FBA problem error: Invalid input !')
    case 1
        vFBA = FBAsolution.full(1:n);
        objFBA = c'*vFBA;
        
        if nnz(c)~=0 & printLevel >= 0
            display('---FBA')
            display(strcat('Obj = ',num2str(objFBA)));
            display(strcat('|vFBA|_0 = ',num2str(nnz(abs(vFBA)>=epsilon))));
            display(strcat('Comp. time = ',num2str(time)));
        end
        
        % Minimise the number of reactions by keeping same max objective found previously
        % One adds the constraint : c'v = c'vFBA
        if nnz(c)~=0
            constraint.A = [S ; c'];
            constraint.b = [b ; objFBA];
            constraint.csense = [csense;'E'];
        else
            constraint.A = S;
            constraint.b = b;
            constraint.csense = csense;
        end
        
        constraint.lb = lb;
        constraint.ub = ub;
        
        %% Minimise l_0 norm
        time = cputime;
        params.epsilon=epsilon;
        solutionL0 = sparseLP(zeroNormApprox,constraint,params);
        
        if printLevel>2
            fprintf('%10g%s%g%s\n',norm(constraint.A*solutionL0.x-constraint.b),' ||S*v-b||_0, should be less than tolerance (',epsilon,').')
            fprintf('%10g%s\n',min(constraint.ub-solutionL0.x),'  min(ub-v), should be non-negative.')
            fprintf('%10g%s\n',min(solutionL0.x-constraint.lb),'  min(v-lb), should be non-negative.')
        end
        time = cputime - time;
       
        %save the solution
        vApprox=solutionL0.x;
        %identify active reactions
        activeRxnBool = abs(vApprox)>=epsilon;
       
        %Check if one can still achieve the same objective only with predicted active reactions
        %remove all predicted non-active reactions
        tightLPproblem = struct('c',c(activeRxnBool),'osense',osense,'A',S(:,activeRxnBool),'csense',csense,'b',b,'lb',model.lb(activeRxnBool),'ub',model.ub(activeRxnBool));
        
        %solve the tighter problem
        tightSolution = solveCobraLP(tightLPproblem,CobraParams);
        
        if tightSolution.stat == 1 && abs(tightSolution.obj - objFBA)<epsilon
            %it could be that this solution is more sparse
            if nnz(activeRxnBool)> nnz(abs(tightSolution.full)>=epsilon)
                if 1       
                    %identify active reactions
                    activeRxnBoolOld=activeRxnBool;
                    %update sparse solution and active reactions
                    vApprox=sparse(n,1);
                    vApprox(activeRxnBool)=tightSolution.full;
                    activeRxnBool = abs(vApprox)>=epsilon;
                end
            end
            if printLevel>1
                fprintf('%s\n','Testing of DC approximation results in a sparser solution')
                disp(solutionL0.x(activeRxnBoolOld & ~activeRxnBool))
            end
        else
            error('Cannot achieve the objective value. Tolerance for non-zero flux is probably too large!')
        end
end
%identify active reactions
activeRxnBool = abs(vApprox)>=epsilon;

%number of reactions in sparse solution
nSparse=nnz(activeRxnBool);
    
%% check which reactions are essential
essentialRxnBool = false(n,1);
if checkEssentialSet == true
    %assume all active reactions are in the minimal set unless tested
    essentialTightRxnsBool = true(nSparse,1);
    
    if ~isempty(activeRxnBool) && printLevel > 1
        disp(['sparseFBA solution: zero norm before heuristic rxn removal = ', num2str(nnz(activeRxnBool))])
    end
    
    %Remove one of the predicted active reaction and verify if 
    %the optimal objective value can be achieved
    for i=1:nSparse
        %try to remove a reaction entirely from model
        essentialTightRxnsBoolTemp = true(nSparse,1);
        essentialTightRxnsBoolTemp(i)=0;
        tighterLPproblem = struct('c',tightLPproblem.c(essentialTightRxnsBoolTemp),'osense',osense,'A',tightLPproblem.A(:,essentialTightRxnsBoolTemp),'csense',csense,'b',b,'lb',tightLPproblem.lb(essentialTightRxnsBoolTemp),'ub',tightLPproblem.ub(essentialTightRxnsBoolTemp));        
        %see if a solution exists
        LPsolution = solveCobraLP(tighterLPproblem,CobraParams);
        if LPsolution.stat == 1 && abs(LPsolution.obj - objFBA)< optTol %&& any(abs(LPsolution.full)>=epsilon)
            essentialTightRxnsBool(i) = false;
        end
    end
    %pad out
    essentialRxnBool(activeRxnBool)=essentialTightRxnsBool;
else
    essentialRxnBool=[];
end


%% Check if the selected set of reactions is minimal
if checkMinimalSet == true
    % vHeuristic = sparse(n,1);
    vHeuristic = vApprox;
    %first assume all active reactions are in the minimal set
    minimalTightRxnBool = true(nSparse,1);
    
    if ~isempty(activeRxnBool) && printLevel > 1
        disp(['sparseFBA solution: zero norm before heuristic rxn removal = ', num2str(nnz(activeRxnBool))])
    end
    
    %Remove one by one the predicted active reaction and verify if
    %the optimal objective value can be achieved
    tighterRxnsBool=true(nSparse,1);
    for i=1:nSparse
        %no need to test a reaction if it is known to be essential
        if  1 && checkEssentialSet && ~essentialTightRxnsBool(i)
            %try to remove reaction entirely from model
            tighterRxnsBool(i)=0;
            tighterLPproblem = struct('c',tightLPproblem.c(tighterRxnsBool),'osense',osense,'A',tightLPproblem.A(:,tighterRxnsBool),'csense',csense,'b',b,'lb',tightLPproblem.lb(tighterRxnsBool),'ub',tightLPproblem.ub(tighterRxnsBool));
            %see if a solution exists
            LPsolution = solveCobraLP(tighterLPproblem,CobraParams);
            if LPsolution.stat == 1 && abs(LPsolution.obj - objFBA)< optTol %&& any(abs(LPsolution.full)>=epsilon)
                minimalTightRxnBool(i) = false;
                tmp = zeros(size(tighterRxnsBool)); % not sparse
                tmp(tighterRxnsBool) = LPsolution.full;
                vHeuristic(:) = 0; %replace
                vHeuristic(activeRxnBool)=tmp;
            else
                %replace reaction
                tighterRxnsBool(i)=1;
            end
        end
    end
    %pad out
    minimalRxnBool = false(n,1);
    minimalRxnBool(activeRxnBool)=minimalTightRxnBool;
    %solution for output
    vSparse=vHeuristic;
else
    vSparse=vApprox;
end
sparseRxnBool=abs(vSparse)>=epsilon;


%% Display result
if printLevel > 0
    fprintf('%s\n','---Non-convex approximation---')
    if any(c)
        fprintf('%g%s\n',c'*solutionL0.x,' = sparse LP objective.');
        display(strcat('Error ||c^T*v - f*||^2=',num2str(norm(c'*solutionL0.x - objFBA,2))));
    end
%    fprintf('%u%s%s%s\n',nnz(activeRxnBool),' rxns in sparsest solution found using a ', solutionL0.bestAprox, ' approximation.');
    if  checkMinimalSet
        fprintf('%u%s\n',nnz(minimalRxnBool),' of these are heuristically minimal rxns.');
    end
    if  checkEssentialSet
        fprintf('%u%s\n',nnz(essentialRxnBool),' of these are essential rxns.');
    end
    if printLevel > 1
        display(strcat('Comp. time = ',num2str(time)));
    end
else
    if printLevel > 1
        fprintf('%u%s\n',nnz(sparseRxnBool),' rxns in sparsest solution.');
        if  checkEssentialSet
            fprintf('%u%s\n',nnz(essentialRxnBool),' of these are essential rxns.');
        end
    end
end