function [exOrgaRxns, ExOrgaInd] = findOrganicExRxns(model, biomassReaction, functionToKeep)
% (c) Maria Pires Pacheco 2015
% Close all the exchange reactions which are carbon sources except the
% biomass reaction, the reactions that are supplying the medium or those
% that are in the functionToKeep input

exchangeMets = []; % exchange metabolites
exRxnsInd = find(sum(abs(model.S), 1) == 1); 
biomassId = find(ismember(model.rxns, biomassReaction)); 

if isempty(biomassId) && isempty(functionToKeep) % if no biomass and no functionToKeep -> exRxnsInd = all exchange rxns
    warning('No biomass set for the model, please verify if the medium constraints do not affect the biomass production')
elseif isempty(biomassId) && ~isempty(functionToKeep) % if biomass is empty but functionToKeep is provided
    warning('No biomass set for the model, please verify if the medium constraints do not affect the biomass production')
    functionId = find(ismember(model.rxns, functionToKeep)); % ids of the reactions to keep (those listed in functionToKeep)
    exRxnsInd = setdiff(exRxnsInd, functionId); % ids of exchange reactions that are not in the reactions to keep
else % if both biomass and functionToKeep are provided
    functionId = find(ismember(model.rxns, functionToKeep)); % ids of the reactions to keep (those listed in functionToKeep)
    functionId = unique([biomassId; functionId]); % keep both the biomass reaction ids and the functionToKeep reactions
    exRxnsInd = setdiff(exRxnsInd, functionId); % exchange reactions are those not in the ids to keep
end
% we remove from exchange reactions those included in biomass or functionToKeep

for i = 1:numel(exRxnsInd)
    exmets = find(model.S(:, exRxnsInd(i)));
    exchangeMets(end + 1) = exmets; % progressively add the exchange metabolites
    if model.S(exmets, exRxnsInd(i)) == 1
        model.S(exmets, exRxnsInd(i)) = -1; % in case the exchange reaction (import) was defined as reversible, we force it to irreversible import
    end
end

exOrgaRxns = model.rxns(exRxnsInd);

exMetsX = (regexp(model.metFormulas(exchangeMets), 'X')); 
exMetsY = (regexp(model.metFormulas(exchangeMets), 'Y')); % used to check whether exchange reactions involving X or Y metabolites are closed or not.

if ~isempty(model.metFormulas(exchangeMets(~cellfun('isempty', exMetsX))))
    disp('Warning metabolites with X in their Formulas these inputs are closed')
end
if ~isempty(model.metFormulas(exchangeMets(~cellfun('isempty', exMetsY))))
    disp('Warning metabolites with Y in their Formulas these inputs are closed')
end

exMetsCarbon = (regexp(model.metFormulas(exchangeMets), 'C')); % exchange reactions involving carbon
exMetsR = (regexp(model.metFormulas(exchangeMets), 'R')); % exchange reactions involving R
exKnowInorganic = (ismember(model.metFormulas(exchangeMets), 'Ca') | ismember(model.metFormulas(exchangeMets), 'Cl') | ismember(model.metFormulas(exchangeMets), 'Co') | ismember(model.metFormulas(exchangeMets), 'Cu'));
model.mets(exchangeMets(exKnowInorganic)); % print exchange reactions that are inorganic (non-nutritive, e.g., O2)

isOrganic = (~cellfun('isempty', exMetsCarbon) | ~cellfun('isempty', exMetsX) | ~cellfun('isempty', exMetsY) | ~cellfun('isempty', exMetsR)) & ~exKnowInorganic; % list of organic exchange reactions

ExOrgaInd = exRxnsInd(isOrganic); % output = indices of organic exchange reactions

end
