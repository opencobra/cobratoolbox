function plotHistConv(model,samples,rxnNames,nSubSamples)
%Plots convergence of sample histograms
%
% USAGE:
%
%    plotHistConv(model, samples, rxnNames, nSubSamples)
%
% INPUTS:
%    model:         COBRA model structure
%    samples:       Sample fluxes
%    rxnNames:      List of reactions to plot
%    nSubSamples:   Number of sub samples
%
% .. Author: - Markus Herrgard 8/14/06

nSkip = 10;
nBin = 20;

[nRxns,nSamples] = size(samples);

[isInModel,rxnInd] = ismember(rxnNames,model.rxns);
rxnInd = rxnInd(isInModel);

nPlotRxn = sum(isInModel);
rxnNames = rxnNames(isInModel);

nCol = ceil(sqrt(nPlotRxn));
nRow = ceil(nPlotRxn/nCol);

subSampleSize = floor(nSamples/nSubSamples);

clf
for rxnID = 1:nPlotRxn
    subplot(nRow,nCol,rxnID);
    hold on
    maxx = -1e9;
    minx = 1e9;
    maxy = 0;
    for subID = 1:nSubSamples
        [n,x] = hist(samples(rxnInd(rxnID),1:nSkip:(subSampleSize*subID))',nBin);
        plot(x,n/sum(n));
        maxx = max([max(x) maxx]);
        minx = min([min(x) minx]);
        maxy = max([max(n/sum(n)) maxy]);
    end
    axis([minx maxx 0 maxy]);
    title(rxnNames{rxnID});
end
