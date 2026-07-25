function [rankMetConnectivity, rankMetInd, rankConnectivity] = rankMetabolicConnectivity(model, param)
% Rank the metabolites in a model by decreasing connectivity
%
% Connectivity is the number of reactions in which a metabolite participates,
% computed from the binary form of the stoichiometric matrix.
%
% USAGE:
%
%    [rankMetConnectivity, rankMetInd, rankConnectivity] = rankMetabolicConnectivity(model, param)
%
% INPUTS:
%    model:                  COBRA model structure with fields:
%
%                              * .S - `m x n` stoichiometric matrix
%                              * .mets - `m x 1` metabolite abbreviations
%                              * .SConsistentMetBool - `m x 1` true for stoichiometrically consistent metabolites
%                              * .SConsistentRxnBool - `n x 1` true for stoichiometrically consistent reactions
%
% OPTIONAL INPUT:
%    param:                  structure of parameters with fields:
%
%                              * .internal - {(1), 0} if only internal reaction connectivity is considered
%                              * .plot - {(1), 0} if plots are produced
%                              * .n - (10) number of top ranked metabolites to plot
%
% OUTPUTS:
%    rankMetConnectivity:    metabolite abbreviations by decreasing connectivity
%    rankMetInd:             rank ordered metabolite indices
%    rankConnectivity:       metabolite connectivity by decreasing connectivity

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

