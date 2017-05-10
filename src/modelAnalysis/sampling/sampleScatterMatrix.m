function sampleScatterMatrix(rxnNames,model,sample,nPoints,fontSize,dispRFlag,rxnNames2)
% Draws a scatterplot matrix with pairwise scatterplots
% for multiple reactions
%
% USAGE:
%
%    sampleScatterMatrix(rxnNames, model, sample, nPoints, fontSize, dispRFlag, rxnNames2)
%
% INPUTS:
%    rxnNames:      Cell array of reaction names to be plotted
%    model:         Model structure
%    sample:        Samples to be analyzed (`nRxns` x `nSamples`)
%
% OPTIONAL INPUTS:
%    nPoints:       How many sample points to plot (Default `nSamples`)
%    fontSize:      Font size for labels (Default calculated based on
%                   number of reactions)
%    dispRFlag:     Display correlation coefficients (Default false)
%    rxnNames2:     Optional second set of reaction names
%
% EXAMPLES:
%
%    %Plots the scatterplots only between the three reactions listed -
%    %histograms for each reaction will be on the diagonal
%    sampleScatterMatrix({'PFK','PYK','PGL'},model,sample);
%    %Plots the scatterplots between each of the first set of reactions and
%    %each of the second set of reactions. No histograms will be shown.
%    sampleScatterMatrix({'PFK','PYK','PGL'},model,sample,100,10,true,{'ENO','TPI');
%
% .. Author: - Markus Herrgard 9/14/06

[isInModel,rxnInd] = ismember(rxnNames,model.rxns);
rxnNames = rxnNames(isInModel);
rxnInd = rxnInd(isInModel);
nRxns = length(rxnNames);

if nargin < 4%no optional inputs specified
    nPoints = size(sample,2);
    dispRFlag = false;
    nRxns2 = nRxns;
    rxnNames2 = rxnNames;
    nPanels = nRxns*nRxns2;
    fontSize = 10+ceil(50/sqrt(nPanels));
    twoSetsFlag = false;
else%some optional inputs specified
    if isempty(nPoints)
        nPoints = size(sample,2);
    end
    if isempty(dispRFlag)
        dispRFlag = false;
    end
    if nargin == 7
        [isInModel2,rxnInd2] = ismember(rxnNames2,model.rxns);

        rxnNames2 = rxnNames2(isInModel2);
        rxnInd2 = rxnInd2(isInModel2);

        nRxns2 = length(rxnNames2);
        twoSetsFlag = true;
        nRxns = nRxns+1;
        nRxns2 = nRxns2+1;
    else
        nRxns2 = nRxns;
        rxnNames2 = rxnNames;
        twoSetsFlag = false;
    end
    if isempty(fontSize)
        nPanels = nRxns*nRxns2;
        fontSize = 10+ceil(50/sqrt(nPanels));
    end
end
height = 0.8/nRxns;
width = 0.8/nRxns2;

clf
showprogress(0,'Drawing scatterplots ...');
for i = 1:nRxns

    for j = 1:nRxns2
        showprogress(((i-1)*nRxns+j)/(nRxns*nRxns2));
        left = 0.1+(j-1)*width;
        bottom = 0.9-i*height;
        if (twoSetsFlag)
            if (i == 1 && j == 1)
            else
                %subplot(nRxns,nRxns2,(i-1)*nRxns2+j);
                subplot('position',[left bottom width height]);
                if (j >1 && i >1)
                    sampleScatterPlot(sample,rxnInd2(j-1),rxnInd(i-1),nPoints,fontSize,dispRFlag);
                elseif (i == 1)
                    sampleHistInternal(sample,rxnInd2(j-1),fontSize);
                elseif (j == 1)
                    sampleHistInternal(sample,rxnInd(i-1),fontSize);
                end
                if (i == 1)
                    xlabel(rxnNames2{j-1},'FontSize',fontSize);
                    set(gca,'XAxisLocation','top');
                end
                if (j == 1)
                    ylabel(rxnNames{i-1},'FontSize',fontSize);
                end
            end
        else
            if (j == i)
                %subplot(nRxns,nRxns2,(i-1)*nRxns2+j);
                subplot('position',[left bottom width height]);
                sampleHistInternal(sample,rxnInd(i),fontSize);

            elseif (j > i)
                %subplot(nRxns,nRxns2,(i-1)*nRxns2+j);
                subplot('position',[left bottom width height]);
                sampleScatterPlot(sample,rxnInd(j),rxnInd(i),nPoints,fontSize,dispRFlag);
            end
            if (i == 1)
                xlabel(rxnNames2{j},'FontSize',fontSize);
                set(gca,'XAxisLocation','top');
            end
            if (j == nRxns2)
                set(gca,'YAxisLocation','right');
                ylabel(rxnNames{i},'FontSize',fontSize);
            end
        end
    end

end


function sampleScatterPlot(sample,id1,id2,nPoints,fontSize,dispRFlag)

selPts = randperm(size(sample,2));
selPts = selPts(1:nPoints);

plot(sample(id1,selPts),sample(id2,selPts),'r.');
set(gca,'YTickLabel',[]);
set(gca,'XTickLabel',[]);
maxx = max(sample(id1,:));
maxy = max(sample(id2,:));
minx = min(sample(id1,:));
miny = min(sample(id2,:));
axis([minx maxx miny maxy]);
% Display correlation coefficients
if (dispRFlag)
    r = corrcoef(sample(id1,:)',sample(id2,:)');
    h = text(minx+0.66*(maxx-minx),miny+0.2*(maxy-miny),num2str(round(100*r(1,2))/100));
    set(h,'FontSize',fontSize-5);
end

function sampleHistInternal(sample,id,fontSize)

[n,bins] = hist(sample(id,:),30);
if (exist('smooth'))
    plot(bins,smooth(bins,n')/sum(n'));
else
    plot(bins,n'/sum(n'));
end
maxx = max(bins);
minx = min(bins);
set(gca,'XTick',linspace(minx,maxx,4));
set(gca,'XTickLabel',round(10*linspace(minx,maxx,4))/10);
set(gca,'YTickLabel',[]);
set(gca,'FontSize',fontSize-5);
axis tight
