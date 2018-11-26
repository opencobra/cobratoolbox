function results = searchModel(model,searchTerm,varargin)
% Search for the specified term in the given model.
% The performed search is fuzzy if similarity is lower than 1.
% 
% USAGE:
%    results = searchModel(model,searchTerm,...)
%
% INPUTS:
%    model:         The model to search in
%    searchTerm:    The term to search for
%    varargin:      Additional parameters as parameter/value pairs or value struct.
%                   Available parameters are:
%                    * printLevel - Printout switch, 0 silent, 1 print results. (Default = 1) .
%                    * similarity - Minimum similarity (as provided in calcSim) for matches.
%                    
% OUTPUTS:
%    results:       The results struct build as follows:
% 
%                     * .field - a struct array containing of the basic fields (e.g. rxns, mets etc) of the model in which matches were found with each field indicating the matches as detailed below.
%                     * .field.id - The id of the matching element
%                     * .field.matches - information about the matches of the respective ID.
%                     * .field.matches.value - the value that matched.
%                     * .field.matches.source - the field that contained the matching value.
%
% .. Author: - Thomas Pfau, June 2018

parser = inputParser();
parser.addParameter('printLevel',1,@isnumeric);
parser.addParameter('similarity',0.8,@(x) isnumeric(x) && x <= 1 && x >= 0);
parser.parse(varargin{:});
similarity = parser.Results.similarity;
printLevel = parser.Results.printLevel;

% first collect some potential fields, which are known.
[baseFields,baseFieldNames] = getCobraTypeFields();

%filter the base fields:
fieldsPresentInModel = ismember(baseFields,fieldnames(model));
baseFields = baseFields(fieldsPresentInModel);
baseFieldNames = baseFieldNames(fieldsPresentInModel);

%All Base fields do have an associated "Names" field.
nameFields = regexprep(baseFields,'s$','Names');
knownFields = union(baseFields,nameFields);
dbFields = getDefinedFieldProperties('DataBaseFields',true);
knownFields = union(knownFields,dbFields(:,3));
% and get the annotations which can also be looked up.
annotationQualifiers = getBioQualifiers();
results = struct();
% now, loop over all basic fields 
displayedFields = 0;
for field = 1:numel(baseFields)    
    cField = baseFields{field};
    % get the model fields associated with this type.
    modelFields = getModelFieldsForType(model,cField);
    resultList = cell(numel(model.(cField)),numel(modelFields));    
    similarities = zeros(numel(model.(cField)),1);
    annotationsFields = {};
    for aqual = 1:numel(annotationQualifiers)  
       cAnnotType = regexprep(cField,'s$',annotationQualifiers{aqual});
       annotationsFields = union(annotationsFields,modelFields(cellfun(@(x) strncmp(x,cAnnotType,length(cAnnotType)),modelFields)));
    end
    % except for xyzNames there are few other fields which contain sensibly
    % searchable information (subSystems is one example). 
    for modelField = 1:numel(modelFields)        
        cModelField = modelFields{modelField};
        if strcmp(cModelField,'subSystems')
            % subSystems is special, as it contains cell arrays.
            fieldToUse = cellfun(@(x) strjoin(x,';'),model.subSystems,'Uniform',0);
            isAnnotation = true;
            
        elseif any(strcmp(cModelField,knownFields))
            % iIf its a known field, than it is a cell array of strings and
            % we will use it accordingly
            isAnnotation = false;
            if strcmp(cModelField,'mets')
                if isempty(regexp(searchTerm,'\[[^\[]\]$'))
                    fieldToUse = regexprep(model.mets,'\[[^\[]\]$','');
                else
                    fieldToUse = model.mets;
                end
            else
                fieldToUse = model.(cModelField);
            end
        else      
            if any(strcmp(cModelField,annotationsFields))
                % if its an annotation field, we look into it.
                fieldToUse = model.(cModelField);
                isAnnotation = true;
            else
                % field does nto match anything. don't search in it.
                continue 
            end
        end        
        % find matches
        [matchingIDs,positions,csims] = findMatchingFieldEntries(fieldToUse,searchTerm,isAnnotation,similarity);
        if ~isempty(positions)
            resultList(positions,modelField) = matchingIDs;            
            similarities(positions) = max(similarities(positions),csims);
        end
    end
    if any(any(~cellfun(@isempty, resultList)))
        if printLevel > 0 && displayedFields > 0
            fprintf('\n-----------------------------------------------------\n\n');
        end
        displayedFields = displayedFields + 1;
        if printLevel > 0            
            fprintf('The following %s have matching properties:\n\n',baseFieldNames{field});            
        end
        % get the base field
        results.(cField) = struct();
        relRows = ~all(cellfun(@isempty,resultList),2);
        results.(cField).id = 'start';        
        results.(cField).matches = struct();
        results.(cField)(sum(relRows)).id = 'end';
        % and the relevant results for that base field
        relResults = resultList(relRows,:);
        relResultPos = find(relRows);
        % order according to highest similarity
        [~,simorder] = sort(similarities(relRows),'descend');
        for cResults = 1:size(relResults,1)
            results.(cField)(cResults).id = model.(cField){relResultPos(simorder(cResults))};            
            results.(cField)(cResults).matches = struct();
            % init struct with size
            results.(cField)(cResults).matches.source = '';
            results.(cField)(cResults).matches.value = '';
            % get the field which have matching entries.
            resultEntries = find(~cellfun(@isempty, relResults(simorder(cResults),:)));
            results.(cField)(cResults).matches(numel(resultEntries)).source = '';
            for cResult = 1:numel(resultEntries)
                % set the source to the fieldName and the value to the found value.
                results.(cField)(cResults).matches(cResult).source = modelFields{resultEntries(cResult)};
                results.(cField)(cResults).matches(cResult).value = relResults{simorder(cResults),resultEntries(cResult)};
            end
            if printLevel > 0   
                % print the individual ids and fields the similarity was achieved on
                fprintf('ID: %s ', model.(cField){relResultPos(simorder(cResults))});                
                matchingFields = {results.(cField)(cResults).matches(:).source};
                matchingValues = {results.(cField)(cResults).matches(:).value};
                % filter ID Field
                idpos = strcmp(matchingFields,cField);
                matchingFields = matchingFields(~idpos);
                matchingValues = matchingValues(~idpos);
                if ~isempty(matchingFields)
                   fprintf('with the following matching values:\n');
                   matches = strcat(matchingFields,{': '},matchingValues);
                   fprintf('%s', strjoin(matches,'; '));
                end
                fprintf('\n\n');
            end
        end
    end     
end
         
        


