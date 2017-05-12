function [solutionDel,solutionWT,totalFluxDiff,solStatus] = ...
    linearMOMA(modelWT,modelDel,osenseStr,minFluxFlag,verbFlag)
%linearMOMA Performs a linear version of the MOMA (minimization of
%metabolic adjustment) approach 
%
% [solutionDel,solutionWT,totalFluxDiff,solStatus] = 
%       linearMOMA(modelWT,modelDel,osenseStr,minFluxFlag,verbFlab)
%
%INPUTS
% modelWT           Wild type model
% modelDel          Deletion strain model
%
%OPTIONAL INPUTS
% osenseStr         Maximize ('max')/minimize ('min') (Default = 'max')
% minFluxFlag       Minimize the absolute value of fluxes in the optimal MOMA
%                   solution (Default = false)
% verbFlag          Verbose output (Default = false)
% 
%OUTPUTS
% solutionDel       Deletion solution structure
% solutionWT        Wild-type solution structure
% totalFluxDiff     Value of the linear MOMA objective, i.e. sum|v_wt-v_del|
% solStatus         Solution status
%
% Solves the problem
%
% min sum|v_wt - v_del|
%     S_wt*v_wt = 0
%     lb_wt <= v_wt <= ub_wt
%     c_wt'*v_wt = f_wt
%     S_del*v_del = 0
%     lb_del <= v_del <= ub_del
%
% Here f_wt is the optimal wild type objective value found by FBA
%
% Notes:
%
% 1) This formulation allows for selecting the most appropriate
% optimal wild type FBA solution as the starting point as opposed to
% picking an arbitrary starting point (original MOMA implementation).
%
% 2) The reaction sets in the two models do not have to be equal as long as
% there is at least one reaction in common
%
% Markus Herrgard 11/7/06

if (nargin <3 || isempty(osenseStr))
    osenseStr = 'max';
end
if (nargin < 4 || isempty(minFluxFlag))
    minFluxFlag = false;
end
if (nargin < 5)
    verbFlag = false;
end

% LP solution tolerance
global CBT_LP_PARAMS
if (exist('CBT_LP_PARAMS', 'var'))
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
else
    tol = 1e-6;
end

[nMets1,nRxns1] = size(modelWT.S);
[nMets2,nRxns2] = size(modelDel.S);

% Match model reaction sets
commonRxns = ismember(modelWT.rxns,modelDel.rxns);
nCommon = sum(commonRxns);
if (nCommon == 0)
    error('No common rxns in the models');
end

solutionWT.f = [];
solutionWT.x = [];
solutionWT.stat = -1;
solutionDel.f = [];
solutionDel.x = [];
solutionDel.stat = -1;

if (verbFlag)
    fprintf('Solving wild type FBA: %d constraints %d variables ',nMets1,nRxns1);
end
% Solve wt problem
solutionWT = optimizeCbModel(modelWT,osenseStr);

if (verbFlag)
    fprintf('%f seconds\n',solutionWT.time);
end
% Round off solution to avoid numerical problems
if (strcmp(osenseStr,'max'))
    objValWT = floor(solutionWT.f/tol)*tol;
else
    objValWT = ceil(solutionWT.f/tol)*tol;
end

% Variables in the following problem are
% x = [v1;v2;delta+;delta-]
% where v1 = wild type flux vector
%       v2 = deletion strain flux vector
%       delta+ = v1 - v2
%       delta- = v2 - v1

if (solutionWT.stat > 0)
    % Construct the LHS matrix
    % Rows:
    % 1: Swt*v1 = 0 for the wild type
    % 2: Sdel*v2 = 0 for the deletion strain
    % 3: delta+ >= v1-v2
    % 4: delta- >= v2-v1
    % 5: c'v1 = f1 (wild type)
    A = [modelWT.S sparse(nMets1,nRxns2+2*nCommon);
         sparse(nMets2,nRxns1) modelDel.S sparse(nMets2,2*nCommon);
         createDeltaMatchMatrix(modelWT.rxns,modelDel.rxns);
         modelWT.c' sparse(1,nRxns2+2*nCommon)];
     
    % Construct the RHS vector
    b = [zeros(nMets1+nMets2+2*nCommon,1);objValWT];
    
    % Construct the objective (sum of all delta+ and delta-)
    c = [zeros(nRxns1+nRxns2,1);ones(2*nCommon,1)];
    
    % Construct the ub/lb
    % delta+ and delta- are in [0 10000]
    lb = [modelWT.lb;modelDel.lb;zeros(2*nCommon,1)];
    ub = [modelWT.ub;modelDel.ub;10000*ones(2*nCommon,1)];

    % Construct the constraint direction vector (G for delta's, E for
    % everything else)
    csense(1:(nMets1+nMets2)) = 'E';
    csense((nMets1+nMets2)+1:(nMets1+nMets2+2*nCommon)) = 'G';
    if (strcmp(osenseStr,'max'))    
        csense(end+1) = 'G';
    else
        csense(end+1) = 'L';
    end
    
    if (verbFlag)
        fprintf('Solving linear MOMA: %d constraints %d variables ',size(A,1),size(A,2));
    end
    
    % Solve the linearMOMA problem
    [LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense] = deal(A,b,c,lb,ub,csense,1);
    LPsolution = solveCobraLP(LPproblem);

    if (verbFlag)
        fprintf('%f seconds\n',LPsolution.time);
    end
    
    if (LPsolution.stat > 0)
        solutionDel.x = LPsolution.full((nRxns1+1):(nRxns1+nRxns2));
        solutionDel.f = sum(modelDel.c.*solutionDel.x);   
        solutionWT.x = LPsolution.full(1:nRxns1);
        totalFluxDiff = LPsolution.obj;
    end

    if (LPsolution.stat > 0 & minFluxFlag)
        A = [modelWT.S sparse(nMets1,nRxns2+2*nCommon+2*nRxns1+2*nRxns2);
            sparse(nMets2,nRxns1) modelDel.S sparse(nMets2,2*nCommon+2*nRxns1+2*nRxns2);
            createDeltaMatchMatrix(modelWT.rxns,modelDel.rxns) sparse(2*nCommon,2*nRxns1+2*nRxns2);
            speye(nRxns1,nRxns1) sparse(nRxns1,nRxns2) sparse(nRxns1,2*nCommon) speye(nRxns1,nRxns1) sparse(nRxns1,nRxns1+2*nRxns2);
            -speye(nRxns1,nRxns1) sparse(nRxns1,nRxns2) sparse(nRxns1,2*nCommon) sparse(nRxns1,nRxns1) speye(nRxns1,nRxns1) speye(nRxns1,2*nRxns2);
            sparse(nRxns2,nRxns1) speye(nRxns2,nRxns2) sparse(nRxns2,2*nCommon) sparse(nRxns2,2*nRxns1) speye(nRxns2,nRxns2) sparse(nRxns2,nRxns2);
            sparse(nRxns2,nRxns1) -speye(nRxns2,nRxns2) sparse(nRxns2,2*nCommon) sparse(nRxns2,2*nRxns1) sparse(nRxns2,nRxns2) speye(nRxns2,nRxns2);
            modelWT.c' sparse(1,nRxns2+2*nCommon+2*nRxns1+2*nRxns2);
            sparse(1,nRxns1+nRxns2) ones(1,2*nCommon) sparse(1,2*nRxns1+2*nRxns2)];
        % Construct the RHS vector
        b = [zeros(nMets1+nMets2+2*nCommon+2*nRxns1+2*nRxns2,1);objValWT;ceil(totalFluxDiff/tol)*tol];

        % Construct the objective (sum of all delta+ and delta-)
        c = [zeros(nRxns1+nRxns2+2*nCommon,1);ones(2*nRxns1+2*nRxns2,1)];

        % Construct the ub/lb
        % delta+ and delta- are in [0 10000]
        lb = [modelWT.lb;modelDel.lb;zeros(2*nCommon+2*nRxns1+2*nRxns2,1)];
        ub = [modelWT.ub;modelDel.ub;10000*ones(2*nCommon+2*nRxns1+2*nRxns2,1)];
        csense(1:(nMets1+nMets2)) = 'E';
        csense((nMets1+nMets2)+1:(nMets1+nMets2+2*nCommon+2*nRxns1+2*nRxns2)) = 'G';
        if (strcmp(osenseStr,'max'))
            csense(end+1) = 'G';
        else
            csense(end+1) = 'L';
        end
        csense(end+1) = 'L';

        if (verbFlag)
            fprintf('Minimizing MOMA flux distribution norms: %d constraints %d variables ',size(A,1),size(A,2));
        end
        
        [LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense] = deal(A,b,c,lb,ub,csense,1);
        LPsolution = solveCobraLP(LPproblem);
        if (verbFlag)
            fprintf('%f seconds\n',LPsolution.time);
        end
        if (LPsolution.stat > 0)
            solutionDel.x = LPsolution.full((nRxns1+1):(nRxns1+nRxns2));
            solutionDel.f = sum(modelDel.c.*solutionDel.x);   
            solutionWT.x = LPsolution.full(1:nRxns1);
        end
    end
    
else
    warning('Wild type FBA problem is infeasible or unconstrained');
end

solutionWT.stat = LPsolution.stat;
solutionDel.stat = LPsolution.stat;
solStatus = LPsolution.stat;
