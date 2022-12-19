function [q, g, solutionQP] = thermoFlux2QNty(model,solution,param)
% Given a steady state thermodynamically feasible flux vector, v, such that
%
%     S*v = b
%  l <= v <= u 
%
% Compute q and g = N'*y such that
%
%     N*diag(q)*g = b - B*w
%
% where the stoichiometric matrix and flux vector are split into internal
% and external components: S = [N B] and v = [z; w], 

[nMet,nRxn]=size(model.S);

if ~exist('param','var')
    param=struct();
end

if ~isfield(model,'SConsistentRxnBool')  || ~isfield(model,'SConsistentMetBool')
    if ~isfield(param,'SConsistentMethod')
        param.SConsistentMethod = 'findSExRxnInd';
    end
    switch param.SConsistentMethod
        case 'findSExRxnInd'
            %finds the reactions in the model which export/import from the model
            %boundary i.e. mass unbalanced reactions
            %e.g. Exchange reactions
            %     Demand reactions
            %     Sink reactions
            model = findSExRxnInd(model,[],param.printLevel-1);
            model.SConsistentMetBool= model.SIntMetBool;
            model.SConsistentRxnBool= model.SIntRxnBool;
        case 'findStoichConsistentSubset'
            % Finds the subset of `S` that is stoichiometrically consistent using
            % an iterative cardinality optimisation approach
            [SConsistentMetBool, SConsistentRxnBool, ...
                SInConsistentMetBool, SInConsistentRxnBool, ...
                unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model] ...
                = findStoichConsistentSubset(model);
    end
else
    if length(model.SConsistentRxnBool)~=nRxn
        error('Length of model.SConsistentRxnBool must equal the number of cols of model.S')
    end
    if length(model.SConsistentMetBool)~=nMet
        error('Length of model.SConsistentMetBool must equal the number of rows of model.S')
    end
end

if ~isfield(param,'bigNum')
    param.bigNum = 1;
end

[model,rankK,nnzK,timeTaken] = internalNullspace(model);

z = solution.v(model.SConsistentRxnBool);

%                       * .A - LHS matrix
%                       * .b - RHS vector
%                       * .F - positive semidefinite matrix for quadratic part of objective (see above)
%                       * .c - Objective coeff vector
%                       * .lb - Lower bound vector
%                       * .ub - Upper bound vector
%                       * .osense - Objective sense for the linear part (-1 max, +1 min)
%                       * .csense - Constraint senses, a string containing the constraint sense for
%                         each row in A ('E', equality, 'G' greater than, 'L' less than).
[n,m]=size(model.K);
QP.A = [model.K'*diag(z); ones(1,n)];
QP.b = [zeros(m,1);1];
QP.csense(1:m+1) ='E'; 
QP.lb = zeros(n,1);
QP.ub = param.bigNum*ones(n,1);
QP.c = zeros(n,1);
QP.F = speye(n);
QP.osense = 1;

solutionQP = solveCobraQP(QP);

if solutionQP.stat == 1
    q0 = 1./solutionQP.full;
    q = NaN*ones(nRxn,1);
    q(model.SConsistentRxnBool)=q0;
    
    g0 = diag(solutionQP.full)*z;
    %N = model.S(:,model.SConsistentRxnBool);
    %y = N'\g0;
    g = NaN*ones(nRxn,1);
    g(model.SConsistentRxnBool)=g0;
    
    %dg0 = N'*y - g0;
    %dg = NaN*ones(nRxn,1);
    %dg(model.SConsistentRxnBool)=dg0;
else
    solutionQP
    error('thermoFlux2QNty: solveCobraQP did not solve')
end
end

