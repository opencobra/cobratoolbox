function [solutionDel,solutionWT,totalFluxDiff,solStatus] = ...
    MOMA(modelWT,modelDel,osenseStr,verbFlag,minNormFlag)
%MOMA Performs a quadratic version of the MOMA (minimization of
%metabolic adjustment) approach 
%
% [solutionDel,solutionWT,totalFluxDiff,solStatus] = MOMA(modelWT,modelDel,osenseStr,verbFlag,minNormFlag)
%
%INPUTS
% modelWT           Wild type model
% modelDel          Deletion strain model
%
%OPTIONAL INPUTS
% osenseStr         Maximize ('max')/minimize ('min') (Default = 'max')
% verbFlag          Verbose output (Default = false)
% minNormFlag       Work with minimum 1-norm flux distribution for the FBA
%                   problem (Default = false)
% 
%OUTPUTS
% solutionDel       Deletion solution structure
% solutionWT        Wild-type solution structure
% totalFluxDiff     Value of the linear MOMA objective, i.e.
%                   sum(v_wt-v_del)^2
% solStatus         Solution status
%
% Solves two different types of MOMA problems:
%
% 1) MOMA that avoids problems with alternative optima (this is the
% default)
%
%    First solve:
%    
%    max c_wt'*v_wt0
%     lb_wt <= v_wt0 <= ub_wt
%     S_wt*v_wt0 = 0
%    
%    Then solve: 
%
%    min sum(v_wt - v_del)^2
%     S_wt*v_wt = 0
%     S_del*v_del = 0
%     lb_wt <= v_wt <= ub_wt
%     lb_del <= v_del <= ub_del
%     c_wt'*v_wt = f_wt
%
%   Here f_wt is the optimal wild type objective value found by FBA in the
%   first problem. Note that the FBA solution v_wt0 is not used in the second
%   problem. This formulation avoids any problems with alternative optima
%
% 2) MOMA that uses a minimum 1-norm wild type FBA solution (this approach
% is used if minNormFlag = true)
%
%    First solve
%
%    max c_wt'*v_wt0
%     lb_wt <= v_wt0 <= ub_wt
%     S_wt*v_wt0 = 0
%
%    Then solve
%
%    min |v_wt|
%     S_wt*v_wt = b_wt
%     c_wt'*v_wt = f_wt
%     lb_wt <= v_wt <= ub_wt
%    
%    Here f_wt is the objective value obtained in the 1st optimization.
%
%    Finally solve:
%
%    min sum(v_wt - v_del)^2
%     S_del*v_del = 0
%     lb_del <= v_del <= ub_del
%
% Notes:
%
% 1) These formulation allows for selecting for more appropriate
% optimal wild type FBA solutions as the starting point as opposed to
% picking an arbitrary starting point (original MOMA implementation).
%
% 2) The reaction sets in the two models do not have to be equal as long as
% there is at least one reaction in common
%
% Markus Herrgard 11/7/06

if (nargin <3 || isempty(osenseStr))
    osenseStr = 'max';
    if isfield(modelWT,'osenseStr')
        osenseStr = model.osenseStr;
    end
end
if (nargin < 4)
    verbFlag = false;
end
if (nargin < 5)
    minNormFlag = false;
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
selCommon1 = ismember(modelWT.rxns,modelDel.rxns);
nCommon = sum(selCommon1);
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
if minNormFlag
    solutionWT = optimizeCbModel(modelWT,osenseStr,true);
else
    solutionWT = optimizeCbModel(modelWT,osenseStr);
end

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
% x = [v1;v2;delta]
% where v1 = wild type flux vector
%       v2 = deletion strain flux vector
%       delta = v1 - v2

if (solutionWT.stat > 0)
    
    if minNormFlag

        b = zeros(nMets2,1);
        A = modelDel.S;
        c = -2*solutionWT.x;
        F = 2*eye(nRxns2);
        lb = modelDel.lb;
        ub = modelDel.ub;
        csense(1:nMets2) = 'E';

    else

        % Construct the LHS matrix
        % Rows:
        % 1: Swt*v1 = 0 for the wild type
        % 2: Sdel*v2 = 0 for the deletion strain
        % 5: c'v1 = f1 (wild type)
        deltaMat = createDeltaMatchMatrix(modelWT.rxns,modelDel.rxns);
        deltaMat = deltaMat(1:nCommon,1:(nRxns1+nRxns2+nCommon));
        A = [modelWT.S sparse(nMets1,nRxns2+nCommon);
            sparse(nMets2,nRxns1) modelDel.S sparse(nMets2,nCommon);
            deltaMat;
            modelWT.c' sparse(1,nRxns2+nCommon)];

        % Construct the RHS vector
        b = [zeros(nMets1+nMets2+nCommon,1);objValWT];

        % Linear objective = 0
        c = zeros(nRxns1+nRxns2+nCommon,1);

        % Construct the ub/lb
        % delta [-10000 10000]
        lb = [modelWT.lb;modelDel.lb;-10000*ones(nCommon,1)];
        ub = [modelWT.ub;modelDel.ub;10000*ones(nCommon,1)];

        % Construct the constraint direction vector (G for delta's, E for
        % everything else)
        csense(1:(nMets1+nMets2+nCommon)) = 'E';
        if (strcmp(osenseStr,'max'))
            csense(end+1) = 'G';
        else
            csense(end+1) = 'L';
        end

        % F matrix
        F = [sparse(nRxns1+nRxns2,nRxns1+nRxns2+nCommon);
            sparse(nCommon,nRxns1+nRxns2) 2*eye(nCommon)];

    end
    
    if (verbFlag)
        fprintf('Solving MOMA: %d constraints %d variables ',size(A,1),size(A,2));
    end
    
    % Solve the linearMOMA problem
    [QPproblem.A,QPproblem.b,QPproblem.F,QPproblem.c,QPproblem.lb,QPproblem.ub,QPproblem.csense,QPproblem.osense] = deal(A,b,F,c,lb,ub,csense,1);
    %QPsolution = solveCobraQP(QPproblem,[],verbFlag-1);
    QPsolution = solveCobraQP(QPproblem, 'printLevel', verbFlag-1);

    if (verbFlag)
        fprintf('%f seconds\n',QPsolution.time);
    end

    % Get the solution(s)
    if (QPsolution.stat > 0)
        if minNormFlag
            solutionDel.x = QPsolution.full;
        else
            solutionDel.x = QPsolution.full((nRxns1+1):(nRxns1+nRxns2));
            solutionWT.x = QPsolution.full(1:nRxns1);
        end
        solutionDel.f = sum(modelDel.c.*solutionDel.x);
        totalFluxDiff = sum((solutionWT.x-solutionDel.x).^2);
    end
    solutionDel.stat = QPsolution.stat;
    solStatus = QPsolution.stat;
    solutionDel.solver = QPsolution.solver;
    solutionDel.time = QPsolution.time;
    
else
    warning('Wild type FBA problem is infeasible or unconstrained');
end


