function resultCell = FEA(model, rxnSet, group)
% Significance analysis - Flux enrichment analysis using hypergeometric
% 1-sided test and FDR correction for multiple testing
%
% USAGE:
%
%    resultCell = FEA(model, rxnSet, 'subSystems')
%
% INPUTS:
%    model:           COBRA structure model
%    rxnSet:          reaction set to be enriched (vector of reaction indices e.g. 1:10)
%    group:           model.group structure e.g.
%                    'subSystems' : FEA looks for significantly enriched subsystems in rxnSet
%
% OUTPUT:
%    resultCell:    cell structure of enriched groups
%
% EXAMPLE:
%
%    load ecoli_core_model;
%    resultCell = FEA(modelEcore, 1:10, 'subSystems');
%
% .. Author: Marouen BEN GUEBILA 04/2016

if nargin < 3
    error('The function FEA must be called with model, reaction set and group as arguments')
end
if ~isvector(rxnSet)
    error('Please provide the indices of the reactions e.g. 1:10')
end
if ~ischar(group)
    error('Please provide the group name as string of characters e.g. ''subSystems'' ')
end

%Temporary Warning until FEA statistics are checked for multiple classes.
if strcmp(group, 'subSystems') && isfield(model,'subSystems')
    if iscell(model.subSystems{1}) %Potentially multiple subSystems
        if any(cellfun(@numel, model.subSystems) > 2)
            warning('Multiple subSystems detected for some reactions. FEA statistics might not be correct.\n Please consider using only one subSystem per reaction.')
        end
    end
end

% compute frequency of enriched terms
groups = eval(['model.' group]);
if iscell([groups{:}])
   [uniquehSubsystemsA] = unique([groups{:}]);
   presenceindicator = false(numel(uniquehSubsystemsA),numel(model.rxns));
   for i = 1:numel(groups)
       presenceindicator(:,i) = ismember(uniquehSubsystemsA,groups{i});
   end   
   [K,~] = find(presenceindicator);
else
    %This works only for fields which have a single entry.
    [uniquehSubsystemsA, ~, K] = unique(groups);
end
% fetch group
enRxns = eval(['model.' group '(rxnSet)']);
m = length(uniquehSubsystemsA);
allSubsystems = zeros(1, m);

% look for unique occurences
if iscell([enRxns{:}])
   [uniquehSubsystems] = unique([enRxns{:}]);
   presenceindicator = false(numel(uniquehSubsystems),numel(model.rxns));
   for i = 1:numel(enRxns)       
        presenceindicator(:,i) = ismember(uniquehSubsystems,enRxns{i});
   end   
   [J,~] = find(presenceindicator);
else
    %This works only for fields which have a single entry.
    [uniquehSubsystems, ~, J] = unique(enRxns);
end

occ = histc(J, 1:numel(uniquehSubsystems));
[l, p] = intersect(uniquehSubsystemsA, uniquehSubsystems);
allSubsystems(p) = occ;

% compute total number of reactions per group
nRxns = histc(K, 1:numel(uniquehSubsystemsA));  % the number of reactions per susbsystem

% Compute p-values
gopvalues = hygepdf(allSubsystems', max(nRxns), max(allSubsystems), nRxns);

% take out the zeros for one-sided test
nonZerInd = find(allSubsystems);

% sort p-values
[m, rxnInd] = sort(gopvalues);

% intersect non zero sets with ordered pvalues
[~, nonZeroInd] = intersect(rxnInd, nonZerInd)
orderedPval = rxnInd(sort(nonZeroInd));

% Build result cell
% initilize variable
resultCell = cell(length(orderedPval) + 1, 5);
resultCell(1, :) = {'P-value', 'Adjusted P-value', 'Group', 'Enriched set size', 'Total set size'};

% P values
resultCell(2:end, 1) = num2cell(gopvalues(orderedPval));

% correct for multiple testing with FDR
resultCell(2:end, 2) = num2cell(mafdr(cell2mat(resultCell(2:end, 1)), 'BHFDR', true));

% Group name
resultCell(2:end, 3) = uniquehSubsystemsA(orderedPval);

% Test size
resultCell(2:end, 4) = num2cell(allSubsystems(orderedPval))';

% Total group size
resultCell(2:end, 5) = num2cell(nRxns(orderedPval));

end
