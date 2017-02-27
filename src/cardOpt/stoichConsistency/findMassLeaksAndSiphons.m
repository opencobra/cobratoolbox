function [leakMetBool,leakRxnBool,siphonMetBool,siphonRxnBool,leakY,siphonY,statp,statn] = findMassLeaksAndSiphons(model,metBool,rxnBool,modelBoundsFlag,params,printLevel)
% Find the metabolites in a network that either leak mass or act as a
% siphon for mass, with (default) or without the bounds on a model.
% The approach is to solve the problem
% max   ||y||_0
% s.t.  Sv - y = 0
% with either
%       l <= v <= u
% or
%      -inf <= v <= inf
% and with either
%       0 <= y <= inf   (semipositive net stoichiometry = leak)
% or
%       -inf <= y <= 0  (seminegative net stoichiometry = siphon)
%
% If there are any zero rows of S, then the corresponding entry in y is
% then set to zero.
%
% INPUT
% model                 (the following fields are required - others can be supplied)
%   .S                   m x n stoichiometric matrix
%
% OPTIONAL INPUT
% model
%   .lb                  Lower bounds
%   .ub                  Upper bounds
%   .SConsistentMetBool
%   .SConsistentRxnBool
% metBool               m x 1 boolean vector of metabolites to test for leakage
% rxnBool               n x 1 boolean vector of reactions to test for leakage
% modelBoundsFlag       {0,(1)}
%                       0 = set all reaction bounds to -inf, inf
%                       1 = use reaction bounds provided by model.lb and .ub
% params.epsilon        (1e-4)
% params.eta            (feasTol*100), smallest nonzero mass leak/siphon
% params.theta          (0.5) parameter of capped l1 approximation
% params.method         {('quasiConcave'),'dc'} method of approximation
% printLevel            {(0),1, 2 = debug}
%
% OUTPUT
% leakRxnBool       m x 1 boolean of metabolites in a positive leakage mode
% leakRxnBool       n x 1 boolean of reactions exclusively involved in a positive leakage mode
% siphonMetBool     m x 1 boolean of metabolites in a negative leakage mode
% siphonRxnBool     n x 1 boolean of reactions exclusively involved in a negative leakage mode
% leakY                 m x 1 boolean of metabolites in a positive leakage mode
% siphonY               m x 1 boolean of metabolites in a negative siphon mode
% statp             status (positive leakage modes)
%                       1 =  Solution found
%                       2 =  Unbounded
%                       0 =  Infeasible
%                      -1 =  Invalid input
% statn               status (negative leakage modes)
%                       1 =  Solution found
%                       2 =  Unbounded
%                       0 =  Infeasible
%                      -1 =  Invalid input

% Ronan Fleming Jan 2017

[nMet,nRxn]=size(model.S);

if ~exist('metBool','var')
    metBool=true(nMet,1);
else
    if ~islogical(metBool)
        error('metBool must be a logical vector')
    end
end
if ~exist('rxnBool','var')
    rxnBool=true(nRxn,1);
else
    if ~islogical(rxnBool)
        error('rxnBool must be a logical vector')
    end
end
if ~exist('modelBoundsFlag','var')
    modelBoundsFlag=0;
end
feasTol = getCobraSolverParams('LP', 'feasTol');
if ~exist('params','var') || isempty(params)
    params.theta   = 0.5;    %parameter of capped l1 approximation
    feasTol = getCobraSolverParams('LP', 'feasTol');
    params.epsilon=1e-4;
    params.eta=feasTol*100;
    %params.method = 'quasiConcave';
    params.method='dc';
else
    if isfield(params,'epsilon') == 0
        params.epsilon=1e-4;
    end
    if isfield(params,'eta') == 0
        params.eta=feasTol*100;
    end
    if isfield(params,'theta') == 0
        params.theta   = 0.5;    %parameter of capped l1 approximation
    end
    if isfield(params,'method') == 0
        %params.method   = 'quasiConcave';
        params.method='dc';
    end
end
if ~exist('printLevel','var')
    printLevel=0;
end

[theta,epsilon,method]=deal(params.theta,params.epsilon,params.method);

%take the subset of stoichiometry if need be
S=model.S(metBool,rxnBool);

%identify zero rows as they should not be leaking by default
zeroRows=~any(S,2);

[mlt,nlt]=size(S);

if modelBoundsFlag
    lb=model.lb(rxnBool);
    ub=model.ub(rxnBool);
    if printLevel>0
        fprintf('%6u\t%6u\t%s%s%s\n',mlt,nlt,' subset tested for leakage (', method,' method, with model flux bounds)...');
    end
else
    if 1
        %no bounds on fluxes
        lb=-inf*ones(nlt,1);
        ub= inf*ones(nlt,1);
    else
        lb=-(1/epsilon)*ones(nlt,1);
        ub= (1/epsilon)*ones(nlt,1);
    end
    if printLevel>0
        fprintf('%6u\t%6u\t%s%s%s\n',mlt,nlt,' subset tested for leakage (', method,' method, with infinite flux bounds)...');
    end
end

%method='quasiConcave';
%method='dc';
switch method
    case 'quasiConcave' %some reason this gives a more aggressive result than dc method, dont know why, possibly due to imbalance of protons.
        % Solve the linear problem
        %   max sum(z_i)
        %       s.t S*v + p      = 0
        %               - p + z <= 0
        %          lb <= v <= ub
        %           0 <= p <= inf %inf seems to help keep the problem feasible
        %           0 <= z <= epsilon
        LPproblem.A=[S              , speye(mlt), sparse(mlt,mlt);
                     sparse(mlt,nlt),-speye(mlt),      speye(mlt)];

        LPproblem.b=zeros(size(LPproblem.A,1),1);

        LPproblem.lb=[lb;            zeros(mlt,1); zeros(mlt,1)];
        LPproblem.ub=[ub; inf*ones(mlt,1);  epsilon*ones(mlt,1)];

        LPproblem.c=zeros(size(LPproblem.A,2),1);
        LPproblem.c(nlt+mlt+1:nlt+2*mlt,1)=1;%maximise z
        LPproblem.osense=-1;%maximisation
        LPproblem.csense(1:mlt,1)='E';
        LPproblem.csense(mlt+1:mlt+mlt,1)='L';

        solp = solveCobraLP(LPproblem,'printLevel',printLevel);
        if solp.stat == 1
            statp   = 1;
            Vp=sparse(nRxn,1);
            Vp(rxnBool) = solp.full(1:nlt);
            leakY=sparse(nMet,1);
            tmp = solp.full(nlt+1:nlt+mlt);
            tmp(zeroRows)=0;%ignore zero rows
            leakY(metBool) = tmp;
        else
            fprintf('%s\n','Infeasibility while detecting semipositive leaking metabolites.');
            Vp=[];
            leakY=[];
            statp=[];
        end

        % Solve the linear problem
        %   max sum(z_i)
        %       s.t S*v - p      = 0
        %               - p + z <= 0
        %          lb <= v <= ub
        %           0 <= p <= inf %inf seems to help keep the problem feasible
        %           0 <= z <= epsilon

        LPproblem_neg=LPproblem;
        LPproblem_neg.A=[S              , -speye(mlt), sparse(mlt,mlt);
                         sparse(mlt,nlt), -speye(mlt),      speye(mlt)];

        soln = solveCobraLP(LPproblem_neg,'printLevel',printLevel-1);

        if soln.stat == 1
            statn   = 1;
            Vn=sparse(nRxn,1);
            siphonY=sparse(nMet,1);
            Vn(rxnBool) = soln.full(1:nlt);
            tmp = soln.full(nlt+1:nlt+mlt);
            tmp(zeroRows)=0;%ignore zero rows
            siphonY(metBool) = tmp;
        else
            fprintf('%s\n','Infeasibility while detecting seminegative leaking metabolites.');
            Vn=[];
            siphonY=sparse(nMet,1);
            statn=[];
        end
    case 'dc'
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

        %Define the optimisation problem
        % [-I,S]*[y;z]=0
        cardPrb.p       = 0; %size of vector x
        cardPrb.q       = mlt; %size of vector y
        cardPrb.r       = nlt; %size of vector z
        cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
        cardPrb.lambda  = 0;
        cardPrb.delta   = 1;
        cardPrb.A       = [-speye(mlt) S];
        cardPrb.b       = zeros(mlt,1);
        cardPrb.csense  = repmat('E',mlt, 1);
        cardPrb.lb      = [zeros(mlt,1);lb];
        cardPrb.ub      = [(1/epsilon)*ones(mlt,1);ub];

        %Call the cardinality optimisation solver for semipositive
         solutionCardp = optimizeCardinality(cardPrb);
        if solutionCardp.stat == 1
            statp   = 1;
            Vp=sparse(nRxn,1);
            leakY=sparse(nMet,1);
            % [-I,S]*[y;z]=0
            % leakage
            tmp = solutionCardp.y;
            tmp(zeroRows)=0;%ignore zero rows
            leakY(metBool) = tmp;
            % flux
            Vp(rxnBool) = solutionCardp.z;
        else
            fprintf('%s\n','Infeasibility while detecting semipositive leaking metabolites.');
            Vp=[];
            leakY=sparse(nMet,1);
            statp=[];
        end

        %seminegative change matrix rather than bounds
        cardPrb.A       = [speye(mlt) S];
        %Call the cardinality optimisation solver
        solutionCardn = optimizeCardinality(cardPrb);

        if solutionCardn.stat == 1
            statn   = 1;
            Vn=sparse(nRxn,1);
            Vn(rxnBool) = solutionCardn.z;
            % [I,S]*[y;z]=0
            % siphon
            siphonY=sparse(nMet,1);
            tmp = solutionCardn.y;
            tmp(zeroRows)=0;%ignore zero rows
            siphonY(metBool) = tmp;
        else
            fprintf('%s\n','Infeasibility while detecting seminegative leaking metabolites.');
            Vn=[];
            siphonY=sparse(nMet,1);
            statn=[];
        end
end

%only metBool rxnBool were tested for leaks
leakMetBool=leakY>=params.eta;
leakRxnBool = getCorrespondingCols(model.S,leakMetBool,rxnBool,'exclusive');
if printLevel>0
    fprintf('%6u\t%6u\t%s\n',nnz(leakMetBool),nnz(leakRxnBool),' semipositive leaking metabolites (and exclusive reactions).')
end

if printLevel>0 && any(leakMetBool)
    %relaxation of stoichiometric consistency for reactions above the
    %threshold of leakParams.eta
    leakY(leakY<0)=0;
    log10Yp=log10(leakY);
    log10YpFinite=isfinite(log10Yp);
    if printLevel>2
        %histogram
        figure;
        hist(log10Yp(metBool & log10YpFinite),200)
        title(['Semipositive leaks above ' num2str(params.eta)])
        xlabel('log_{10}(leak)')
        ylabel('#mets')
    end
    [~,sortedlog10YpInd]=sort(log10Yp,'ascend');
    if printLevel>1
        for k=1:min(10,nnz(leakMetBool))
            mass=getMolecularMass(model.metFormulas{sortedlog10YpInd(k)});
            fprintf('%g\t%10s\n',mass,model.mets{sortedlog10YpInd(k)});
        end
    else
        for k=1:nnz(leakMetBool)
            mass=getMolecularMass(model.metFormulas{sortedlog10YpInd(k)});
            fprintf('%g\t%10s\n',mass,model.mets{sortedlog10YpInd(k)});
        end
    end
    if any(leakRxnBool)
        fprintf('%s\n','...')
    end
    for k=1:min(10,nnz(leakRxnBool))
        ind=find(leakRxnBool);
        fprintf('%s\n',model.rxns{ind(k)});
    end
end

siphonMetBool=siphonY>=params.eta;
siphonRxnBool = getCorrespondingCols(model.S,siphonMetBool,rxnBool,'exclusive');
if printLevel>0
    fprintf('%6u\t%6u\t%s\n',nnz(siphonMetBool),nnz(siphonRxnBool),' seminegative siphon metabolites (and exclusive reactions).');
end

if printLevel>0 && any(siphonMetBool)
    %relaxation of stoichiometric consistency for reactions above the
    %threshold of leakParams.eta
    siphonY(siphonY<0)=0;
    log10Yn=log10(siphonY);
    log10YnFinite=isfinite(log10Yn);
    if printLevel>2
        %histogram
        figure;
        hist(log10Yn(metBool & log10YnFinite),200)
        title(['Seminegative siphons above ' num2str(params.eta)])
        xlabel('log_{10}(siphon)')
        ylabel('#mets')
    end
    [~,sortedlog10YnInd]=sort(log10Yn,'ascend');
    if printLevel>1
        for k=1:min(10,nnz(siphonMetBool))
            mass=getMolecularMass(model.metFormulas{sortedlog10YnInd(k)});
            fprintf('%g\t%10s\n',mass,model.mets{sortedlog10YnInd(k)});
        end
    else
        for k=1:nnz(siphonMetBool)
            mass=getMolecularMass(model.metFormulas{sortedlog10YnInd(k)});
            fprintf('%g\t%10s\n',mass,model.mets{sortedlog10YnInd(k)});
        end
    end
    if any(siphonRxnBool)
        fprintf('%s\n','...')
    end
    for k=1:min(10,nnz(siphonRxnBool))
        ind=find(siphonRxnBool);
        fprintf('%s\n',model.rxns{ind(k)});
    end
end
