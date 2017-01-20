function [Vp,Yp,statp,Vn,Yn,statn] = findMinimalLeakageMode(model,metBool,modelBoundsFlag,epsilon,printLevel)
% Solve the problem
% min   ||v||_0 + ||y||_0
% s.t.  Sv - y = 0
%       l <= v <= u
% with either
%       0 <= y      (semipositive net stoichiometry)
% or 
%            y <= 0 (seminegative net stoichiometry)
%
% INPUT
% model                 (the following fields are required - others can be supplied)
%   .S                   m x n stoichiometric matrix
%   .lb                  Lower bounds
%   .ub                  Upper bounds
%
% OPTIONAL INPUT
% model
%   .SConsistentMetBool
%   .SConsistentRxnBool
% metBool               m x 1 boolean vector of metabolites to test for
%                       leakage
% modelBoundsFlag       {0,(1)} 
%                       0 = set all reaction bounds to -inf, inf
%                       1 = use reaction bounds provided by model.lb and .ub
% epsilon                1e-4, smallest nonzero reaction flux in leakage mode   
% printLevel             {(0),1}
%
% OUTPUT
%       Vp                  n x 1 vector (positive leakage modes)
%       Yp                  m x 1 vector (positive leakage modes)
%       statp               status (positive leakage modes)
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
%       Vn                  n x 1 vector (negative leakage modes)
%       Yn                  m x 1 vector (negative leakage modes)
%       statn               status (negative leakage modes)
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
%
% Ines Thiele & Ronan Fleming June 2016

[S,lb,ub] = deal(model.S,model.lb,model.ub);
[mlt,nlt]=size(S);

if ~exist('metBool','var')
    if ~isfield(model,'SConsistentMetBool')
        metBool=true(mlt,1);
    else
        metBool=~model.SConsistentMetBool;
        if length(metBool)~=mlt
            error('model.SConsistentMetBool the wrong dimension')
        end
    end
end
if ~isfield(model,'SConsistentRxnBool')
    SConsistentRxnBool=false(nlt,1);
else
    SConsistentRxnBool=model.SConsistentRxnBool;
    if length(SConsistentRxnBool)~=nlt
        error('SConsistentRxnBool the wrong dimension')
    end
end
if ~exist('modelBoundsFlag','var')
    modelBoundsFlag = 1;
end
if ~exist('epsilon','var')
    epsilon = 1e-6;
end
if ~exist('printLevel','var')
    printLevel = 0;
end

%%Define the semipositive optimisation problem
cardPrb.p       = nlt+mlt;
cardPrb.q       = 0;
cardPrb.r       = 0;
cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
cardPrb.lambda  = 1;
cardPrb.delta   = 0;
cardPrb.b       = zeros(mlt,1);
cardPrb.csense  = repmat('E',mlt, 1);
%semipositive
cardPrb.A       = [S -speye(mlt)];
if ~modelBoundsFlag
    %set all reactions to reversible
    cardPrb.lb      = [-inf*ones(nlt,1);zeros(mlt,1)];
    cardPrb.ub      = inf*ones(nlt+mlt,1);
else
    %use the model bounds for the reactions
    cardPrb.lb      = [lb;zeros(mlt,1)];
    cardPrb.ub      = [ub;inf*ones(mlt,1)];
end
%all known stoichiometrically inconsistent reactions set to zero
cardPrb.lb(~SConsistentRxnBool)=0;
cardPrb.ub(~SConsistentRxnBool)=0;

%preallocate for results
zlt=nnz(metBool);
statp=ones(zlt,1)*NaN;
Vp=sparse(nlt,zlt);
Yp=sparse(mlt,zlt);

%%Define the seminegative optimisation problem
cardPrbn=cardPrb;
cardPrbn.A = [S speye(mlt)]; %note the positive on lhs of constraints
%preallocate for results
statn=ones(zlt,1)*NaN;
Vn=sparse(nlt,zlt);
Yn=sparse(mlt,zlt);

if printLevel>0
    fprintf('%u%s\n',zlt,' rows of S to test for minimal leakage modes...')
end
    
%%
fhandle=fopen('leakages.txt');
z=0;
warning off;
for m=1:mlt
    if metBool(m)
        %initially plan to test both positive and negative, but if positive
        %mode exists then dont compute negative
        trySemiNegativeLeakageMode=1;
        %increment index for results
        z=z+1;
        
        %set a positive lower bound on one stoichiometrically inconsistent metabolite
        oldlb=cardPrb.lb(nlt+m);
        cardPrb.lb(nlt+m)=1;
        %Call the cardinality optimisation solver
        solution = optimizeCardinality(cardPrb);
        %fetch the solution
        statp(z)   = solution.stat;
        switch solution.stat
            case 0
                if printLevel>2
                    fprintf('%s%s\n',model.mets{m},' has no semipositive leakage mode.')
                end
            case 1
                Vp(:,z)     = solution.x(1:nlt,1);
                Yp(:,z)     = solution.x(nlt+1:nlt+mlt,1);
                if printLevel>0
                    fprintf('%s%s',model.mets{m},' has a minimal semipositive leakage mode,')
                    bool=abs(Vp(:,z))>=epsilon;
                    if printLevel>1
                        if nnz(bool) < 10
                            fprintf('%s%u%s',' which involves ',nnz(bool),' reactions:')
                            formulas = printRxnFormula(model,model.rxns(bool));
                        else
                            fprintf('%s%u%s',' it involves ',nnz(bool),' reactions (not displayed).')
                        end
                        fprintf('\n')
                    else
                        fprintf('%s%u%s\n',' which involves ',nnz(bool),' reactions (not displayed).')
                    end
                end
                %no need to find semi negative leakage mode
                trySemiNegativeLeakageMode=0;
            case 2
                warning([model.mets{m} ': Problem unbounded !!!!!']);
        end
        %reset the bound
        cardPrb.lb(nlt+m)=oldlb;
        
        if trySemiNegativeLeakageMode
            %set a positive lower bound on one stoichiometrically inconsistent metabolite
            oldlb=cardPrbn.lb(nlt+m);
            cardPrbn.lb(nlt+m)=1;
            %Call the cardinality optimisation solver
            solution = optimizeCardinality(cardPrbn);
            %fetch the solution
            statn(z)   = solution.stat;
            switch solution.stat
                case 0
                    if printLevel>2
                        fprintf('%s%s\n',model.mets{m},' has no seminegative leakage mode.')
                    end
                case 1
                    Vn(:,z)     = solution.x(1:nlt,1);
                    Yn(:,z)     = solution.x(nlt+1:nlt+mlt,1);
                    if printLevel>0
                        fprintf('%s%s',model.mets{m},' has a minimal seminegative leakage mode,')
                        bool=abs(Vn(:,z))>=epsilon;
                        if printLevel>1
                            if nnz(bool) < 10
                                fprintf('%s%u%s',' which involves ',nnz(bool),' reactions:')
                                formulas = printRxnFormula(model,model.rxns(bool));
                            else
                                fprintf('%s%u%s',' which involves ',nnz(bool),' reactions (not displayed).')
                            end
                            fprintf('\n')
                        else
                            fprintf('%s%u%s\n',' which involves ',nnz(bool),' reactions (not displayed).')
                        end
                    end
                case 2
                    warning([model.mets{m} ': Problem unbounded !!!!!']);
            end
            %reset the bound
            cardPrbn.lb(nlt+m)=oldlb;
        end
    end
end
warning on;