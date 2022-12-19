function plotThermoKernelWeights(metWeights, rxnWeights, thermoModelMetBool, thermoModelRxnBool)
% plots weights on metabolites and reactions used by thermokernel
% -ve weight = incentive
%   0 weight = 
% +ve weight = disincentive
%
% If thermoModelMetBool and thermoModelRxnBool are also provided, it also plots the weigths 
% for the incentivised metabolites and reactions that were omitted from the output model
%
% IPUTS
%   metWeights:  - `m x 1` real valued vector weight on metabolites 
%   rxnWeights:  - `n x 1` real valued vector weight on reactions
%
% OPTIONAL INPUTS
%   thermoModelMetBool:   `m` x 1 boolean vector of thermodynamically consistent `mets` in input model
%   thermoModelRxnBool:   `n` x 1 boolean vector of thermodynamically consistent `rxns` in input model
%
%
% Ronan Fleming


[N,edges] = histcounts([rxnWeights;metWeights]);
figure;
hold on
[metN,metEdges] = histcounts(metWeights,edges);
[rxnN,rxnEdges] = histcounts(rxnWeights,edges);

if exist('thermoModelMetBool','var')
    [metN_omitted,metEdges_omitted] = histcounts(metWeights(~thermoModelMetBool & metWeights<0),edges);
    [rxnN_omitted,rxnEdges_omitted] = histcounts(rxnWeights(~thermoModelRxnBool & rxnWeights<0),edges);

    h=bar(metEdges(1:end-1),[metN;metN_omitted;rxnN;rxnN_omitted],'BarWidth',2.8,'FaceAlpha',0.5);
    h(1).FaceColor='red';
    h(2).FaceColor='green';
    h(3).FaceColor='blue';
    h(4).FaceColor='cyan';
    
    set(gca,'yscale','log')
    title('Incentivised(-ve), ambivalent(0), and penalised(+ve)','FontSize',12)
    txt = {[int2str(nnz(metWeights<0)) ' incentivised, ' int2str(nnz(metWeights==0)) ' unweighted, ' int2str(nnz(metWeights>0)) ' penalised metabolites'],...
        [int2str(nnz(rxnWeights<0)) ' incentivised, ' int2str(nnz(rxnWeights==0)) ' unweighted, ' int2str(nnz(rxnWeights>0)) ' penalised reactions']};
    subtitle(txt,'FontSize',12)
    legend({'metabolites','metabolites omitted', 'reactions', 'reactions omitted'},'Location','northwest','FontSize',12);
else
    h=bar(metEdges(1:end-1),[metN;rxnN],'BarWidth',2.8,'FaceAlpha',0.5);
    h(1).FaceColor='red';
    h(2).FaceColor='blue';
    set(gca,'yscale','log')
    title('Incentivised(-ve), ambivalent(0), and penalised(+ve)','FontSize',12)
    txt = {[int2str(nnz(metWeights<0)) ' incentivised, ' int2str(nnz(metWeights==0)) ' unweighted, ' int2str(nnz(metWeights>0)) ' penalised metabolites'],...
        [int2str(nnz(rxnWeights<0)) ' incentivised, ' int2str(nnz(rxnWeights==0)) ' unweighted, ' int2str(nnz(rxnWeights>0)) ' penalised reactions']};
    subtitle(txt,'FontSize',12)
    legend({'metabolites','reactions'},'Location','northwest','FontSize',12);
end

ylabel('Counts (log scale)','FontSize',12)
xlabel('ThermoKernel Weights','FontSize',12)
