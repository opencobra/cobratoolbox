function [translatedModel,notInTableRxns, notInTableMets] = translateKBaseModel2VMHModel(model, biomassReaction,database)
% Translates reaction and metabolite identifiers from a KBase/ModelSEED
% reconstruction to the Virtual Metabolic Human (https://vmh.life)
% reaction and metabolite nomenclature.
% The reaction and metabolite database with VMH identifiers as well as the
% translation table from KBase/Model SEED to VMH reaction and metabolite
% identiers are retrieved from the folder
% cobratoolbox/papers/2018_microbiomeModelingToolbox/database.
% Note that there will likely be reactions and metabolites that are not yet
% included in the translation table and will thus be missing from the
% translated model.
%
% INPUT
% model                 COBRA model structure derived from KBase/ModelSEED
% biomassReaction       Biomass reaction abbreviation
%
% OUTPUTS
% translatedModel       Translated COBRA model structure
% notInTableRxns        Reactions that are currently not in translation
%                       table
% notInTableMets        Metabolites that are currently not in translation
%                       table
%
% ... AUTHORS
% Stefania Magnusdottir, Oct 2017
% Almut Heinken, Dec 2018 - simplified inputs

% check inputs
if isempty(model)
    error('No model provided')
end
if isempty(biomassReaction)
    error('No biomass reaction provided')
end
if ~any(ismember(model.rxns, biomassReaction))
    error('Invalid biomass reaction')
end

% load the reaction and metabolite translation tables
translateRxns = readtable('ReactionTranslationTable.txt', 'Delimiter', '\t');
translateRxns=table2cell(translateRxns);
translateMets = readtable('MetaboliteTranslationTable.txt', 'Delimiter', '\t');
translateMets=table2cell(translateMets);

% adapt IDs for translation
model.mets = strrep(model.mets, '[c0]', '_c0');
model.mets = strrep(model.mets, '[e0]', '_e0');
model.rxns = strrep(model.rxns, '_c0', '');
model.rxns = strrep(model.rxns, '_e0', '');

% proceed if the model contains any reactions in KBase nomenclature
if ~isempty(intersect(model.rxns,translateRxns(:,1)))
    model.rxns = strrep(model.rxns, 'R_', '');
    % create a grRules field as KBase reconstructions do not have one
    model = creategrRulesField(model);

    % biomass reaction is not translatable, will translate using metabolite
    % translation table
    biomass = printRxnFormula(model, 'rxnAbbrList', biomassReaction, 'printFlag', false);
    biomassMets = model.mets(model.S(:, ismember(model.rxns, biomassReaction)) ~= 0);
    biomassMets = strrep(biomassMets, '_c0', '');
    biomassMets = strrep(biomassMets, '_e0', '');
    
    % check if all biomass metabolites are in translation table
    notInTableBiomassMets = setdiff(biomassMets, translateMets(:, 1));
    if ~isempty(notInTableBiomassMets)
        error('Model contains biomass metabolites that are not present in translation table')
    end
    
    % biomass metabolite indeces in translation table
    [biomassMets, ~, iB] = intersect(biomassMets, translateMets(:, 1));
    
    % translate biomass
    biomassTranslated = biomass;
    for i = 1:length(biomassMets)
        biomassTranslated = regexprep(biomassTranslated, ...
            translateMets{iB(i), 1},  translateMets{iB(i), 2});
    end
    biomassTranslated = regexprep(biomassTranslated, ...
        '_c0',  '[\c]');
    biomassTranslated = regexprep(biomassTranslated, ...
        '_e0',  '[\e]');
    
    % remove biomass reaction from model (add translated reaction at the end)
    model = removeRxns(model, biomassReaction);
    
    % adust metabolite and reaction IDs
    % model.mets = strrep(model.mets, '[c0]', '_c0');
    % model.mets = strrep(model.mets, '[e0]', '_e0');
    model.mets = strrep(model.mets, '[c0]', '');
    model.mets = strrep(model.mets, '[e0]', '');
    model.mets = strrep(model.mets, '_c0', '');
    model.mets = strrep(model.mets, '_e0', '');
    model.rxns = strrep(model.rxns, '_c0', '');
    model.rxns = strrep(model.rxns, '_e0', '');
    model.rxns = strrep(model.rxns, 'R_', '');
    
    % check if there are any reactions in model that are not in translation
    % table
    notInTableRxns = setdiff(model.rxns, translateRxns(:, 1));
    if ~isempty(notInTableRxns)
        warning('Model contains reactions that are not present in translation table.')
    end
    % check if there are any metabolites in model that are not in translation
    % table
    notInTableMets = setdiff(model.mets, translateMets(:, 1));
    if ~isempty(notInTableMets)
        warning('Model contains metabolites that are not present in translation table.')
    end
    
    % find model reaction indeces in reaction translation table
    [newModelRxns, iA, iB] = intersect(model.rxns, translateRxns(:, 1));
    
    % check that all translated VMH reactions are in the reaction database
    notInDB = setdiff(translateRxns(iB, 2), database.reactions(:, 1));
    if ~isempty(notInDB)
        error('Some translated reactions are not present in reaction database.')
    end
    
    % create structure for translated model
    newModel = struct();
    newModel.rxns = cell(0, 1);
    newModel.mets = cell(0, 1);
    newModel.genes = cell(0, 1);
    newModel.c = zeros(size(newModel.rxns));
    newModel.lb = zeros(size(newModel.rxns));
    newModel.ub = zeros(size(newModel.rxns));
    newModel.rules = cell(0, 1);
    newModel.genes = model.genes;
    newModel.geneNames = model.geneNames;
    newModel.comments = cell(0, 1);
    newModel.citations = cell(0, 1);
    newModel.rxnECNumbers = cell(0, 1);
    newModel.rxnKEGGID = cell(0, 1);
    newModel.subSystems = cell(0, 1);
    newModel.rxnConfidenceScores = zeros(size(newModel.rxns));
    newModel.S = sparse(zeros(0, 0));
    
    % add reactions from database to model
    for i = 1:length(newModelRxns)
        findRxn = find(strcmp(database.reactions(:, 1), translateRxns{iB(i), 2}));
        if ~isempty(findRxn)
            newModel = addReaction(newModel, database.reactions{findRxn, 1}, ...
                'reactionName', database.reactions{findRxn, 2}, ...
                'reactionFormula', database.reactions{findRxn, 3}, ...
                'subSystem', database.reactions{findRxn, 11}, ...
                'geneRule', model.grRules{iA(i)}, ...
                'printLevel', 0);
        else
            warning('Translated reaction not found in reaction database!')
        end
    end
    % add translated biomass reaction
    % biomass reaction formula needs to be a char
    biomassTranslated = char(biomassTranslated);
    newModel = addReaction(newModel, biomassReaction, ...
        'reactionName', 'Biomass reaction', ...
        'reactionFormula', biomassTranslated, ...
        'printLevel', 0);
    
    % add metabolite information
    translMets = newModel.mets;
    translMets = strrep(translMets, '_c0', '');
    translMets = strrep(translMets, '_e0', '');
    [newModelMets, iA, iB] = intersect(translMets, translateMets(:, 1));
    notInDB = setdiff(translateMets(iB, 2), database.metabolites(:, 1));
    if ~isempty(notInDB)
        error('Some translated metabolites are not present in metabolites database.')
    end
    
    model = newModel;
    % enter metabolite data (some metabolites appear in multiple compartments,
    % hence the for loop)
    [allMets, ~, iB] = intersect(regexprep(model.mets, '\[[ec]\]', ''), database.metabolites(:, 1));
    for i = 1:length(allMets)
        inds = find(strncmp(allMets{i}, model.mets, length(allMets{i})));
        for j = 1:length(inds)
            model.metNames{inds(j), 1} = database.metabolites(iB(i), 2);
            model.metFormulas{inds(j), 1} = char(database.metabolites(iB(i), 4));
            model.metCharges(inds(j), 1) = str2double(database.metabolites(iB(i), 5));
        end
    end
    
    % rebuild the model in a quality-controlled manner
    [translatedModel] = rebuildModel(model,database);
else
    translatedModel = model;
    notInTableRxns = {}; 
    notInTableMets = {};
end

end
