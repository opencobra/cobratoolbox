function [finalState,finalInputs1States,finalInputs2States] = solveBooleanRegModel(model,initialState,inputs1States,inputs2States)
% Determines the next state of the regulatory network based on the current state.
% Called by optimizeRegModel and dynamicRFBA
% 
% USAGE:
%
%    [finalState, finalInputs1States, finalInputs2States] =
%    solveBooleanRegModel(model, initialState, inputs1States, inputs2States)
%
% INPUTS:
%    model:                 a regulatory COBRA model
%    initialState:          initial state of regulatory network
%    inputs1States:         initial state of type 1 inputs (metabolites)
%    inputs2States:         initial state of type 2 inputs (reactions)
%
% OUTPUTS:
%    finalState:            final state of regulatory network
%    finalInputs1States:    final state of type 1 inputs
%    finalInputs2States:    final state of type 2 inputs
%
% .. Authors: - Jeff Orth  7/24/08



finalInputs1States = [];
% determine state of inputs

% determine external metabolite levels from exchange rxn bounds (maybe change this later)
[selExc,selUpt] = findExcRxns(model); %get all exchange rxns 
for i = 1:length(model.regulatoryInputs1)
    met = model.regulatoryInputs1{i};
    fullS = full(model.S);
    rxnID = intersect(find(fullS(findMetIDs(model,met),:)),find(selExc));
    if model.lb(rxnID) < 0
        finalInputs1States(i,1) = true;
    else
        finalInputs1States(i,1) = false;
    end
end    

% apply initialState to model, get rxn fluxes
drGenes = {};
for i = 1:length(model.regulatoryGenes)
    if initialState(i) == false 
        drGenes{length(drGenes)+1} = model.regulatoryGenes{i};
    end
end
drGenes = intersect(model.genes,drGenes); % remove genes not associated with rxns
modelDR = deleteModelGenes(model,drGenes); % set rxns to 0
fbasolDR = optimizeCbModel(modelDR,'max',true);

% if rxn flux = 0, set state to false
finalInputs2States = [];
if ~any(fbasolDR.x)
    finalInputs2States = false.*ones(length(model.regulatoryInputs2),1);
else
    for i = 1:length(model.regulatoryInputs2)
        rxnFlux = fbasolDR.x(findRxnIDs(model,model.regulatoryInputs2{i}));
        if rxnFlux == 0
            finalInputs2States(i,1) = false;
        else
            finalInputs2States(i,1) = true;
        end
    end
end

% determine state of genes

ruleList = parseRegulatoryRules(model); %get the set of rules in a form that can be evaluated

geneStates = [];
for i = 1:length(model.regulatoryRules)
    geneStates(i,1) = eval(ruleList{i});
end

finalState = geneStates;
    

%% parseRegulatoryRules
function ruleList = parseRegulatoryRules(model)

ruleList = cell(length(model.regulatoryRules),1); %preallocate array

for i = 1:length(model.regulatoryRules)
    fields = splitString(model.regulatoryRules{i},'[\s~|&()]');
    newFields = fields;
    for j = 1:length(fields) %iterate through words and replace
        word = fields{j};
        if strcmp(word,'true') 
            newFields{j} = 'true';
        elseif strcmp(word,'false')
            newFields{j} = 'false';
        else
            if any(strcmp(word,model.regulatoryGenes))
                index = find(strcmp(word,model.regulatoryGenes));
                newFields{j} = ['initialState(',num2str(index),')'];
            elseif any(strcmp(word,model.regulatoryInputs1))
                index = find(strcmp(word,model.regulatoryInputs1));
                newFields{j} = ['inputs1States(',num2str(index),')'];
            elseif any(strcmp(word,model.regulatoryInputs2))
                index = find(strcmp(word,model.regulatoryInputs2));
                newFields{j} = ['inputs2States(',num2str(index),')'];
            else
                newFields{j} = ''; %no match, delete the invalid word
            end
        end
    end
    newRule = model.regulatoryRules{i};
    for j = 1:length(fields)
        newRule = strrep(newRule,fields{j},newFields{j});
    end
    ruleList{i} = newRule;
end
    

