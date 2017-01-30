function [minLeakMetBool,minLeakRxnBool,minSiphonMetBool,minSiphonRxnBool,rxnAbbr,statp,statn] = findMinimalLeakageModeRxn(model,rxnBool,metBool,modelBoundsFlag,params,printLevel)
% Solve the problem
% min   ||v||_0 + ||y||_0
% s.t.  Sv - y = 0
%       l <= v <= u  % either l(rxnBool)>0 or u(rxnBool)<0
% with either
%       0 <= v(rxnBool) 
% or
%            v(rxnBool) <= 0 
% and
%       1 <= y(metBool)      (semipositive net stoichiometry)
% or
%            y(metBool) <= 1 (seminegative net stoichiometry)
% INPUT
% model                 (the following fields are required - others can be supplied)
%   .S                   m x n stoichiometric matrix
%   .lb                  Lower bounds
%   .ub                  Upper bounds
% rxnBool               n x 1 boolean vector of reactions to give non-zero
%                       flux in order to  test for leakage
%
% OPTIONAL INPUT
% model
%   .SConsistentMetBool
%   .SConsistentRxnBool
% metBool               m x 1 boolean vector of metatbolites to involve in
%                       test for leakage
% modelBoundsFlag       {0,(1)}
%                       0 = set all reaction bounds to -inf, inf
%                       1 = use reaction bounds provided by model.lb and .ub
% params.eta           (feasTol*100), smallest nonzero mass/flux for leak/siphon
% params.monoRxnMode   {(1),0}, adds one stoichiometrically inconsistent
%                       reaction at a time
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
%set parameters according to feastol
feasTol = getCobraSolverParams('LP', 'feasTol');

if ~exist('metBool','var')
    %involve all metabolites unless otherwise specified
    metBool=true(mlt,1);
else
    if length(metBool)~=mlt
        error('model.SConsistentMetBool the wrong dimension')
    end
end
if ~islogical(metBool)
    error('metBool must be a logical vector')
end

if ~exist('rxnBool','var')
    if ~isfield(model,'SConsistentRxnBool')
        rxnBool=true(nlt,1);
    else
        rxnBool=~model.SConsistentRxnBool & ~model.SIntRxnBool;
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

if ~exist('params','var') || isempty(params)
    params.eta=feasTol*100;
    params.eta=feasTol*100;
else
    if isfield(params,'epsilon') == 0
        params.eta=feasTol*100;
    end
end

if ~exist('printLevel','var')
    printLevel = 0;
end

if isfield(params,'eta') == 0
    params.eta=feasTol*100;
end

if isfield(params,'monoRxnMode') == 0
    params.monoRxnMode=1;
end

%%Define the semipositive optimisation problem
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

if modelBoundsFlag
    % bounds on exchange reactions set to zero
    lb(~model.SIntRxnBool)=0;
    ub(~model.SIntRxnBool)=0;
    if params.monoRxnMode
        % bounds on internal reactions that are either inconsistent or of unknown constency are set to zero
        lb(model.SIntRxnBool & ~model.SConsistentRxnBool)=0;
        ub(model.SIntRxnBool & ~model.SConsistentRxnBool)=0;
    end
    %use the model bounds for the reactions
    cardProb.lb      = [lb;zeros(mlt,1)];
    cardProb.ub      = [ub;inf*ones(mlt,1)];
else
    %set all reactions to reversible
    cardProb.lb      = [-inf*ones(nlt,1);zeros(mlt,1)];
    cardProb.ub      = inf*ones(nlt+mlt,1);
end

%working through reactions
rxnAbbr=model.rxns{rxnBool};

%preallocate for results
zlt=nnz(rxnBool);
statp=ones(zlt,1)*NaN;
Vp=sparse(nlt,zlt);
Yp=sparse(mlt,zlt);
minLeakRxnBool=logical(Vp);
minLeakMetBool=logical(Yp);

%%Define the seminegative optimisation problem
cardProbn=cardProb;
cardProbn.A = [S speye(mlt)]; %note the positive on lhs of constraints
%preallocate for results
statn=ones(zlt,1)*NaN;
Vn=sparse(nlt,zlt);
Yn=sparse(mlt,zlt);
minSiphonRxnBool=logical(Vn);
minSiphonMetBool=logical(Yn);

if printLevel>0
    fprintf('%s\n','-------')
    fprintf('%u%s\n',zlt,' reactions to test for minimal leakage modes...')
    
end

%%
z=0;
warning off;
fprintf('%6s\t%6s\t%6s\t%15s\t%6s\t%6s\t%6s\t%6s\n','#mets','#rxns','mode','rxnAbbr','lb','ub','newlb','newub')
for n=1:nlt
    if rxnBool(n)
        %initially plan to test both positive and negative, but if positive
        %mode exists then dont compute negative
        trySemiNegativeLeakageMode=1;
        %increment index for results
        z=z+1;
        
        %set a positive lower bound on one stoichiometrically inconsistent metabolite
        oldlb=lb(n);
        oldub=ub(n);
        if lb(n)>=0 && ub(n)>0
            %force reaction forward
            cardProb.lb(n)=1;
            cardProb.ub(n)=cardProb.ub(n)+1;
        else
            if lb(n)<0 && ub(n)<=0
                %force reaction reverse
                cardProb.lb(n)=cardProb.lb(n)-1;
                cardProb.ub(n)=-1;
            else
                if lb(n)==0 && ub(n)==0
                    %force reaction forward
                    cardProb.lb(n)=1;
                    cardProb.ub(n)=cardProb.lb(n)+1;
                else
                    if lb(n)<=0 && ub(n)>=0
                        %force reaction forward
                        cardProb.lb(n)=1;
                        cardProb.ub(n)=cardProb.ub(n)+1;
                    else
                        fprintf('%6u\t%6u\t%6s\t%15s\t%6g\t%6g\t%6g\t%6g\n',NaN,NaN,'-',model.rxns{n},model.lb(n),model.ub(n),cardProb.lb(n),cardProb.ub(n));
                        error('direction wierd')
                    end
                end
            end
        end
        %Call the cardinality optimisation solver
        solution = optimizeCardinality(cardProb);
        %fetch the solution
        statp(z)   = solution.stat;
        switch solution.stat
            case 0
                if printLevel>2
                    fprintf('%s%s\n',model.mets{n},' has no semipositive leakage mode.')
                end
            case 1
                Vp(:,z)          = solution.x(1:nlt,1);
                minLeakRxnBool(:,z) = Vp(:,z)>=params.eta;
                Yp(:,z)          = solution.x(nlt+1:nlt+mlt,1);
                minLeakMetBool(:,z) = Yp(:,z)>=params.eta;
                
                if printLevel>0
                    fprintf('%6u\t%6u\t%6s\t%15s\t%6g\t%6g\t%6g\t%6g\n',nnz(minLeakMetBool(:,z)),nnz(minLeakRxnBool(:,z)),'leak',model.rxns{n},lb(n),ub(n),cardProb.lb(n),cardProb.ub(n));
                end
                if nnz(minLeakRxnBool(:,z))==1
                    formulas = printRxnFormula(model,model.rxns(minLeakRxnBool(:,z)));
                    fprintf('%g\t%s\n',full(Vp(minLeakRxnBool(:,z),z)),' flux value')
                end
                
                if printLevel>1
                    if nnz(minLeakRxnBool(:,z)) < 10
                        formulas = printRxnFormula(model,model.rxns(minLeakRxnBool(:,z)));
                    end
                end
                
                if printLevel>2 && any(minLeakMetBool(:,z))
                    %relaxation of stoichiometric consistency for reactions above the
                    %threshold of leakParams.eta
                    Yp(Yp(:,z)<0,z)=0;
                    log10Yp=log10(Yp(:,z));
                    log10YpFinite=isfinite(log10Yp);
                    if printLevel>2
                        %histogram
                        figure;
                        hist(log10Yp(metBool & log10YpFinite),200)
                        title(['Semipositive leaks above ' num2str(params.eta)])
                        xlabel('log_{10}(leak)')
                        ylabel('#mets')
                    end
                    [~,sortedlog10YpInd]=sort(log10Yp,'descend');
                    for k=1:min(13,nnz(minLeakMetBool(:,z)))
                        fprintf('%s\n',model.mets{sortedlog10YpInd(k)});
                    end
                    for k=1:min(10,nnz(minLeakRxnBool(:,z)))
                        ind=find(minLeakRxnBool(:,z));
                        fprintf('%s\n',model.rxns{ind(k)});
                    end
                end
                %find minimal semi negative leakage mode also
                trySemiNegativeLeakageMode=1;
            case 2
                warning([model.mets{n} ': Problem unbounded !!!!!']);
        end
        %reset the bound
        cardProb.lb(n)=oldlb;
        cardProb.ub(n)=oldub;
        
        if trySemiNegativeLeakageMode
            %set a positive lower bound on one stoichiometrically inconsistent metabolite
            oldlb=lb(n);
            oldub=ub(n);
            
            if lb(n)>=0 && ub(n)>0
                %force reaction forward
                cardProbn.lb(n)=1;
                cardProbn.ub(n)=cardProbn.ub(n)+1;
            else
                if lb(n)<0 && ub(n)<=0
                    %force reaction reverse
                    cardProbn.lb(n)=cardProbn.lb(n)-1;
                    cardProbn.ub(n)=-1;
                else
                    if lb(n)==0 && ub(n)==0
                        %force reaction forward
                        cardProbn.lb(n)=1;
                        cardProbn.ub(n)=cardProbn.ub(n)+1;
                    else
                        if lb(n)<=0 && ub(n)>=0
                            %force reaction forward
                            cardProbn.lb(n)=1;
                            cardProbn.ub(n)=cardProbn.ub(n)+1;
                        else
                            fprintf('%6u\t%6u\t%6s\t%15s\t%6g\t%6g\t%6g\t%6g\n',NaN,NaN,'-',model.rxns{n},lb(n),ub(n),cardProbn.lb(n),cardProbn.ub(n));
                            error('direction wierd')
                        end
                    end
                end
            end
            
            %Call the cardinality optimisation solver
            solution = optimizeCardinality(cardProbn);
            %fetch the solution
            statn(z)   = solution.stat;
            switch solution.stat
                case 0
                    if printLevel>2
                        fprintf('%s%s\n',model.rxns{n},' has no seminegative leakage mode.')
                    end
                case 1
                    Vn(:,z)            = solution.x(1:nlt,1);
                    minSiphonRxnBool(:,z) = Vn(:,z)>=params.eta;
                    Yn(:,z)            = solution.x(nlt+1:nlt+mlt,1);
                    minSiphonMetBool(:,z) = Yn(:,z)>=params.eta;
                    
                    if printLevel>0
                        fprintf('%6u\t%6u\t%6s\t%15s\t%6g\t%6g\t%6g\t%6g\n',nnz(minSiphonMetBool(:,z)),nnz(minSiphonRxnBool(:,z)),'siphon',model.rxns{n},lb(n),ub(n),cardProbn.lb(n),cardProbn.ub(n));
                    end
                    if printLevel>1
                        if nnz(minSiphonRxnBool(:,z)) < 10
                            formulas = printRxnFormula(model,model.rxns(minSiphonRxnBool(:,z)));
                        end
                    end
                    
                    if printLevel>2 && any(minSiphonMetBool(:,z))
                        %relaxation of stoichiometric consistency for reactions above the
                        %threshold of leakParams.eta
                        Yn(Yn(:,z)<0,z)=0;
                        log10Yn=log10(Yn(:,z));
                        log10YnFinite=isfinite(log10Yn);
                        if printLevel>2
                            %histogram
                            figure;
                            hist(log10Yn(metBool & log10YnFinite),200)
                            title(['Semipositive siphons above ' num2str(params.eta)])
                            xlabel('log_{10}(siphon)')
                            ylabel('#mets')
                        end
                        [~,sortedlog10YnInd]=sort(log10Yn,'descend');
                        for k=1:min(13,nnz(minSiphonMetBool(:,z)))
                            fprintf('%s\n',model.rxns{sortedlog10YnInd(k)});
                        end
                        for k=1:min(10,nnz(minSiphonRxnBool(:,z)))
                            ind=find(minSiphonRxnBool(:,z));
                            fprintf('%s\n',model.rxns{ind(k)});
                        end
                    end
                case 2
                    warning([model.rxns{n} ': Problem unbounded !!!!!']);
            end
            %reset the bound
            cardProbn.lb(n)=oldlb;
            cardProbn.ub(n)=oldub;
        end
    end
end


