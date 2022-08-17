function [model] = annotateSBOTerms(model)
% Add SBO terms to model entities
%
% INPUT
% model     model structure
%
% OUTPUT
% model     updated model structure
%
% Ines Thiele June 2022

% give all metabolites a SBO:0000247 represents the term 'simple chemical'.
for i = 1 : length(model.mets)
    model.metSBOTerms{i} = 'SBO:0000247';
end

% give all genes a SBO:0000243 represents the term 'gene'.
for i = 1 : length(model.genes)
    model.geneSBOTerms{i} = 'SBO:0000243';
end

% reactions:
for i = 1 : length(model.rxns)
    if ~isempty(find(contains(model.rxns{i},'EX_'))) ||  ~isempty(find(contains(model.rxns{i},'Ex_')))
        % Exchange Reaction SBO:0000627 Presence
        model.rxnSBOTerms{i} = 'SBO:0000627';
    elseif  ~isempty(find(contains(model.rxns{i},'DM_')))
        % Demand Reaction SBO:0000628 Presence
        model.rxnSBOTerms{i} = 'SBO:0000628';
    elseif  ~isempty(find(contains(model.rxns{i},'Sink_'))) || ~isempty(find(contains(model.rxns{i},'sink_')))
        %Sink Reactions SBO:0000632 Presence
        model.rxnSBOTerms{i} = 'SBO:0000632';
    elseif  ~isempty(find(contains(model.rxns{i},'biomass')))
        % Biomass Reactions SBO:0000629 Presence
        model.rxnSBOTerms{i} = 'SBO:0000629';
    else
        % get compartments in reactions
        a = printRxnFormula(model,'rxnAbbrList',model.rxns{i},'printFlag',0);
        c = regexp(a,'\[\w]');
        c = c{1};
        clear comp;
        
        for k = 1 : length(c)
            comp{k} = a{1}(c(k):c(k)+2);
        end
        % find transport and metabolic reactions
        if length(comp) > 1 % exclude some other unmapped reactions
            if    length(unique(comp)) == 1 % metabolic reaction
                % Metabolic Reaction SBO:0000176 Presence
                model.rxnSBOTerms{i} = 'SBO:0000176';
            elseif  length(unique(comp)) > 1
                % they have 2 different compartments
                % Transport Reaction SBO:0000185 Presence
                model.rxnSBOTerms{i} = 'SBO:0000185';
                
            else
                model.rxnSBOTerms{i} = '';
            end
        else
              model.rxnSBOTerms{i} = '';
        end
    end
end

model.rxnSBOTerms = columnVector(model.rxnSBOTerms);
