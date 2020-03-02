function [solutionDel, solutionWT, totalFluxDiff, solStatus] = linearMOMA(modelWT, modelDel, osenseStr, minFluxFlag, verbFlag)
% Performs a linear version of the MOMA (minimization of metabolic adjustment) approach
%
% USAGE:
%
%    [solutionDel, solutionWT, totalFluxDiff, solStatus] = linearMOMA(modelWT, modelDel, osenseStr, minFluxFlag, verbFlab)
%
% INPUTS:
%    modelWT:          Wild type model
%    modelDel:         Deletion strain model
%
% OPTIONAL INPUTS:
%    osenseStr:        Maximize ('max') / minimize ('min') (Default = 'max')
%    minFluxFlag:      Minimize the absolute value of fluxes in the optimal MOMA
%                      solution (Default = false)
%    verbFlag:         Verbose output (Default = false)
%
% OUTPUTS:
%    solutionDel:      Deletion solution structure
%    solutionWT:       Wild-type solution structure
%    totalFluxDiff:    Value of the linear MOMA objective, i.e. :math:`\sum |v_{wt}-v_{del}|`
%    solStatus:        Solution status - solves the problem: (`f_wt` is the optimal wild type objective value found by FBA)
%
% .. math::
%     min ~&~  \sum |v_{wt} - v_{del}| \\
%         ~&~ S_{wt}v_{wt} = 0 \\
%         ~&~ lb_{wt} \leq v_{wt} \leq ub_{wt} \\
%         ~&~ c_{wt}^T v_{wt} = f_{wt} \\
%         ~&~ S_{del}v_{del} = 0 \\
%         ~&~ lb_{del} \leq v_{del} \leq ub_{del}
%
% NOTE:
%
%    1) This formulation allows for selecting the most appropriate
%    optimal wild type FBA solution as the starting point as opposed to
%    picking an arbitrary starting point (original MOMA implementation).
%
%    2) The reaction sets in the two models do not have to be equal as long as
%    there is at least one reaction in common
%
% .. Author: - Markus Herrgard 11/7/06

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
    LPWT = buildLPproblemFromModel(modelWT);
    LPDel = buildLPproblemFromModel(modelDel);
    [nWTCtrs,nWTVars] = size(LPWT.A);
    [nDelCtrs,nDelVars] = size(LPDel.A);
    deltaMat = createDeltaMatchMatrix(modelWT.rxns,modelDel.rxns);
    deltaMatWT = deltaMat(1:2*nCommon,1:nRxns1);
    deltaMatDel = deltaMat(1:2*nCommon,nRxns1+(1:nRxns2));
    deltaMatCom = deltaMat(1:2*nCommon,(nRxns1+nRxns2)+(1:2*nCommon));
    LPproblem.A = [LPWT.A, sparse(nWTCtrs,nDelVars+2*nCommon);...
        sparse(nDelCtrs,nWTVars),LPDel.A,sparse(nDelCtrs,2*nCommon);...
        deltaMatWT, sparse(2*nCommon,nWTVars - nRxns1), deltaMatDel, sparse(2*nCommon,nDelVars - nRxns2), deltaMatCom;...
        LPWT.c',sparse(1,nDelVars+2*nCommon)];
    % Construct the RHS vector
    LPproblem.b = [LPWT.b;LPDel.b;zeros(2*nCommon,1);objValWT];
    
    % Linear objective = 0
    LPproblem.c = [zeros(nWTVars+nDelVars,1); ones(2*nCommon,1)];
        
    % Construct the ub/lb
    % delta [-10000 10000]
    LPproblem.lb = [LPWT.lb;LPDel.lb;zeros(2*nCommon,1)];
    LPproblem.ub = [LPWT.ub;LPDel.ub;10000*ones(2*nCommon,1)];
    
    % minimize
    LPproblem.osense = 1;
    
    % Construct the constraint direction vector (G for delta's, E for
    % everything else)
    if (strcmp(osenseStr,'max'))
        csense = 'G';
    else
        csense = 'L';
    end
    
    LPproblem.csense = [LPWT.csense;LPDel.csense;repmat('G',2*nCommon,1);csense];           
    
    LPsolution = solveCobraLP(LPproblem);

    if (verbFlag)
        fprintf('%f seconds\n',LPsolution.time);
    end

    if (LPsolution.stat > 0)
        solutionDel.x = LPsolution.full((nWTVars+1):(nWTVars+nRxns2));
        solutionDel.full = LPsolution.full((nWTVars+1):(nWTVars+nRxns2));
        solutionDel.f = sum(modelDel.c.*solutionDel.x);
        solutionWT.x = LPsolution.full(1:nRxns1);
        solutionWT.full = LPsolution.full(1:nRxns1);
        totalFluxDiff = LPsolution.obj;
    end

    if (LPsolution.stat > 0 && minFluxFlag)
        % Add things to the original LPproblem:        
        LPproblem.A = [LPWT.A, sparse(nWTCtrs,nDelVars+2*nCommon+2*nRxns1+2*nRxns2);... % Swt * v = 0;
        sparse(nDelCtrs,nWTVars),LPDel.A,sparse(nDelCtrs,2*nCommon+2*nRxns1+2*nRxns2);... % Sdel * v = 0;
        deltaMatWT, sparse(2*nCommon,nWTVars - nRxns1), deltaMatDel, sparse(2*nCommon,nDelVars - nRxns2), deltaMatCom, sparse(2*nCommon,+2*nRxns1+2*nRxns2);... % dist(WT,del) - delta < 0 
        speye(nRxns1,nWTVars),sparse(nRxns1,nDelVars + 2*nCommon), speye(nRxns1, 2*nRxns1+ 2*nRxns2);... % delta + WT > 0
        -speye(nRxns1,nWTVars),sparse(nRxns1,nDelVars + 2*nCommon + nRxns1), speye(nRxns1, nRxns1+ 2*nRxns2);... % delta - WT > 0
        sparse(nRxns2,nWTVars),speye(nRxns2,nDelVars + 2*nCommon + 2*nRxns1), speye(nRxns2, 2*nRxns2);... % delta + Del > 0
        sparse(nRxns2,nWTVars),-speye(nRxns2,nDelVars + 2*nCommon + 2*nRxns1 + nRxns2), speye(nRxns2, nRxns2);... % delta - Del > 0
        LPWT.c',sparse(1,nDelVars+2*nCommon+2*nRxns1+2*nRxns2);... % obj >= actual obj
        sparse(1,nWTVars+nDelVars) ones(1,2*nCommon) sparse(1,2*nRxns1+2*nRxns2)];  % distanc < opt Distance      
    
        % Construct the RHS vector
        LPproblem.b = [LPWT.b;LPDel.b;zeros(2*nCommon+2*nRxns1+2*nRxns2,1);objValWT;ceil(totalFluxDiff/tol)*tol];

        % Construct the objective (sum of all delta+ and delta-)
        LPproblem.c = [zeros(nWTVars+nDelVars+2*nCommon,1);ones(2*nRxns1+2*nRxns2,1)];

        % Construct the ub/lb
        % delta+ and delta- are in [0 10000]
        LPproblem.lb = [LPWT.lb;LPDel.lb;zeros(2*nCommon+2*nRxns1+2*nRxns2,1)];
        LPproblem.ub = [LPWT.ub;LPDel.ub;10000*ones(2*nCommon+2*nRxns1+2*nRxns2,1)];
        if (strcmp(osenseStr,'max'))
            csense = 'G';
        else
            csense = 'L';
        end
        
        LPproblem.csense = [LPWT.csense;LPDel.csense;repmat('G',2*nCommon+2*nRxns1+2*nRxns2,1);csense; 'L'];

        if (verbFlag)
            fprintf('Minimizing MOMA flux distribution norms: %d constraints %d variables ',size(A,1),size(A,2));
        end

        LPsolution = solveCobraLP(LPproblem);
        if (verbFlag)
            fprintf('%f seconds\n',LPsolution.time);
        end
        if (LPsolution.stat > 0)
            solutionDel.x = LPsolution.full((nWTVars+1):(nWTVars+nRxns2));
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
