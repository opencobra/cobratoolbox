function [minLeakMetBool,minLeakRxnBool,minSiphonMetBool,minSiphonRxnBool,metAbbr,statp,statn] = findMinimalLeakageModeMet(model,metBool,rxnBool,modelBoundsFlag,params,printLevel)
% Solve the problem
% min   ||v||_0 + ||y||_0
% s.t.  Sv - y = 0
%       l <= v <= u  % either l(rxnBool)>0 or u(rxnBool)<0
% with either
%       0 <= y      (semipositive net stoichiometry)
% or 
%            y <= 0 (seminegative net stoichiometry)
% and
%       1 <= y(metBool)      (semipositive net stoichiometry)
% or 
%            y(metBool) <= 1 (seminegative net stoichiometry)
% INPUT
% model                 (the following fields are required - others can be supplied)
%   .S                   m x n stoichiometric matrix
%   .lb                  Lower bounds
%   .ub                  Upper bounds
% metBool               m x 1 boolean vector of metabolites to test for
%                       leakage
%
% OPTIONAL INPUT
% model
%   .SConsistentMetBool
%   .SConsistentRxnBool
% rxnBool               n x 1 boolean vector of reactions to involve in
%                       test for leakage
% modelBoundsFlag       {0,(1)} 
%                       0 = set all reaction bounds to -inf, inf
%                       1 = use reaction bounds provided by model.lb and .ub
% params.epsilon        (feasTol*100), smallest nonzero mass leak/siphon
% params.monoMetMode    {(0),1} boolean to test for leakage of only one metabolite    
% printLevel            {(0),1}
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
if ~islogical(metBool)
        error('metBool must be a logical vector')
end

if ~exist('rxnBool','var')
    if ~isfield(model,'SConsistentRxnBool')
        rxnBool=true(nlt,1);
    else
        rxnBool=~model.SConsistentRxnBool;
        if length(rxnBool)~=nlt
            error('model.SConsistentRxnBool the wrong dimension')
        end
    end
end
if ~islogical(rxnBool)
        error('rxnBool must be a logical vector')
end

if ~exist('modelBoundsFlag','var')
    modelBoundsFlag = 1;
end

feasTol = getCobraSolverParams('LP', 'feasTol');
if ~exist('params','var') || isempty(params)
    params.epsilon=feasTol*100;
else
    if isfield(params,'epsilon') == 0
        params.epsilon=feasTol*100;
    end
end

if isfield(params,'monoMetMode') == 0
    params.monoMetMode=0;
end

if ~exist('printLevel','var')
    printLevel = 0;
end

% ~rxnBool bounds set to zero
lb(~rxnBool)=0;
ub(~rxnBool)=0;

%%Define the semipositive optimisation problem
% min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
% s.t.      A*(x,y,z) <= b
%           l <= (x,y,z) <=u
%           x in R^p, y in R^q, z in R^r
cardProb.p       = nlt+mlt;
cardProb.q       = 0;
cardProb.r       = 0;
cardProb.c       = zeros(cardProb.p+cardProb.q+cardProb.r,1);
cardProb.lambda  = 1;
cardProb.delta   = 0;
cardProb.b       = zeros(mlt,1);
cardProb.csense  = repmat('E',mlt, 1);
%semipositive
cardProb.A       = [S -speye(mlt)];
if ~modelBoundsFlag
    %set all reactions to reversible
    cardProb.lb      = [-inf*ones(nlt,1);zeros(mlt,1)];
    cardProb.ub      = inf*ones(nlt+mlt,1);
else
    %use the model bounds for the reactions
    cardProb.lb      = [lb;zeros(mlt,1)];
    cardProb.ub      = [ub;inf*ones(mlt,1)];
end

%working through metabolites
metAbbr=model.mets{metBool};

%preallocate for results
zlt=nnz(metBool);
statp=ones(zlt,1)*NaN;
Vp=sparse(nlt,zlt);
Yp=sparse(mlt,zlt);
minLeakRxnBool=logical(Vp);
minLeakMetBool=logical(Yp);

%%Define the seminegative optimisation problem
cardPrbn=cardProb;
cardPrbn.A = [S speye(mlt)]; %note the positive on lhs of constraints
%preallocate for results
statn=ones(zlt,1)*NaN;
Vn=sparse(nlt,zlt);
Yn=sparse(mlt,zlt);
minSiphonRxnBool=logical(Vn);
minSiphonMetBool=logical(Yn);

%leak/siphon of only one metabolite if true
monoMetMode=params.monoMetMode;

if printLevel>0
    fprintf('%s\n','-------')
    if monoMetMode
        fprintf('%u%s\n',zlt,' rows of S to test for minimal leakage modes...')
    else
        fprintf('%u%s\n',zlt,' rows of S to test for minimal leakage modes...')

    end
end

%%
z=0;
warning off;
fprintf('%6s\t%6s\t%6s\t%6s\n','#mets','#rxns','mode','metAbbr')
for m=1:mlt
    if metBool(m)
        %initially plan to test both positive and negative, but if positive
        %mode exists then dont compute negative
        trySemiNegativeLeakageMode=1;
        %increment index for results
        z=z+1;
        
        %set a positive lower bound on one stoichiometrically inconsistent metabolite
        oldlb=cardProb.lb(nlt+m);
        cardProb.lb(nlt+m)=1;
        if monoMetMode
            d=zeros(mlt,1);
            d(m,1)=-1;
            cardProb.A=[S spdiags(d,0,mlt,mlt)];
        end
        %Call the cardinality optimisation solver
        solution = optimizeCardinality(cardProb);
        %fetch the solution
        statp(z)   = solution.stat;
        switch solution.stat
            case 0
                if printLevel>2
                    fprintf('%s%s\n',model.mets{m},' has no semipositive leakage mode.')
                end
            case 1
                Vp(:,z)          = solution.x(1:nlt,1);
                minLeakRxnBool(:,z) = Vp(:,z)>=params.epsilon;
                Yp(:,z)          = solution.x(nlt+1:nlt+mlt,1);
                minLeakMetBool(:,z) = Yp(:,z)>=params.epsilon;
                
                if printLevel>0
                    fprintf('%6u\t%6u\t%6s\t%s\n',nnz(minLeakMetBool(:,z)),nnz(minLeakRxnBool(:,z)),'leak',model.mets{m});
                end
                if nnz(minLeakRxnBool(:,z))==1
                     formulas = printRxnFormula(model,model.rxns(minLeakRxnBool(:,z)));
                     fprintf('%g\t%s\n',full(Vp(minLeakRxnBool(:,z),z)),' flux value')
                end
                            
                if printLevel>2 
                    if nnz(minLeakRxnBool(:,z)) < 10
                        fprintf('%s%u%s',' ... which involves ',nnz(minLeakRxnBool(:,z)),' reactions:')
                    else
                        fprintf('%s%u%s',' it involves ',nnz(minLeakRxnBool(:,z)),' reactions (not displayed).')
                    end
                    fprintf('\n')
                end
                
                if printLevel>1 && any(minLeakMetBool(:,z))
                    %relaxation of stoichiometric consistency for reactions above the
                    %threshold of leakParams.eta
                    Yp(Yp(:,z)<0,z)=0;
                    log10Yp=log10(Yp(:,z));
                    log10YpFinite=isfinite(log10Yp);
                    if printLevel>2
                        %histogram
                        figure;
                        hist(log10Yp(metBool & log10YpFinite),200)
                        title(['Semipositive leaks above ' num2str(params.epsilon)])
                        xlabel('log_{10}(leak)')
                        ylabel('#mets')
                    end
                    [~,sortedlog10YpInd]=sort(log10Yp,'descend');
                    for k=1:min(13,nnz(minLeakMetBool(:,z)))
                        fprintf('%s\n',model.mets{sortedlog10YpInd(k)});
                    end
                    if any(minLeakRxnBool(:,z))
                        fprintf('%s\n','...')
                    end
                    for k=1:min(10,nnz(minLeakRxnBool(:,z)))
                        ind=find(minLeakRxnBool(:,z));
                        fprintf('%s\n',model.rxns{ind(k)});
                    end
                end
                %no need to find semi negative leakage mode
                trySemiNegativeLeakageMode=1;
            case 2
                warning([model.mets{m} ': Problem unbounded !!!!!']);
        end
        %reset the bound
        cardProb.lb(nlt+m)=oldlb;
        
        if trySemiNegativeLeakageMode
            %set a positive lower bound on one stoichiometrically inconsistent metabolite
            oldlb=cardPrbn.lb(nlt+m);
            cardPrbn.lb(nlt+m)=1;
            if monoMetMode
                d=zeros(mlt,1);
                d(m,1)=1;
                cardPrbn.A=[S spdiags(d,0,mlt,mlt)];
            end
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
                    Vn(:,z)            = solution.x(1:nlt,1);
                    minSiphonRxnBool(:,z) = Vn(:,z)>=params.epsilon;
                    Yn(:,z)            = solution.x(nlt+1:nlt+mlt,1);
                    minSiphonMetBool(:,z) = Yn(:,z)>=params.epsilon;

                    if printLevel>0
                        fprintf('%6u\t%6u\t%6s\t%s\n',nnz(minSiphonMetBool(:,z)),nnz(minSiphonRxnBool(:,z)),'siphon',model.mets{m});
                    end
                    if printLevel>2
                        if nnz(minSiphonRxnBool(:,z)) < 10
                            fprintf('%s%u%s',' which involves ',nnz(minSiphonRxnBool(:,z)),' reactions:')
                            formulas = printRxnFormula(model,model.rxns(minSiphonRxnBool(:,z)));
                        else
                            fprintf('%s%u%s',' it involves ',nnz(minSiphonRxnBool(:,z)),' reactions (not displayed).')
                        end
                        fprintf('\n')
                    end

                    if printLevel>1 && any(minSiphonMetBool)
                        %relaxation of stoichiometric consistency for reactions above the
                        %threshold of leakParams.eta
                        Yn(Yn(:,z)<0,z)=0;
                        log10Yn=log10(Yn(:,z));
                        log10YnFinite=isfinite(log10Yn);
                        if printLevel>2
                            %histogram
                            figure;
                            hist(log10Yn(metBool & log10YnFinite),200)
                            title(['Semipositive siphons above ' num2str(params.epsilon)])
                            xlabel('log_{10}(siphon)')
                            ylabel('#mets')
                        end
                        [~,sortedlog10YnInd]=sort(log10Yn,'descend');
                        for k=1:min(13,nnz(minSiphonMetBool))
                            fprintf('%s\n',model.mets{sortedlog10YnInd(k)});
                        end
                        if any(minSiphonRxnBool)
                            fprintf('%s\n','...')
                        end
                        for k=1:min(10,nnz(minSiphonRxnBool))
                            ind=find(minSiphonRxnBool);
                            fprintf('%s\n',model.rxns{ind(k)});
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