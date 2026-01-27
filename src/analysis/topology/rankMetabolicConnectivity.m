function [rankMetConnectivity,rankMetInd,rankConnectivity] = rankMetabolicConnectivity(model,param)
%metabolite connectivity in a model
%
% INPUT
% model
%
% OUTPUT
% rankMetConnectivity  metabolite abbreviations by decreasing connectivity
% rankMetInd           rank ordered metabolite indices
% rankConnectivity     metabolite connectivity by decreasing connectivity 
%
% OPTIONAL INPUT
% param.internal    {(1),0} if only internal reaction connectivity is
%                   considered
% param.plot        {(1),0} if plots produces
% param.n           (10) number of top ranked metabolites to plot

if ~exist('param','var')
    param=struct;
end

if ~isfield(param,'internal')
    param.internal=1;
end

if ~isfield(param,'n')
    param.n=10;
end

if ~isfield(param,'plot')
    param.plot=1;
end

if param.internal
    if ~isfield(model,'SConsistentRxnBool')
        massBalanceCheck=1;
        printLevel=1;
        [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model]...
            = findStoichConsistentSubset(model,massBalanceCheck,printLevel);
        N=model.S(SConsistentMetBool,SConsistentRxnBool)~=0;
        %ignore stoichiometrically inconsistent metabolites
        N(~SConsistentMetBool,:)=0;
    else
        N=model.S(:,model.SConsistentRxnBool)~=0;
        %ignore stoichiometrically inconsistent metabolites
        N(~model.SConsistentMetBool,:)=0;
    end
else
    N=model.S~=0;
end

A = N*N';
a = diag(A);
[rankConnectivity,rankMetInd]=sort(a,'descend');

rankMetConnectivity = model.mets(rankMetInd);

if param.plot==1
    if 0
        figure
        plot(log10(rankConnectivity),'.')
        xlabel('metabolites')
        ylabel('log10(connectivity)')
    end
    
    n=20;
    %ind=1:round((n/100)*size(N,1));
    ind=1:min(param.n,length(rankConnectivity));
    figure
    plot(log10(rankConnectivity(ind)),'*')
    xlabel('metabolites')
     ylabel('log10(connectivity)')
    xticklabels(model.mets(rankMetInd(ind)))
    xticks(ind)
    xtickangle(45)
end

end

