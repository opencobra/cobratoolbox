function [newModel, hasEffect] = addMetInfoInCBmodel(model, inputData, replace)
% Integrates metabolite data from an external file and incorporates it into 
% the COBRA model.
%
% USAGE:
%
%    model = addMetInfoInCBmodel(model, inputData)
%
% INPUTS:
%    model:         COBRA model with following fields:
%
%                       * .S - The m x n stoichiometric matrix for the
%                              metabolic network.
%                       * .mets - An m x 1 array of metabolite identifiers.
%    inputData:     COBRA model with following fields:
%
% OPTIONAL INPUTS:
%    replace:       If the new ID should replace an existing ID, this 
%                   logical value indicates so (default: false).
%
% OUTPUTS:          COBRA model with updated identifiersCOBRA model with 
%                   the identifiers updated.

if nargin < 3 || isempty(replace)
    replace = false;
end

hasEffect = false;

if isfile(inputData)
    dbData = readtable(inputData);
elseif isstruct(inputData)
    dbData = readtable(inputData);
end

% Get data from model and external source
sources = {'KEGG', 'HMDB', 'ChEBI', 'PubChem', 'SMILES', 'InChI'};
fields = fieldnames(model);
newDataVariableNames = dbData.Properties.VariableNames;
metsInModel = regexprep(model.mets, '(\[\w\])', '');

for i = 1:size(sources, 2)
    
    % Get the corresponding field for a database in the model
    fieldInModelBool = ~cellfun(@isempty, regexpi(fields, sources{i}));
    if sum(fieldInModelBool) > 1
        metDataInModelBool = ~cellfun(@isempty, regexpi(fields, 'met'));
        fieldInModelBool = fieldInModelBool & metDataInModelBool;
    end
    % Create the field if it does not exist
    if sum(fieldInModelBool) == 0
        model.(['met' sources{i}]) = cell(size(metsInModel, 1), 1);
        fields = fieldnames(model);
        fieldInModelBool = ~cellfun(@isempty, regexpi(fields, sources{i}));
    end
    
    % Get the corresponding field for a database in the data
    fieldInDataBool = ~cellfun(@isempty, regexpi(newDataVariableNames, sources{i}));
    if sum(fieldInDataBool) > 1
        metDataInDataBool = ~cellfun(@isempty, regexpi(newDataVariableNames, 'met'));
        inchiKeyInDataBool = cellfun(@isempty, regexpi(newDataVariableNames, 'inchikey'));
        fieldInDataBool = fieldInDataBool & (metDataInDataBool | inchiKeyInDataBool);
    end
    
    if sum(fieldInModelBool) == 1 && sum(fieldInDataBool) == 1
        
        % Identify the correct idx per metabolite
        for j = 1:size(dbData.(newDataVariableNames{1}), 1)
            
            % Fix for numeric values omitting 0 and NaN
            if isnumeric(dbData.(newDataVariableNames{fieldInDataBool})(j))
                if ~isnan(dbData.(newDataVariableNames{fieldInDataBool})(j)) && dbData.(newDataVariableNames{fieldInDataBool})(j) ~= 0
                    data2add = num2str(dbData.(newDataVariableNames{fieldInDataBool})(j));
                else
                    data2add = [];
                end
            else
                data2add = dbData.(newDataVariableNames{fieldInDataBool}){j};
            end
            idx = strmatch(dbData.(newDataVariableNames{1}){j}, metsInModel, 'exact');
            
            % Fill the data
            if ~isempty(idx) && replace && ~isempty(data2add)
                
                % Add the ID
                for k = 1:size(idx, 1)
                    model.(fields{fieldInModelBool})(idx(k)) = data2add;
                end
                if ~hasEffect
                    hasEffect = true;
                end
                
            elseif ~isempty(idx) && ~replace && ~isempty(data2add)
                
                % Only add data on empty cells
                idxBool = cellfun(@isempty, model.(fields{fieldInModelBool})(idx));
                if any(idxBool)
                    idx = idx(idxBool);
                    % Add the ID
                    for k = 1:size(idx, 1)
                        model.(fields{fieldInModelBool}){idx(k)} = data2add;
                    end
                    if ~hasEffect
                        hasEffect = true;
                    end
                end
                
            end
            
        end
    elseif sum(fieldInModelBool) > 1 || sum(fieldInDataBool) > 1
        error(['Rename the data, nameTag "' sources{i} '" was found more than 1 time'])
    end
end

newModel = model;