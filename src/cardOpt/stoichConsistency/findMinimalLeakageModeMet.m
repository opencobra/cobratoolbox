function [minLeakMetBool,minLeakRxnBool,minSiphonMetBool,minSiphonRxnBool,leakY,siphonY,statp,statn] = findMinimalLeakageModeMet(model,metBool,rxnBool,modelBoundsFlag,params,printLevel)
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
% minLeakRxnBool        m x 1 boolean of metabolites in a positive leakage mode
% minLeakRxnBool        n x 1 boolean of reactions exclusively involved in a positive leakage mode
% minSiphonMetBool      m x 1 boolean of metabolites in a negative leakage mode
% minSiphonRxnBool      n x 1 boolean of reactions exclusively involved in a negative leakage mode
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
findSparseRxnSet=0;
if findSparseRxnSet
    cardProb.p       = nlt;
    cardProb.q       = 0;
    cardProb.r       = mlt;
else
    cardProb.p       = nlt+mlt;
    cardProb.q       = 0;
    cardProb.r       = 0;
end
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
siphonY=sparse(mlt,zlt);
minLeakRxnBool=logical(Vp);
minLeakMetBool=logical(siphonY);

%%Define the seminegative optimisation problem
cardPrbn=cardProb;
cardPrbn.A = [S speye(mlt)]; %note the positive on lhs of constraints
%preallocate for results
statn=ones(zlt,1)*NaN;
Vn=sparse(nlt,zlt);
leakY=sparse(mlt,zlt);
minSiphonRxnBool=logical(Vn);
minSiphonMetBool=logical(leakY);

%leak/siphon of only one metabolite if true
monoMetMode=params.monoMetMode;

if printLevel>0
    fprintf('%s\n','-------')
    if monoMetMode
        fprintf('%u%s\n',zlt,' rows of S to test for minimal leakage modes (one by one inconsistent added)...')
    else
        fprintf('%u%s\n',zlt,' rows of S to test for minimal leakage modes (all inconsistent in)...')
        
    end
end

%%
z=0;
warning off;
fprintf('%6s\t%6s\t%6s\t%6s\n','#mets','#rxns','result','metAbbr')
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
                if printLevel>1
                    fprintf('%6u%6u%6s%s\n',nnz(0),nnz(0),' no leak   ',model.mets{m});
                end
            case 1
                Vp(:,z)          = solution.x(1:nlt,1);
                minLeakRxnBool(:,z) = Vp(:,z)>=params.epsilon;
                if findSparseRxnSet
                    siphonY(:,z)          = solution.z(1:mlt,1);
                else
                    siphonY(:,z)          = solution.x(nlt+1:nlt+mlt,1);
                end
                minLeakMetBool(:,z) = siphonY(:,z)>=params.epsilon;
                
                if any(minLeakMetBool(:,z))
                    if printLevel>0
                        fprintf('%6u%6u%6s%s',nnz(minLeakMetBool(:,z)),nnz(minLeakRxnBool(:,z)),' leak    ',model.mets{m});
                    end
                    if printLevel>1
                        if nnz(minLeakRxnBool(:,z)) < 10
                            fprintf('%s%u%s',' ... which involves ',nnz(minLeakRxnBool(:,z)),' reactions:')
                        else
                            fprintf('%s%u%s',' it involves ',nnz(minLeakRxnBool(:,z)),' reactions (not displayed).')
                        end
                        fprintf('\n')
                    else
                        fprintf('\n')
                    end
                    if nnz(minLeakRxnBool(:,z))==1
                        formulas = printRxnFormula(model,model.rxns(minLeakRxnBool(:,z)));
                        fprintf('%g\t%s\n',full(Vp(minLeakRxnBool(:,z),z)),' flux value')
                    end
                    if printLevel>2
                        %relaxation of stoichiometric consistency for reactions above the
                        %threshold of leakParams.eta
                        siphonY(siphonY(:,z)<0,z)=0;
                        log10Yp=log10(siphonY(:,z));
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
                    else
                        if printLevel>1
                            fprintf('%6u%6u%6s%s\n',nnz(0),nnz(0),' no leak ',model.mets{m});
                        end
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
                    if printLevel>1
                        fprintf('%6u%6u%6s%s\n',nnz(0),nnz(0),' no siphon ',model.mets{m});
                    end
                case 1
                    Vn(:,z)            = solution.x(1:nlt,1);
                    minSiphonRxnBool(:,z) = Vn(:,z)>=params.epsilon;
                    if findSparseRxnSet
                        leakY(:,z)          = solution.z(1:mlt,1);
                    else
                        leakY(:,z)          = solution.x(nlt+1:nlt+mlt,1);
                    end
                    minSiphonMetBool(:,z) = leakY(:,z)>=params.epsilon;
                    
                    if any(minSiphonMetBool)
                        if printLevel>0
                            fprintf('%6u%6u%6s%s',nnz(minSiphonMetBool(:,z)),nnz(minSiphonRxnBool(:,z)),' siphon   ',model.mets{m});
                        end
                        if printLevel>1
                            if nnz(minSiphonRxnBool(:,z)) < 10
                                fprintf('\n%s%u%s',' which involves ',nnz(minSiphonRxnBool(:,z)),' reactions:')
                                formulas = printRxnFormula(model,model.rxns(minSiphonRxnBool(:,z)));
                            else
                                fprintf('%s%u%s',' which involves ',nnz(minSiphonRxnBool(:,z)),' reactions (not displayed).')
                            end
                            fprintf('\n')
                        else
                            fprintf('\n')
                        end
                        if printLevel>2
                            %relaxation of stoichiometric consistency for reactions above the
                            %threshold of leakParams.eta
                            leakY(leakY(:,z)<0,z)=0;
                            log10Yn=log10(leakY(:,z));
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
                        if printLevel>1
                            fprintf('%6u%6u%6s%s\n',nnz(0),nnz(0),' no siphon ',model.mets{m});
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