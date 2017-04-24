function plotSampleHist(rxnNames,samples,models,nBins,perScreen)
% Compares flux histograms for one or more samples
% for one or more reactions
%
% USAGE:
%
%    plotSampleHist(rxnNames, samples, models, nBins, perScreen)
%
% INPUTS:
%    rxnNames:      Cell array of reaction abbreviations
%    samples:       Cell array containing samples
%    models:        Cell array containing model structures or common model
%                   structure
%
% OPTIONAL INPUTS:
%    nBins:         Number of bins to be used
%    perScreen:     Number of reactions to show per screen.  Either a number or [nY, nX] vector.
%                   (press 'enter' to advance screens)
%
% EXAMPLE:
%    sampleStructOut1 = gpSampler(model1, 2150);
%    sampleStructOut2 = gpSampler(model2, 2150);
%    %Plot for model 1
%    plotSampleHist(model1.rxns,{samplePoints1},{model1})
%
%    %Plot reactions reactions in model 1 that also exist in model 2 using 10
%    %bins and plotting 12 reactions per screen.
%    plotSampleHist(model1.rxns,{samplePoints1,samplePoints2},{model1,model2},10,12)
%
% .. Authors;
%       - Markus Herrgard 7/17/06
%       - Richard Que 2/05/10, added ability to move in reverse direction.
%
% CONTROLS:
% To advance to next screen hit 'enter/return' or type 'f' and hit 'enter/return'
% To rewind to previous screen type 'r' or 'b' and hit 'enter/return'
% To quit script type 'q' and hit 'enter/return'

if (nargin < 5)
    perScreen = 1e5;
end

if (nargin < 4 || isempty(nBins))
    [tmp,nSamples] = size(samples{1});
    nBins = round(nSamples/25);
end

if (~iscell(samples))
    singleDataFlag = true;
    samplesTmp = samples;
    clear samples;
    samples{1} = samplesTmp;
end

if (~iscell(models))
    commonModelFlag = true;
else
    commonModelFlag = false;
end

if (~iscell(rxnNames))
    rxnNameList{1} = rxnNames;
else
    rxnNameList = rxnNames;
end

nRxns = length(rxnNameList);

for i = 1:nRxns
    if (commonModelFlag)
        keepRxn(i) = ismember(rxnNameList{i},models.rxns);
    else
        for j = 1:length(models)
            isIn(j) = ismember(rxnNameList{i},models{j}.rxns);
        end
        if (all(isIn))
            keepRxn(i) = true;
        else
            keepRxn(i) = false;
        end
    end
end

rxnNameList = rxnNameList(keepRxn');
nRxns = length(rxnNameList);
if length(perScreen) ==2
    nX = perScreen(2);
    nY = perScreen(1);
    perScreen = nX*nY;
else
    nX = ceil(sqrt(min(nRxns, perScreen)));
    nY = ceil(min(nRxns, perScreen)/nX);
end

j=1;
flagQuit = false;
fig=figure;
while ~flagQuit
    clear counts;
    currLB = 1e6;
    currUB = -1e6;
    for i = 1:length(samples)
        if (commonModelFlag)
            id = findRxnIDs(models,rxnNameList{j});
        else
            id = findRxnIDs(models{i},rxnNameList{j});
        end
        if (isempty(id))
            if (commonModelFlag)
                id = findRxnIDs(models,[rxnNameList{j} '_r']);
            else
                id = findRxnIDs(models{i},[rxnNameList{j} '_r']);
            end
            if (isempty(id))
                warning('Reaction does not exist');
            end
        end
        currLB = min(currLB,min(samples{i}(id,:)'));
        currUB = max(currUB,max(samples{i}(id,:)'));
    end

    if currUB-currLB < 8*eps*abs(mean([currUB, currLB])) %rescale currUB, LB if they are the same # within numerical precision (8*eps)
        av = abs(mean([currUB, currLB]));
        currUB = currUB+8*eps*av;
        currLB = currLB-8*eps*av;
    end
    bins = linspace(currLB,currUB,nBins);

    for i = 1:length(samples)
        sampleSign = 1;
        if (commonModelFlag)
            id = findRxnIDs(models,rxnNameList{j});
        else
            id = findRxnIDs(models{i},rxnNameList{j});
        end
        if (isempty(id))
            if (commonModelFlag)
                id = findRxnIDs(models,[rxnNameList{j} '_r']);
            else
                id = findRxnIDs(models{i},[rxnNameList{j} '_r']);
            end
            sampleSign = -1;
        end
        n = hist(sampleSign*samples{i}(id,:),bins);
        counts(:,i) = smooth(bins,n');
    end
    freq = counts./repmat(sum(counts),size(counts,1),1);

    subplot(nY,nX, mod(j-1, perScreen)+1);
    plot(bins,freq,'-');
    axis([currLB-.0001 currUB+.0001 0 max(max(freq))]);
    h = text((currUB+currLB)/2,max(max(freq))*1.1,strrep(rxnNameList{j},'_','-'));
    set(h,'HorizontalAlignment','center');

    user_input = 'f';
    if j>=nRxns
        if nRxns<=perScreen, return; end
        user_input = input('End of sampples; reverse (r) or quit (q): ','s');
        while isempty(user_input)|| ~(ismember(user_input(1),{'b','r','q','e'}))
            user_input = input('End of sampples; reverse (r) or quit (q)): ','s');
        end
        clear fig
    elseif mod(j, perScreen) ==0
        user_input = input('Move forward (f), reverse (r) or quit (q): ','s');
        if isempty(user_input), user_input='f'; end
        clear fig
    end
    if user_input(1)=='r' || user_input(1)=='b'
        j=j-perScreen*2+1;
        if j<0, j=1; end
    elseif user_input(1)=='q'|| user_input(1)=='e'
        flagQuit=true;
    elseif user_input(1)=='f'
        j=j+1;
    end
end
