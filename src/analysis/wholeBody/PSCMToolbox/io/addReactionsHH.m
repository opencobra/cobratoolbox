function [model] = addReactionsHH(model, rxnAbbrs, rxnNames, reactions, gprs, subSystems, couplingFactor, rxnNotes, rxnReferences)
% Add reaction(s) to the whole-body metabolic model with coupling constraints
%
% This function adds reaction(s) to the whole-body metabolic model, including
% the required coupling constraint. It is based on
% model = addReaction(model, 'newRxn1', 'A -> B + 2 C').
%
% USAGE:
%
%    [model] = addReactionsHH(model, rxnAbbrs, rxnNames, reactions, gprs, subSystems, couplingFactor, rxnNotes, rxnReferences)
%
% INPUTS:
%    model:            Whole-body metabolic model, with fields:
%
%                        * .rxns - reaction identifiers
%                        * .S - stoichiometric matrix
%                        * .A - constraint matrix (stoichiometry plus coupling constraints)
%                        * .subSystems - subsystem annotations
%    rxnAbbrs:         List of reaction abbreviation(s) to add
%    rxnNames:         List of reaction names
%    reactions:        List of reaction formulae, e.g. {'A -> B + 2 C'}
%    gprs:             List of gene-protein-reaction rules
%    subSystems:       List of subsystems
%    couplingFactor:    Coupling factor to add (default 20000)
%    rxnNotes:         List of notes for the reactions (optional)
%    rxnReferences:    List of references for the reactions (optional)
%
% OUTPUT:
%    model:            Updated model structure
%
% .. Authors:
% ..    - Ines Thiele, 2018
% ..    - IT, added GPR rules to be properly taken into account


if ~exist('couplingFactor','var') || ~isempty(couplingFactor)
    couplingFactor = 20000;
end
if ~exist('rxnNotes','var') || isempty(rxnNotes)
    rxnNotesPresent = 0;
else
        rxnNotesPresent = 1;
end
if ~exist('rxnReferences','var') || isempty(rxnReferences)
    rxnRefPresent = 0;
else
    rxnRefPresent = 1;
end

for i = 1 : length(rxnAbbrs)
    
    % check that reaction does not exist yet in model
    if isempty(strmatch(rxnAbbrs(i),model.rxns,'exact'))
        % add reaction
        model = addReaction(model,rxnAbbrs{i},reactions{i});
        A = strmatch(rxnAbbrs(i),model.rxns,'exact');
        model.subSystems(A) = subSystems(i);
        %model.grRules(A) = gprs(i);
        if ~isempty(gprs{i})
            model = changeGeneAssociation(model, rxnAbbrs{i}, gprs{i}, {}, {}, 0);
        end
        model.rxnNames(A) = rxnNames(i);
        if isfield(model,'rxnNotes') && rxnNotesPresent == 1
            model.rxnNotes(A) = rxnNotes(i);
        end
        if isfield(model,'rxnReferences') && rxnRefPresent == 1
            model.rxnReferences(A) = rxnReferences(i);
        end
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
                && isempty(strmatch('BileDuct_EX_',rxnAbbrs(i))) && isempty(strmatch('BC_EX_',rxnAbbrs(i)))
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