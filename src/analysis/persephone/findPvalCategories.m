function [groupsToPlot, colours] = findPvalCategories(pValues)
% This function inputs a list of p values and outputs the variables 
% pValueGroups and colourGroups. A maximum of three groups are defined,
% FDR<0.05, P<0.05, and P>0.05. 
%
% USAGE:
%    [groupsToPlot, colours] = findPvalCategories(pValues)
%
% INPUT
% pValues
%
% OUTPUTS
% groupsToPlot      Table that categorises the indices of the p-value list.
% colours           Cell array with numerical encodings for the
%                   category-associated colours.
%
% .. Author:
%       - Tim Hensen       November, 2024

% First, the FDR values are calculated from the p-value list using the
% benjamini-holm method.
FDRvalues = mafdr(pValues,'BHFDR',true);

% Next, the p-value groups are defined. Note that not all groups might be
% present in the data.
pValueGroups = string(nan(length(pValues),1));
pValueGroups(FDRvalues<0.05) = 'FDR < 0.05';
pValueGroups(all([FDRvalues>=0.05 pValues<0.05],2)) = 'P < 0.05';
pValueGroups(pValues>=0.05) = 'P > 0.05';

% Then, the groupsToPlot table is created which contains for each category
% the row indices of their associated p-values
groupsToPlot = table();
groupsToPlot.('FDR < 0.05') = matches(pValueGroups,'FDR < 0.05');
groupsToPlot.('P < 0.05') = matches(pValueGroups,'P < 0.05');
groupsToPlot.('P > 0.05') = matches(pValueGroups,'P > 0.05');

% Define colours to plot
colours = {};
colours{1} = [0.89 0.145 0.157]; % red
colours{2} = [0 0.4470 0.7410]; % blue
colours{3} = [0.804 0.808 0.808]; % grey

% To ensure the colours and legends are always displayed correctly,
% plotting will be done separately for each group. If a group is not
% present in the p-value list, this group will be removed before plotting.

% Find groups absent in the p-value list
valuesToPlot = sum(table2array(groupsToPlot));

% Remove these categories
groupsToPlot(:,valuesToPlot==0)=[];
colours(valuesToPlot==0) = [];
end