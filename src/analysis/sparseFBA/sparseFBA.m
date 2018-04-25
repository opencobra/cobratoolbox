function [vSparse, sparseRxnBool, essentialRxnBool]  = sparseFBA(model, osenseStr, checkMinimalSet, checkEssentialSet, zeroNormApprox, printLevel)
% Finds the minimal set of reactions subject to a LP objective
%
% .. math::
%      min ~&~ ||v||_0 \\
%      s.t ~&~ S v \leq, = or \geq b \\
%          ~&~ c^T v = f* \\
%          ~&~ l \leq v \leq u
%
% where :math:`f*` is the optimal value of objective (default is :math:`max c^T v`).
%
% USAGE:
%
%    [vSparse, sparseRxnBool, essentialRxnBool]  = sparseFBA(model, osenseStr, checkMinimalSet, checkEssentialSet, zeroNormApprox, printLevel)
%
% INPUT:
%    model:               (the following fields are required - others can be supplied):
%                           * S - Stoichiometric matrix
%                           * b - Right hand side = dx/dt
%                           * c - Objective coefficients
%                           * lb - Lower bounds
%                           * ub - Upper bounds
%
% OPTIONAL INPUTS:
%    model:               (optional for C*v<=d):
%                           * C - Stoichiometric matrix
%                           * d - Right hand side = dx/dt
%
%    osenseStr:           (default = 'max')
%
%                           * max: :math:`f* = argmax \{max\ c^T v: Sv \leq, = or \geq b, l \leq v \leq u\}`
%                           * min: :math:`f* = argmin \{min\ c^T v: Sv \leq, = or \geq b, l \leq v \leq u\}`
%                           * none: ignore the constraint :math:`c^T v = f*`
%
%    checkMinimalSet:     {0,(1)} Heuristically check if the selected set of reactions is minimal
%                         by removing one by one the predicted active reaction
%
%                           * true = check (default value)
%                           * false = do not check
%    checkEssentialSet:   {0,(1)} Heuristically check if the selected set of reactions is essential
%    zeroNormApprox:      appoximation type of zero-norm (only available when minNorm = 'zero') (default = 'cappedL1')
%
%                           * 'cappedL1' : Capped-L1 norm
%                           * 'exp'      : Exponential function
%                           * 'log'      : Logarithmic function
%                           * 'SCAD'     : SCAD function
%                           * 'lp-'      : :math:`L_p` norm with :math:`p < 0`
%                           * 'lp+'      : :math:`L_p` norm with :math:`0 < p < 1`
%                           * 'l1'       : L1 norm
%                           * 'all'      : try all approximations and return the best result
%    printLevel:          Printing level
%
%                           * 0 - Silent (Default)
%                           * 1 - Summary information
%
% OUTPUT:
%    vSparse:             Depends on the set of reactions
%    sparseRxnBool:       Returns a vector with 1 and 0's, where 1 means sparse
%    essentialRxnBool:    Returns a vector with 1 and 0's, where 1 means essential
%
% Authors: - Hoai Minh Le, Ronan Fleming


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

% size of the stoichiometric matrix
[nMets,nRxns] = size(model.S);

%make sure C is present if d is present
if ~isfield(model,'C') && isfield(model,'d')
    error('For the constraints C*v <= d, both must be present')
end

if isfield(model,'C')
    [nIneq,nltC]=size(model.C);
    [nIneq2,nltd]=size(model.d);
    if nltC~=nRxns
        error('For the constraints C*v <= d the number of columns of S and C are inconsisent')
    end
    if nIneq~=nIneq2
        error('For the constraints C*v <= d, the number of rows of C and d are inconsisent')
    end
    if nltd~=1
        error('For the constraints C*v <= d, d must have only one column')
    end
else
    nIneq=0;
end

if ~isfield(model,'dxdt')
    if isfield(model,'b')
        %old style model
        if length(model.b)==nMets
            model.dxdt=model.b;
            %model=rmfield(model,'b'); %tempting to do this
        else
            if isfield(model,'C')
                %new style model, b must be rhs for [S;C]*v {=,<=,>=} [dxdt,d] == b
                if length(model.b)~=nMets+nIneq
                    error('model.b must equal the number of rows of [S;C]')
                end
            else
                error('model.b must equal the number of rows of S or [S;C]')
            end
        end
    end
%     if printLevel>1
%         fprintf('%s\n','dxdt not defined csense.')
%         fprintf('%s\n','We assume that S*v = dxdt = 0')
%     end
%     model.dxdt=sparse(nMets,1);
else
    if length(model.dxdt)~=size(model.S,1)
        error('Number of rows in model.dxdt and model.S must match')
    end
end

%check the csense and make sure it is consistent
if isfield(model,'C')
    if ~isfield(model,'csense')
        if printLevel>1
            fprintf('%s\n','No defined csense.')
            fprintf('%s\n','We assume that all mass balance constraints are equalities, i.e., S*v = 0')
            fprintf('%s\n','We assume that all constraints C & d constraints are C*v <= d')
        end
        model.csense(1:nMets,1) = 'E';
        model.csense(nMets+1:nMets+nIneq,1) = 'L';
    else
        if length(model.csense)~=nMets+nIneq
            error('Length of csense is invalid! Defaulting to equality constraints.')
        else
            model.csense = columnVector(model.csense);
        end
    end
else
    if ~isfield(model,'csense')
        % If csense is not declared in the model, assume that all constraints are equalities.
        if printLevel>1
            fprintf('%s\n','We assume that all mass balance constraints are equalities, i.e., S*v = dxdt = 0')
        end
        model.csense(1:nMets,1) = 'E';
    else % if csense is in the model, move it to the lp problem structure
        if length(model.csense)~=nMets
            error('The length of csense does not match the number of rows of model.S.')
            model.csense(1:nMets,1) = 'E';
        else
            model.csense = columnVector(model.csense);
        end
    end
end

if ~isfield(model,'c')
    if printLevel>0
        fprintf('%s\n','FBA problem has no defined c in min c''*v. For now we assume c = 0.')
    end
    model.c=zeros(size(A,2),1);
end

% Compute f* = max c'v or f* = min c'v
if strcmpi(osenseStr,'max')
    osense = -1;
elseif strcmpi(osenseStr,'min')
    osense = +1;
elseif strcmpi(osenseStr,'none')
    osense = +1;
    model.c = zeros(nRxns,1);
end

if ~isfield(model,'dxdt')
    if isfield(model,'b')
        %old style model
        if length(model.b)==nMets
            model.dxdt=model.b;
            %model=rmfield(model,'b'); %tempting to do this
        else
            if isfield(model,'C')
                %new style model, b must be rhs for [S;C]*v {=,<=,>=} [dxdt,d] == b
                if length(model.b)~=nMets+nIneq
                    error('model.b must equal the number of rows of [S;C]')
                end
            else
                error('model.b must equal the number of rows of S or [S;C]')
            end
        end
    end
else
    if length(model.dxdt)~=size(model.S,1)
        error('Number of rows in model.dxdt and model.S must match')
    end
end

if isfield(model,'C')
    %pad out matrices with a new slack variable (s)
    % A*x <= rhs is the same as [A I]*[x;s] = rhs with 0 <= s
    e(model.csense == 'E',1) = 0;
    e(model.csense == 'G',1) = -1;
    e(model.csense == 'L',1) = 1;
    Ie=spdiags(e,0,nMets+nIneq,nMets+nIneq);
    eBool=e~=0;
    Ie=Ie(:,eBool);
end

%now build the equality and inequality constraint matrices
if isfield(model,'d')
    LPproblem.b = [model.dxdt;model.d];
else
    LPproblem.b = model.dxdt;
end

if isfield(model,'C')
    LPproblem.A=[model.S;model.C];
    LPproblem.A=[LPproblem.A,Ie];
else
    LPproblem.A = model.S;
end

%copy over the constraint sense also
LPproblem.osense=osense;

%copy over the constraint sense also
LPproblem.csense=model.csense;

%linear objective coefficient
if isfield(model,'C')
    LPproblem.c = [model.c; zeros(nIneq,1)];
else
    LPproblem.c = model.c;
end

%box constraints
if isfield(model,'C')
    %include constraints on the slack variables
    LPproblem.lb = [model.lb; zeros(nIneq,1)];
    LPproblem.ub = [model.ub; ones(nIneq,1)*Inf];
else
    LPproblem.lb = model.lb;
    LPproblem.ub = model.ub;
end

%Double check that all inputs are valid:
if ~(verifyCobraProblem(LPproblem, [], [], false) == 1)
    error('invalid problem');
end

if nnz(model.c)~=0
    time=cputime;
    FBAsolution = solveCobraLP(LPproblem,CobraParams);
    time = cputime-time;
else
    time=0;
    FBAsolution.stat=1;
    FBAsolution.full=zeros(size(LPproblem.lb));
end

    %       stat                status
    %                           1 =  Solution found
    %                           2 =  Unbounded
    %                           0 =  Infeasible
    %                           -1=  Invalid input
switch FBAsolution.stat
    case 2
        v = [];
        error('%s\nRxns','FBA problem unbounded !')
    case 0
        v = [];
        error('%s\nRxns','FBA problem infeasible !')
    case -1
        v = [];
        error('%s\nRxns','FBA problem error: Invalid input !')
    case 1
        vFBA = FBAsolution.full(1:nRxns);
        objFBA = LPproblem.c'*FBAsolution.full;

        if nnz(model.c)~=0 && printLevel >= 0
            display('---FBA---')
            if printLevel > 0
                fprintf('%10g%s\n',objFBA,' FBA objective.');
                fprintf('%10u%s%g\n',nnz(abs(vFBA)>=epsilon),' reactions above epsilon = ',epsilon);
                fprintf('%10g%s\n',time,' computation time (sec)');
            end
            %display(strcat('Obj = ',num2str(objFBA)));
            %display(strcat('|vFBA|_0 = ',num2str(nnz(abs(vFBA)>=epsilon))));
            %display(strcat('Comp. time = ',num2str(time)));
        end

        % Minimise the number of reactions by keeping same max objective found previously
        % One adds the constraint : c'v = c'vFBA
        if any(LPproblem.c~=0)
            constraint.A = [LPproblem.A ; LPproblem.c'];
            constraint.b = [LPproblem.b ; objFBA];
            constraint.csense = [LPproblem.csense;'E'];
        else
            constraint.A = LPproblem.A;
            constraint.b = LPproblem.b;
            constraint.csense = LPproblem.csense;
        end

        constraint.lb = LPproblem.lb;
        constraint.ub = LPproblem.ub;

        %% Minimise l_0 norm
        time = cputime;
        params.epsilon=epsilon;
        solutionL0 = sparseLP(constraint, zeroNormApprox, params);

        if printLevel>2
            fprintf('%10g%s%g%s\n',norm(constraint.A*solutionL0.x-constraint.b),' ||S*v-b||_0, should be less than tolerance (',epsilon,').')
            fprintf('%10g%s%g%s\n',min(constraint.ub-solutionL0.x),'  min(ub-v), should be less than tolerance (',epsilon,').')
            fprintf('%10g%s%g%s\n',min(solutionL0.x-constraint.lb),'  min(v-lb), should be less than tolerance (',epsilon,').')
        end
        time = cputime - time;

        %save the solution
        vApprox=solutionL0.x;
        %identify active reactions
        activeRxnBool = abs(vApprox)>=epsilon;

        %Check if one can still achieve the same objective only with predicted active reactions
        %remove all predicted non-active reactions
        tightLPproblem = struct('c',LPproblem.c(activeRxnBool),'osense',osense,'A',LPproblem.A(:,activeRxnBool),'csense',LPproblem.csense,...
            'b',LPproblem.b,'lb',model.lb(activeRxnBool),'ub',model.ub(activeRxnBool));

        %solve the tighter problem
        tightSolution = solveCobraLP(tightLPproblem,CobraParams);

        if tightSolution.stat == 1 && abs(tightSolution.obj - objFBA)<epsilon
            %it could be that this solution is more sparse
            if nnz(activeRxnBool)> nnz(abs(tightSolution.full)>=epsilon)
                %identify active reactions
                activeRxnBoolOld=activeRxnBool;
                %update sparse solution and active reactions
                vApprox=sparse(nRxns,1);
                vApprox(activeRxnBool)=tightSolution.full;
                activeRxnBool = abs(vApprox)>=epsilon;
                if printLevel>1
                    fprintf('%s\n','Testing of DC approximation results in a sparser solution')
                    disp(solutionL0.x(activeRxnBoolOld & ~activeRxnBool))
                end
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
essentialRxnBool = false(nRxns,1);
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
        tighterLPproblem = struct('c',tightLPproblem.c(essentialTightRxnsBoolTemp),'osense',osense,'A',tightLPproblem.A(:,essentialTightRxnsBoolTemp),'csense',LPproblem.csense,'b',LPproblem.b,'lb',tightLPproblem.lb(essentialTightRxnsBoolTemp),'ub',tightLPproblem.ub(essentialTightRxnsBoolTemp));
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
    % vHeuristic = sparse(nRxns,1);
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
            tighterLPproblem = struct('c',tightLPproblem.c(tighterRxnsBool),'osense',osense,'A',tightLPproblem.A(:,tighterRxnsBool),'csense',tightLPproblem.csense,'b',tightLPproblem.b,'lb',tightLPproblem.lb(tighterRxnsBool),'ub',tightLPproblem.ub(tighterRxnsBool));
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
    minimalRxnBool = false(nRxns,1);
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
    if any(LPproblem.c)
         if printLevel > 0
            fprintf('%10g%s\n',LPproblem.c'*solutionL0.x,' = Sparse FBA objective.');
            fprintf('%10g%s\n',norm(LPproblem.c'*solutionL0.x - objFBA,2),' = ||c^T*v - f*||^2.');
            fprintf('%10u%s%g\n',nnz(abs(vFBA)>=epsilon),' reactions above epsilon = ',epsilon);
            fprintf('%10g%s\n',time,' computation time (sec)');
         end
    end
%    fprintf('%u%s%s%s\nRxns',nnz(activeRxnBool),' rxns in sparsest solution found using a ', solutionL0.bestAprox, ' approximation.');
    if  checkMinimalSet
        fprintf('%u%s\n',nnz(minimalRxnBool),' of these are heuristically minimal rxns.');
    end
    if  checkEssentialSet
        fprintf('%u%s\n',nnz(essentialRxnBool),' of these are essential rxns.');
    end
else
    if printLevel > 1
        fprintf('%u%s\n',nnz(sparseRxnBool),' rxns in sparsest solution.');
        if  checkEssentialSet
            fprintf('%u%s\n',nnz(essentialRxnBool),' of these are essential rxns.');
        end
    end
end

%only return the fluxes and not the slack variables if they exist
if isfield(model,'C')
    vSparse=vSparse(1:nRxns,1);
    sparseRxnBool=sparseRxnBool(1:nRxns,1);
    essentialRxnBool=essentialRxnBool(1:nRxns,1);
end
