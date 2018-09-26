function [solutionDel, solutionWT, totalFluxDiff, solStatus] = MOMA(modelWT, modelDel, osenseStr, verbFlag, minNormFlag)
% Performs a quadratic version of the MOMA (minimization of
% metabolic adjustment) approach
%
% USAGE:
%
%    [solutionDel, solutionWT, totalFluxDiff, solStatus] = MOMA(modelWT, modelDel, osenseStr, verbFlag, minNormFlag)
%
% INPUTS:
%    modelWT:          Wild type model
%    modelDel:         Deletion strain model
%
% OPTIONAL INPUTS:
%    osenseStr:        Maximize ('max') / minimize ('min') (Default = 'max')
%    verbFlag:         Verbose output (Default = false)
%    minNormFlag:      Work with minimum 1-norm flux distribution for the FBA
%                      problem (Default = false)
%
% OUTPUTS:
%    solutionDel:      Deletion solution structure
%    solutionWT:       Wild-type solution structure
%    totalFluxDiff:    Value of the linear MOMA objective, i.e.
%                      :math:`\sum (v_{wt}-v_{del})^2`
%    solStatus:        Solution status - solves two different types of MOMA problems:
%
%                        1.  MOMA that avoids problems with alternative optima (this is the
%                            default)
%                        2.  MOMA that uses a minimum 1-norm wild type FBA solution (this approach
%                            is used if minNormFlag = true)
% First solve:
%
% .. math::
%      max ~&~ c_{wt}^T v_{wt0} \\
%          ~&~ lb_{wt} \leq v_{wt0} \leq ub_{wt} \\
%          ~&~ S_{wt}v_{wt0} = 0 \\
%
% Then solve:
%
% .. math::
%      min ~&~ \sum (v_{wt} - v_{del})^2 \\
%          ~&~ S_{wt}v_{wt} = 0 \\
%          ~&~ S_{del}v_{del} = 0 \\
%          ~&~ lb_{wt} \leq v_{wt} \leq ub_{wt} \\
%          ~&~ lb_{del} \leq v_{del} \leq ub_{del} \\
%          ~&~ c_{wt}^T v_{wt} = f_{wt} \\
%
% Here :math:`f_{wt}` is the optimal wild type objective value found by FBA in the
% first problem. Note that the FBA solution :math:`v_{wt0}` is not used in the second
% problem. This formulation avoids any problems with alternative optima
%
% First solve
%
% .. math::
%      max ~&~ c_{wt}^T v_{wt0} \\
%          ~&~ lb_{wt} \leq v_{wt0} \leq ub_{wt} \\
%          ~&~ S_{wt}v_{wt0} = 0 \\
%
% Then solve
%
% .. math::
%      min ~&~ |v_{wt}| \\
%          ~&~ S_{wt}v_{wt} = b_{wt} \\
%          ~&~ c_{wt}^T v_{wt} = f_{wt} \\
%          ~&~ lb_{wt} \leq v_{wt} \leq ub_{wt} \\
%
% Here :math:`f_{wt}` is the objective value obtained in the 1st optimization.
%
% Finally solve:
%
% .. math::
%      min ~&~ \sum (v_{wt} - v_{del})^2 \\
%          ~&~ S_{del}v_{del} = 0 \\
%          ~&~ lb_{del} \leq v_{del} \leq ub_{del}
%
% NOTE::
%
%    1) These formulation allows for selecting for more appropriate
%    optimal wild type FBA solutions as the starting point as opposed to
%    picking an arbitrary starting point (original MOMA implementation).
%
%    2) The reaction sets in the two models do not have to be equal as long as
%    there is at least one reaction in common
%
% .. Author: - Markus Herrgard 11/7/06

if (nargin <3 || isempty(osenseStr))
    osenseStr = 'max';
    if isfield(modelWT,'osenseStr')
        osenseStr = modelWT.osenseStr;
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
        QPproblem = buildLPproblemFromModel(modelDel);
        QPproblem.c(1:nRxns) = -2*solutionWT.x;
        QPproblem.F = sparse(size(QPproblem.A,2));
        QPproblem.F(1:nRxns2,1:nRxns2) = 2*speye(nRxns2);
        
    else

        % Construct the LHS matrix
        % Rows:
        % 1: Swt*v1 = 0 for the wild type
        % 2: Sdel*v2 = 0 for the deletion strain
        % 5: c'v1 = f1 (wild type)
        LPWT = buildLPproblemFromModel(modelWT);
        LPDel = buildLPproblemFromModel(modelDel);        
        [nWTCtrs,nWTVars] = size(LPWT.A);
        [nDelCtrs,nDelVars] = size(LPDel.A);
        deltaMat = createDeltaMatchMatrix(modelWT.rxns,modelDel.rxns);
        deltaMat = deltaMat(1:nCommon,1:(nRxns1+nRxns2+nCommon));
        deltaMatWT = deltaMat(1:nCommon,1:nRxns1);
        deltaMatDel = deltaMat(1:nCommon,nRxns1+(1:nRxns2));
        deltaMatCom = deltaMat(1:nCommon,(nRxns1+nRxns2)+(1:nCommon));
        QPproblem.A = [LPWT.A, sparse(nWTCtrs,nDelVars+nCommon);...
                       sparse(nDelCtrs,nWTVars),LPDel.A,sparse(nDelCtrs,nCommon);...
                       deltaMatWT, sparse(nCommon,nWTVars - nRxns1), deltaMatDel, sparse(nCommon,nDelVars - nRxns2), deltaMatCom;...
                       LPWT.c',sparse(1,nDelVars+nCommon)];
        % Construct the RHS vector
        QPproblem.b = [LPWT.b;LPDel.b;zeros(nCommon,1);objValWT];

        % Linear objective = 0
        QPproblem.c = zeros(nWTVars+nDelVars+nCommon,1);

        % Construct the ub/lb
        % delta [-10000 10000]
        QPproblem.lb = [LPWT.lb;LPDel.lb;-10000*ones(nCommon,1)];
        QPproblem.ub = [LPWT.ub;LPDel.ub;10000*ones(nCommon,1)];

        % Construct the constraint direction vector (G for delta's, E for
        % everything else)
        if (strcmp(osenseStr,'max'))
            csense = 'G';
        else
            csense = 'L';
        end
        
        QPproblem.csense = [LPWT.csense;LPDel.csense;repmat('E',nCommon,1);csense];        
        

        % F matrix
        QPproblem.F = [sparse(nWTVars+nDelVars,nWTVars+nDelVars+nCommon);
                       sparse(nCommon,nWTVars+nDelVars) 2*eye(nCommon)];

    end
    
    % in either case: minimize the distance
    QPproblem.osense = 1;
    
    if (verbFlag)
        fprintf('Solving MOMA: %d constraints %d variables ',size(QPproblem.A,1),size(QPproblem.A,2));
    end

    % Solve the linearMOMA problem    
    %QPsolution = solveCobraQP(QPproblem,[],verbFlag-1);
    QPsolution = solveCobraQP(QPproblem, 'printLevel', verbFlag-1, 'method', 0);

    if (verbFlag)
        fprintf('%f seconds\n',QPsolution.time);
    end

    % Get the solution(s)
    if QPsolution.stat == 1
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
