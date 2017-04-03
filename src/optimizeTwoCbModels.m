function [solution1,solution2,totalFluxDiff] = optimizeTwoCbModels(model1,model2,osenseStr,minFluxFlag,verbFlag)
%optimizeTwoCbModels Simultaneously solve two flux balance problems and
%minimize the difference between the two solutions
%
% [solution1,solution2,totalFluxDiff] =
%   optimizeTwoCbModels(model1,model2,osenseStr,minFluxFlag,verbFlag)
%
%INPUTS
% model1        The first COBRA model
% model2        The second COBRA model
% model (the following fields are requires - others can be supplied)
%   S             Stoichiometric matrix
%   b             Right hand side = 0
%   c             Objective coefficients
%   lb            Lower bounds
%   ub            Upper bounds
%
%OPTIONAL INPUTS
% osenseStr     Maximize ('max')/minimize ('min') (Default = 'max')
% minFluxFlag   Minimize the absolute value of fluxes in the optimal MOMA
%               solution (Default = false)
% verbFlag      Verbose output (Default = false)
%
%OUTPUTS
% solution1     Solution for the 1st model
% solution2     Solution for the 2nd model
% totalFluxDiff 1-norm of the difference between the flux vectors sum|v1-v2| 
%
% solution
%   f         Objective value
%   x         Primal (flux vector)
%
%
% First solves two separate FBA problems:
%                                 f1 = max/min c1'v1
%                                 subject to S1*v1 = b1
%                                            lb1 <= v1 <= ub1
%                                 f2 = max/min c2'v2
%                                 subject to S2*v2 = b2
%                                            lb2 <= v2 <= ub2
%
% Then solves the following LP to obtain the two flux vectors with the
% smallest possible 1-norm difference between them
%
%                                 min |v1-v2|
%                                   s.t. S1*v1 = b1
%                                        c1'v1 = f1
%                                        lb1 <= v1 <= ub1
%                                        S2*v2 = b2
%                                        c2'v2 = f2
%                                        lb2 <= v2 <= ub2
% 
% Finally optionally minimizes the 1-norm of the flux vectors
%
% Markus Herrgard 1/4/07

% LP solution tolerance
global CBT_LP_PARAMS
if (exist('CBT_LP_PARAMS', 'var'))
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    end
else
    tol = 1e-6;
end

%TODO: Have a look how the model.osenseStr can be incorporated here.
if (nargin < 3)
    osenseStr = 'max';
end
if (nargin < 4)
    minFluxFlag = false;
end
if (nargin < 5)
    verbFlag = false;
end

% Figure out objective sense
if (strcmp(osenseStr,'max'))
    osense = -1;
else
    osense = +1;
end

% Find model dimensionalities
[nMets1,nRxns1] = size(model1.S);
[nMets2,nRxns2] = size(model2.S);

% Match model reaction sets
commonRxns = ismember(model1.rxns,model2.rxns);
nCommon = sum(commonRxns);
if (nCommon == 0)
    error('No common rxns in the models');
end

% Fill in the RHS vector if not provided
if (~isfield(model1,'b'))
    model1.b = zeros(size(model1.S,1),1);
end
if (~isfield(model2,'b'))
    model2.b = zeros(size(model2.S,1),1);
end

csense = [];

if (verbFlag)
    fprintf('Solving original FBA problems: %d constraints %d variables ',nMets1+nMets2,nRxns1+nRxns2);
end
% Solve original FBA problems

FBAsol1 = optimizeCbModel(model1,osenseStr);
FBAsol2 = optimizeCbModel(model2,osenseStr);

if (verbFlag)
    fprintf('%f seconds\n',FBAsol1.time+FBAsol2.time);
end

% Minimize the difference between flux solutions
if (FBAsol1.stat > 0 && FBAsol1.stat > 0)
    f1 = FBAsol1.f;
    f2 = FBAsol2.f;
    if (strcmp(osenseStr,'max'))
        f1 = floor(f1/tol)*tol;
        f2 = floor(f2/tol)*tol;
    else
        f1 = ceil(f1/tol)*tol;
        f2 = ceil(f2/tol)*tol;
    end
    % Set up the optimization problem
    % min sum(delta+ + delta-)
    % 1: S1*v1 = 0
    % 2: S2*v2 = 0
    % 3: delta+ >= v1-v2
    % 4: delta- >= v2-v1
    % 5: c1'v1 >= f1 (optimal value of objective)
    % 6: c2'v2 >= f2
    %
    % delta+,delta- >= 0
    A = [model1.S sparse(nMets1,nRxns2+2*nCommon);
        sparse(nMets2,nRxns1) model2.S sparse(nMets2,2*nCommon);
        createDeltaMatchMatrix(model1.rxns,model2.rxns)
        model1.c' sparse(1,nRxns2+2*nCommon);
        sparse(1,nRxns1) model2.c' sparse(1,2*nCommon);];
    c = [zeros(nRxns1+nRxns2,1);ones(2*nCommon,1)];
    lb = [model1.lb;model2.lb;zeros(2*nCommon,1)];
    ub = [model1.ub;model2.ub,;10000*ones(2*nCommon,1)];
    b = [model1.b;model2.b;zeros(2*nCommon,1);f1;f2];
    clear csense;
    csense(1:(nMets1+nMets2)) = 'E';
    csense(end+1:end+2*nCommon) = 'G';
    if (strcmp(osenseStr,'max'))    
        csense(end+1:end+2) = 'G';
    else
        csense(end+1:end+2) = 'L';
    end
    
    % Re-solve the problem
    if (verbFlag)
        fprintf('Minimize difference between solutions: %d constraints %d variables ',size(A,1),size(A,2));
    end
    
    [LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense] = deal(A,b,c,lb,ub,csense,1);
    LPsol = solveCobraLP(LPproblem);

    if (verbFlag)
        fprintf('%f seconds\n',LPsol.time);
    end    
    
    if (LPsol.stat > 0)
        totalFluxDiff = LPsol.obj;
        solution1.f = f1;
        solution2.f = f2;
        solution1.x = LPsol.full(1:nRxns1);
        solution2.x = LPsol.full(nRxns1+1:nRxns1+nRxns2);
    else
        totalFluxDiff = [];
        solution1.f = [];
        solution2.f = [];
        solution1.x = [];
        solution2.x = [];
    end
    
    if (LPsol.stat > 0 & minFluxFlag)
        A = [model1.S sparse(nMets1,nRxns2+2*nCommon+2*nRxns1+2*nRxns2);
            sparse(nMets2,nRxns1) model2.S sparse(nMets2,2*nCommon+2*nRxns1+2*nRxns2);];
        A = [A;
            createDeltaMatchMatrix(model1.rxns,model2.rxns) sparse(2*nCommon,2*nRxns1+2*nRxns2)];
        A = [A;
            speye(nRxns1,nRxns1) sparse(nRxns1,nRxns2) sparse(nRxns1,2*nCommon) speye(nRxns1,nRxns1) sparse(nRxns1,nRxns1+2*nRxns2);
            -speye(nRxns1,nRxns1) sparse(nRxns1,nRxns2) sparse(nRxns1,2*nCommon) sparse(nRxns1,nRxns1) speye(nRxns1,nRxns1) sparse(nRxns1,2*nRxns2);
            sparse(nRxns2,nRxns1) speye(nRxns2,nRxns2) sparse(nRxns2,2*nCommon) sparse(nRxns2,2*nRxns1) speye(nRxns2,nRxns2) sparse(nRxns2,nRxns2);
            sparse(nRxns2,nRxns1) -speye(nRxns2,nRxns2) sparse(nRxns2,2*nCommon) sparse(nRxns2,2*nRxns1) sparse(nRxns2,nRxns2) speye(nRxns2,nRxns2);];
        A = [A;
            model1.c' sparse(1,nRxns2+2*nCommon+2*nRxns1+2*nRxns2);
            sparse(1,nRxns1) model2.c' sparse(1,2*nCommon+2*nRxns1+2*nRxns2);
            sparse(1,nRxns1+nRxns2) ones(1,2*nCommon) sparse(1,2*nRxns1+2*nRxns2)];
        % Construct the RHS vector
        b = [zeros(nMets1+nMets2+2*nCommon+2*nRxns1+2*nRxns2,1);f1;f2;ceil(totalFluxDiff/tol)*tol];

        % Construct the objective (sum of all delta+ and delta-)
        c = [zeros(nRxns1+nRxns2+2*nCommon,1);ones(2*nRxns1+2*nRxns2,1)];

        % Construct the ub/lb
        % delta+ and delta- are in [0 10000]
        lb = [model1.lb;model2.lb;zeros(2*nCommon+2*nRxns1+2*nRxns2,1)];
        ub = [model1.ub;model2.ub;10000*ones(2*nCommon+2*nRxns1+2*nRxns2,1)];
        csense(1:(nMets1+nMets2)) = 'E';
        csense((nMets1+nMets2)+1:(nMets1+nMets2+2*nCommon+2*nRxns1+2*nRxns2)) = 'G';
        if (strcmp(osenseStr,'max'))
            csense(end+1:end+2) = 'G';
        else
            csense(end+1:end+2) = 'L';
        end
        csense(end+1) = 'L';

        if (verbFlag)
            fprintf('Minimizing flux distribution norms: %d constraints %d variables ',size(A,1),size(A,2));
        end

        [LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense] = deal(A,b,c,lb,ub,csense,1);
        LPsol = solveCobraLP(LPproblem);
        
        if (verbFlag)
            fprintf('%f seconds\n',LPsol.time);
        end
        
        if (LPsol.stat > 0)
            solution1.x = LPsol.full(1:nRxns1);
            solution2.x = LPsol.full(nRxns1+1:nRxns1+nRxns2);
        end

    end
end

solution1.stat = LPsol.stat;
solution2.stat = LPsol.stat;

