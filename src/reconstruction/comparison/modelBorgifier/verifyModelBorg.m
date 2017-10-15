function Model = verifyModelBorg(Model, varargin)
% Ensures that a model is in the correct format to be analyzed
% by any of the scripts in the `Tmodel` suite. It will add fields that are
% missing and expected for comparison. It will remove fields not in this list.
% Called by  `driveModelBorgifier`, calls `TmodelFields`, `fixNames`, `removeDuplicateNames`,
% `makeNamesUnique`, `buildRxnEquations`, `fixChemFormulas`, `orderModelFieldsBorg`, `organizeModelCool`.
%
% USAGE:
%
%    Model = verifyModelBorg(Model)
%
% INPUTS:
%    Vmodel:        Model from `readCbModel` or any of the `readModel` functions.
%
% OPTIONAL INPUTS:
%    'keepName':    Don't ask for verification of model name
%    'Verbose':     Print steps.
%
% OUTPUTS:
%    Model:         Model with additional fields and correct format.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

askForModelName = true ; % Declare variables.
verbose = false ;
if ~isempty(varargin)
    if sum(strcmp('keepName', varargin))
        askForModelName = false ;
    end
    if sum(strcmp('Verbose', varargin))
        verbose = true ;
    end
end

nRxns = length(Model.rxns);
nMets = length(Model.mets);

% Current Field names in the model.
fieldNames = fieldnames(Model);

% Get desired field names.
fields = TmodelFields ;
Field.rxn = fields{1};
Field.rNum = fields{2};
Field.met = fields{3};
Field.mNum = fields{4};
Field.all = fields{5};

%% Remove fields that will not be used
% This is a hacky solution, and unused fields should be carried forward
rmFieldNames = false(size(fieldNames)) ;
for iField = 1:length(fieldNames)
    if strmatch(fieldNames{iField}, Field.all)
        continue
    else
        rmFieldNames(iField) = 1 ;
    end
end
Model = rmfield(Model, fieldNames(rmFieldNames)) ;


%% Pad fields with empty strings or zeros.
% Reaction related cell arrays.
for iField = 1:length(Field.rxn)
   fieldIndex = strcmp(Field.rxn{iField}, fieldNames);
   fieldIndex = find(fieldIndex);
   if isempty(fieldIndex) % Field does not currently exist
       if verbose
           fprintf(['Array .' Field.rxn{iField} ' not in Model. Adding.\n'])
       end
       Model.(Field.rxn{iField}) = cell(nRxns, 1);
       Model.(Field.rxn{iField})(:) = {''};
   else % Field exists, check if the length is correct
       vFieldLength = length(Model.(fieldNames{fieldIndex}));
       for icell = 1:vFieldLength
           while iscell(Model.(fieldNames{fieldIndex}){icell})
               Model.(fieldNames{fieldIndex}){icell} = [Model.(fieldNames{fieldIndex}){icell}{:}] ;
           end
       end
       if vFieldLength ~= nRxns
           vFieldLength = vFieldLength + 1 ;
           Model.(fieldNames{fieldIndex})(vFieldLength:nRxns) = {''};
       end
   end
end

% Reaction related double arrays.
for iField = 1:length(Field.rNum)
   fieldIndex = strcmp(Field.rNum{iField}, fieldNames);
   fieldIndex = find(fieldIndex);
   if isempty(fieldIndex) % Field does not currently exist
       if verbose
           fprintf(['Array .' Field.rNum{iField} ' not in Model. Adding.\n'])
       end
       Model.(Field.rNum{iField}) = zeros(nRxns, 1);
   else % Field exists, check if the length is correct
       vFieldLength = length(Model.(fieldNames{fieldIndex}));
       if vFieldLength ~= nRxns
           vFieldLength = vFieldLength + 1 ;
           Model.(fieldNames{fieldIndex})(vFieldLength:nRxns) = 0 ;
       end
   end
end

% Metabolite related cell arrays.
for iField = 1:length(Field.met)
   fieldIndex = strcmp(Field.met{iField}, fieldNames);
   fieldIndex = find(fieldIndex);
   if isempty(fieldIndex) % Field does not currently exist
       if verbose
           fprintf(['Array .' Field.met{iField} ' not in Model. Adding.\n'])
       end
       Model.(Field.met{iField}) = cell(nMets, 1);
       Model.(Field.met{iField})(:) = {''};
   else % Field exists, check if the length is correct
       vFieldLength = length(Model.(fieldNames{fieldIndex}));
       % weed out cells in cells
       for icell = 1:vFieldLength
           while iscell(Model.(fieldNames{fieldIndex}){icell})
               Model.(fieldNames{fieldIndex}){icell} = [Model.(fieldNames{fieldIndex}){icell}{:}] ;
           end
       end
       if vFieldLength ~= nMets
           vFieldLength = vFieldLength + 1 ;
           Model.(fieldNames{fieldIndex})(vFieldLength:nMets) = {''};
       end
   end
end

% Metabolite related double arrays.
for iField = 1:length(Field.mNum)
   fieldIndex = strcmp(Field.mNum{iField}, fieldNames);
   fieldIndex = find(fieldIndex);
   if isempty(fieldIndex) % Field does not currently exist
       if verbose
           fprintf(['Array .' Field.mNum{iField} ' not in Model. Adding.\n'])
       end
       Model.(Field.mNum{iField}) = zeros(nMets, 1);
   else % Field exists, check if the length is correct
       vFieldLength = length(Model.(fieldNames{fieldIndex}));
       if vFieldLength ~= nMets
           vFieldLength = vFieldLength + 1 ;
           Model.(fieldNames{fieldIndex})(vFieldLength:nMets) = 0 ;
       end
   end
end

%% Ensure reactions are forwards.
if verbose
    fprintf('Making sure reactions are all forwards\n')
end
% Find reverse reactions based on bounds.
revRxns = find(abs(Model.lb) > Model.ub);

% Do it.
for iRxn = 1:length(revRxns)
    % Reverse bounds.
    [Model.lb(revRxns(iRxn)), Model.ub(revRxns(iRxn))] = ...
        deal(-Model.ub(revRxns(iRxn)), -Model.lb(revRxns(iRxn)));

    % Change sign of stochiometrix matrix.
    metStoics = find(Model.S(:, revRxns(iRxn)));
    for iMet = 1:length(metStoics)
        if Model.S(metStoics(iMet), revRxns(iRxn)) > 0
            Model.S(metStoics(iMet), revRxns(iRxn)) = ...
                0 - Model.S(metStoics(iMet), revRxns(iRxn));
        else
            Model.S(metStoics(iMet), revRxns(iRxn)) = ...
                abs(Model.S(metStoics(iMet), revRxns(iRxn)));
        end
    end
end

%% Remove hyphens and obtuse characters from names.
if verbose
    fprintf('Fixing names of metabolites and reaction\n')
end
Model.mets = fixNames(Model.mets);
Model.metNames = fixNames(Model.metNames);
Model.metNames = removeDuplicateNames(Model.metNames);
Model.rxns = fixNames(Model.rxns);
Model.rxnNames = removeDuplicateNames(Model.rxnNames);

%% Make sure all reaction and metabolite names are unique.
if verbose
    fprintf('Checking if reaction IDs (.rxns) are unique.\n');
end
if length(Model.rxns) ~= length(unique(Model.rxns))
    fprintf('ERROR: Not all reactions are unique.\n')
    % Launch name correcting script.
    Model.rxns = makeNamesUnique(Model.rxns, Model.rxnNames);
end
if verbose
    fprintf('Checking if metabolite IDs (.mets) are unique.\n');
end
if length(Model.mets) ~= length(unique(Model.mets))
    fprintf('ERROR: Not all metabolites are unique.\n')
    Model.mets = makeNamesUnique(Model.mets, Model.metNames);
end

%% Make sure all metabolites have a compartment.
noComp = find(cellfun(@isempty, regexp(Model.mets, '\[\w\]$')));

if isempty(noComp)
    if verbose
        fprintf('All metabolites have comparment designation.\n')
    end
else
    % try to get compartment information from metNames
    nameComp = find(~cellfun(@isempty, regexp(Model.metNames, '\[\w\]$')));
    if ~isempty(nameComp)
        for inc = rowvector(nameComp)
            Model.mets{inc} = [Model.mets{inc} ...
                Model.metNames{inc}(strfind(Model.metNames{inc}, '['): ...
                strfind(Model.metNames{inc}, ']')) ];
            Model.metNames{inc} = ...
                Model.metNames{inc}(1:strfind(Model.metNames{inc}, '[')-1);
        end
    end

    noComp = find(cellfun(@isempty, regexp(Model.mets, '\[\w\]$')));

    if isempty(noComp)
        if verbose
            fprintf('All metabolites have comparment designation.\n')
        end
    else
        if verbose
            fprintf(['Some metabolites have no compartment designation. ' ...
            'Assigning as cytosolic.\n'])
        end
        for iMet = 1:length(noComp)
            Model.mets{noComp(iMet)} = [Model.mets{noComp(iMet)} '[c]'];
        end
    end
end

%% Give .rxnID or .metID names from .rxns and .mets.
Model.rxnID = Model.rxns ;
Model.metID = Model.mets ;

%% If model has SEED style reaction or metabolite IDs, add them to arrays.
% Reactions.
areSEEDids = ~cellfun(@isempty, regexp(Model.rxns, '^rxn\d{5}$'));
Model.rxnSEEDID(areSEEDids) = Model.rxns(areSEEDids);

% Metabolites.
noComp = Model.mets;
for iMet = 1:length(noComp)
    noComp{iMet} = noComp{iMet}(1:end - 3);
end
areSEEDids = ~cellfun(@isempty, regexp(noComp, '^cpd\d{5}$'));
Model.metSEEDID(areSEEDids) = noComp(areSEEDids);

%% Format chemical formulas
Model.metFormulas = fixChemFormulas(Model.metFormulas);

%% Rebuild reaction equations to ensure they use fixed names/abbreviations.
Model = buildRxnEquations(Model);

%% Ensure all vectors are column vectors.
colFields = {'rxn' 'rNum' 'met' 'mNum'};
for iName = 1:length(colFields)
    for iField = 1:length(Field.(colFields{iName}))
        Model.(Field.(colFields{iName}){iField}) = ...
            Model.(Field.(colFields{iName}){iField})(:);
    end
end

%% Make sure there is a model name and if not, ask for one.
if ~isfield(Model, 'description')
    needModelName = 1 ;
else
    if askForModelName
        fprintf(['Current model name is:' char(10) Model.description char(10)])
        answer = input('Keep name? (y/n): ', 's');
        if strcmpi(answer,'y') || strcmpi(answer, 'yes')
            fprintf('Keeping name\n')
            needModelName = 0 ;
        else
            needModelName = 1 ;
        end
    else
        needModelName = 0 ;
    end
end
try
    test.(Model.description) = true  ;
catch
    disp('Sorry, this model name is invalid. (Hint: it must start with a letter and only contain letters and numbers)')
    needModelName = 1 ;
end
while needModelName
    prompt = 'Input model name: ';
    modelName = input(prompt, 's');
    Model.description = modelName ;
    try
        test.(Model.description) = true  ;
        needModelName = 0 ;
    catch
        disp('Sorry, this model name is invalid. (Hint: it must start with a letter and only contain letters and numbers)')
    end
end

%% Reorder fields and organize model based on most common mets.
Model = orderModelFieldsBorg(Model);
Model = organizeModelCool(Model);
