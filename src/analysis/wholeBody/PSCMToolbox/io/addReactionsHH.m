function [model] = addReactionsHH(model, rxnAbbrs,rxnNames, reactions, gprs, subSystems,couplingFactor)
% This function add reaction(s) to the whole-body metabolic model,
% including the required coupling constraint.
% This function is based on model = addReaction(model,'newRxn1','A -> B + 2 C')
%
% [model] = addReactionsHH(model, rxnAbbrs,rxnNames, reactions, gprs, subSystems,couplingFactor)
%
% INPUT
% model             Model structure
% rxnAbbrs          List of reaction abbreviation(s) to be added
% rxnNames          List of reaction names
% reactions         List of reaction formula {'A -> B + 2 C'}
% gprs              List of grRules
% subSystems        List of subSystems
% couplingFactor    Coupling factor to be added, default 20000
%
% OUTPUT
% model             Updated model structure
%
% Ines Thiele 2018

if ~exist('couplingFactor','var')
    couplingFactor = 20000;
end

for i = 1 : length(rxnAbbrs)
    
    % check that reaction does not exist yet in model
    if isempty(strmatch(rxnAbbrs(i),model.rxns,'exact'))
        % add reaction
        model = addReaction(model,rxnAbbrs{i},reactions{i});
        A = strmatch(rxnAbbrs(i),model.rxns,'exact');
        model.subSystems(A) = subSystems(i);
        model.grRules(A) = gprs(i);
        model.rxnNames(A) = rxnNames(i);
        [token,rem] = strtok(rxnAbbrs{i},'_');
        % find organ biomass
        if strcmp(token,'sIEC')
            rxnC= strmatch('sIEC_biomass_maintenance',model.rxns,'exact');%(find(~cellfun(@isempty,strfind((model.rxns),'sIEC_biomass_maintenance'))));
            if isempty(rxnC)
                rxnC = strmatch('sIEC_biomass_reactionIEC01b',model.rxns,'exact');
            end
       
        else
            rxnC = strmatch(strcat(token,'_biomass_maintenance'),model.rxns,'exact');
            if isempty(rxnC)
                rxnC = strmatch(strcat(token,'_biomass_maintenance_noTrTr'),model.rxns);
            end
        end
        model.A = model.S;
        % if reaction does not start with Excretion or EX or Diet - add
        % coupling constraint
      
        if isempty(strmatch('EX_',rxnAbbrs(i))) && isempty(strmatch('Excretion_',rxnAbbrs(i))) && isempty(strmatch('Diet_',rxnAbbrs(i))) ...
                && isempty(strmatch('LI_EX_',rxnAbbrs(i))) &&  isempty(strmatch('SI_EX_',rxnAbbrs(i))) ...
                &&  isempty(strmatch('GI_EX_',rxnAbbrs(i))) && isempty(strmatch('BBB_',rxnAbbrs(i))) ...
                && isempty(strmatch('BileDuct_EX_',rxnAbbrs(i))) 
            [model]=coupleRxnList2Rxn(model,rxnAbbrs(i),...
                model.rxns(rxnC),couplingFactor,0.00);
        end
        model.S=model.A;
    else
        warning('Reaction with the same name already exists in the model');
    end
    
end

if isfield(model,'A')
    % remove model.A
    model = rmfield(model,'A');
end