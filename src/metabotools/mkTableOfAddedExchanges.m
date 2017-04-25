function [Added_all] = mkTableOfAddedExchanges(ResultsAllCellLines,samples,Ex_added_all_unique)
% The function generates a table of the added exchanges defined by the
% function `generateCompactExchModel` called by the function `setQuantConstraints`.
%
% USAGE:
%
%    [Added_all] = mkTableOfAddedExchanges(ResultsAllCellLines, samples, Ex_added_all_unique)
%
% INPUTS:
%    ResultsAllCellLines:
%    samples:
%    Ex_added_all_unique:    Output of the function `statisticsAddedExchanges`
%
% OUTPUT:
%    Added_all:              Table overview of all added Exchanges for each sample
%
% .. Author: - Maike K. Aurich 08/07/15

Added_all{length(Ex_added_all_unique),length(samples)+1}={};
Added_all(:,1)=Ex_added_all_unique(:,1);
Added_all_names=Ex_added_all_unique(:,1);

for i=1:length(samples)
    Ex_RxnsAdded = eval(['ResultsAllCellLines.' samples{i} '.Ex_RxnsAdded']);

    for k=1:length(Ex_RxnsAdded)

        A=find(ismember(Added_all_names,Ex_RxnsAdded{k,1}));
        Added_all{A,i+1}=Ex_RxnsAdded(k);

    end
end
end
