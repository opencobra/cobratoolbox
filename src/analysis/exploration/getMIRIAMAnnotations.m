function annotations = getMIRIAMAnnotations(model, varargin)
% Get the MIRIAM Annotations a struct array of annotation structs for the given type
%
% USAGE:
%    annotations = getMIRIAMAnnotations(model, varargin)
%
% INPUTS:
%    model:             The COBRA  model structure. 
%
% OPTIONAL INPUTS:
%    varagin:           Additional arguments as parameter/value pairs.
%                        * `referenceField` - The reference field to look up the IDs (or the whole field if no ID is porivded). If not provided, the function will try to determine all anotations for the given IDs for all base fields. 
%                        * `bioQualifiers` - A Cell array of BioQualifiers to look for if not provided, or empty, all bioQualifiers defined in `getBioQualifiers()` will be used
%                        * `ids` - A specific ID or IDs to get the annotation data for. Cannot be combined with type model.(Default: model.([type 's'])). 
%                        * `databases` - Database identifiers to extract (default: all)
% OUTPUT:
%    annotations:       A struct array with the following structure:                        
%                        * annotations.cvterms -> A Struct array of controlled vocabulary terms with one element per qualifier used
%                        * annotations.cvterms.qualifier -> the bioQualifier for this all ressourcesof this cvterm 
%                        * annotations.cvterms.qualifierType -> the Qualifier type (modelQualifier or bioQualifier) for all ressources of this cvterm 
%                        * annotations.cvterms.ressources -> struct with the following fields:
%                        * annotations.cvterms.ressources.database -> the database for this ressource.
%                        * annotations.cvterms.ressources.id-> The ID in the database for this ressource.
%                        * annotations.id the associated with the cv term


[defaultBioQualifiers,standardQualifiers] = getBioQualifiers();

defaultFields = intersect(getCobraTypeFields(),fieldnames(model));



parser = inputParser();
parser.addParameter('referenceField','all',@(x) (ischar(x) || iscell(x)) && all(ismember(regexprep(x,'s$',''),union(regexprep(defaultFields,'s$',''),{'all','model'}))));
parser.addParameter('bioQualifiers',defaultBioQualifiers,@(x) ischar(x) || iscell(x))
parser.addParameter('databases','all',@(x) ischar(x) || iscell(x));
parser.KeepUnmatched = true;
% get the potential reference fields.
parser.parse(varargin{:});

if isfield(model,'modelID')
    modelID = {model.modelID};
else
    modelID = {'model'};
end

type = regexprep(parser.Results.referenceField,'s$','');
if strcmp(type,'all')
    type = union('model',defaultFields);
end

% check whether type is a cell array (requires special treatment).
if iscell(type)
    defaultIDs = {};
    for i = 1:numel(type)        
        cField = type{i};
        if strcmp(cField,'model')
            % skip
            continue;
        end
        if isfield(model,cField)
            defaultIDs = union(defaultIDs,model.(cField));
        end
    end
    if any(ismember(type,'model')) 
        defaultIDs = [modelID;defaultIDs];
    end
    idValidationFunction = @(x) (ischar(x) || iscell(x)) && all(ismember(x,defaultIDs));
elseif ~strcmpi(type,'model')
    defaultIDs = model.([lower(type) 's']);
    idValidationFunction = @(x) (ischar(x) || iscell(x)) && all(ismember(x,defaultIDs)) || isnumeric(x) && max(x) < numel(defaultIDs) || islogical(x) && max(find(x)) < numel(defaultIDs);
else
    defaultIDs = modelID;
    idValidationFunction = @(x) ischar(x);
end
parser.addParameter('ids',defaultIDs,idValidationFunction);
parser.KeepUnmatched = false;
% parse again to check the IDs.
parser.parse(varargin{:});
ids = parser.Results.ids;

% determine the bioQualifiers to check
bioQualifiers = parser.Results.bioQualifiers;
if ischar(bioQualifiers)
    bioQualifiers = {bioQualifiers};
end

% select the databases to check
dbsToReturn = parser.Results.databases;
% make sure this is a cell array if its not all
if ischar(dbsToReturn) && ~strcmp(dbsToReturn,'all')
    dbsToReturn = {dbsToReturn};
end

% in case we have a single id, we will convert it into a cell array.
if ischar(ids)
    ids = {ids};
end

if iscell(type)
    annotations = struct('id',{},'cvterms',struct('qualifier',{},'qualifierType',{},'ressources',struct('id',{},'database',{})));    
    annotations(numel(ids)).id = ids(numel(ids));
    for i = 1:numel(type)         
       cField = type{i};
       if strcmp(cField,'model')
           % skip the model, handled separately
           continue;
       end
       [idpres] = find(ismember(ids,model.(cField)));
       if ~isempty(idpres)
           result = getMIRIAMAnnotations(model,'ids',ids(idpres),'referenceField',cField,...
               'databases', dbsToReturn, 'bioQualifiers',bioQualifiers);
           for elem = 1:numel(idpres)
               if isempty(annotations(idpres(elem)).cvterms)
                   %no assignments yet, so we set it.
                   annotations(idpres(elem)) = result(elem);
               else
                   annotations(idpres(elem)).cvterms = [annotations(idpres(elem)).cvterms,result(elem).cvterms];
               end
           end
       end
    end
    % also handle the model field if requested.
    if any(ismember(modelID,ids)) && any(ismember(type,'model'))
        result = getMIRIAMAnnotations(model,'referenceField','model',...
                                          'databases', dbsToReturn, 'bioQualifiers',bioQualifiers);
        annotations(1).id = ids{1};
        annotations(1).cvterms = result.cvterms;
    end
    return
end

% extract positional IDs
if isnumeric(ids) || islogical(ids)
    ids = model.([lower(type) 's'])(ids);
end

% we have to handle some things special for model annotations (e.g. they can
% have model qualifiers)
if strcmp(type,'model')
    numElements = 1;
    annotations = cell(1);
    modelAnnot = true;
    bioQualifiers = [strcat('m',bioQualifiers),strcat('b',bioQualifiers)];    
    if isfield(model,'modelID')
        ids = {model.modelID};
    else
        ids = {'model'};
    end
else
    numElements = length(ids);
    modelAnnot = false;
    modelQualString = '';
    [pres,pos] = ismember(ids,model.([type 's']));
    relPos = pos(pres);
    if  numel(relPos) ~= numElements
        error('The following IDs were not part of model.%s:\n%s',[type, 's'],strjoin(setdiff(ids,model.([type 's'])(relPos)),'\n'));
    end
end

modelFields = fieldnames(model);
unusedFields = true(size(modelFields));
databaseFields = getDatabaseMappings(type);
% ok, these can be converted
databaseFields = databaseFields(ismember(databaseFields(:,3),modelFields),:);
% so we first convert the databaseFields
% but we will first filter so that we only get the standard qualifiers for
% each db.
databaseFields = databaseFields(ismember(databaseFields(:,2),standardQualifiers(:,1)),:);

% now we know the database fields, so we will check for the non default
% annotation fields
relfields = modelFields(cellfun(@(x) strncmp(x,type,length(type)),modelFields));        
annotationsFields = relfields(cellfun(@(x) any(cellfun(@(y) strncmp(x,[type, y],length([type y])),bioQualifiers)),relfields));

if ~ischar(dbsToReturn)
    databaseFields = databaseFields(ismember(lower(databaseFields(:,1)),lower(dbsToReturn)),:);
    % build all possible target fields given the qualifiers and the 
    [qualifiers,databases] = cellfun(@(x) getBioQualifierAndDBFromFieldName(x),annotationsFields,'Uniform',false);
    rels = ismember(qualifiers,bioQualifiers) & ismember(databases,dbsToReturn);
else
    [qualifiers] = cellfun(@(x) getBioQualifierAndDBFromFieldName(x),annotationsFields,'Uniform',false);
    rels = ismember(qualifiers,bioQualifiers);
end
    
annotationsFields = annotationsFields(rels);
% now, we can initialize the result cell array. 
% this array has the following form:
% Dim1 -> one entry per element
% Dim2 -> one entry per either database or annotations Field
% Dim3 -> 1: qualifierType ; 2: qualifier ; 3: Database ; 4: IDs ; 
resultArray = cell(numElements,size(databaseFields,1)+ numel(annotationsFields), 4);
arrayDim2Pos = 1;
for i = 1:size(databaseFields,1)
    cField = databaseFields{i,3};
    cSource = databaseFields(i,1);
    cQual = databaseFields(i,2);
    if modelAnnot
        cValues = {model.(cField)};    
    else
        cValues = model.(cField)(relPos);
    end
    cQualType = databaseFields(i,6);
    resultArray(:,arrayDim2Pos,:) = [repmat(cQualType,numElements,1),repmat(cQual,numElements,1),repmat(cSource,numElements,1),cValues];
    arrayDim2Pos = arrayDim2Pos + 1;
end

for i = 1:numel(annotationsFields)
    cField = annotationsFields{i};
    if modelAnnot
        cValues = {model.(annotationsFields{i})};    
    else
        cValues = model.(annotationsFields{i})(relPos);
    end
    % get the correct qualifier for this field.
    for i = 1:numel(bioQualifiers)
        cQual = bioQualifiers{i};
        if strncmp(cField,[type, cQual],length([type cQual]))
            cField = cField((length([type cQual])+1):end);
            break;
        end
    end
    cQualType = 'bioQualifier';
    if modelAnnot
        if cQual(1) == 'm'
            cQualType = 'modelQualifier';
        end
        cQual = cQual(2:end);
    end
    cSource = convertSBMLID(regexprep(cField,'ID$',''),false);
	if ~ischar(dbsToReturn) && ~any(strcmpi(cSource,dbsToReturn))
        % if not all, or the db doesn't match the description, skip it.
        continue
    end
    resultArray(:,arrayDim2Pos,:) = [repmat({cQualType},numElements,1),repmat({cQual},numElements,1),repmat({cSource},numElements,1),cValues];
    arrayDim2Pos = arrayDim2Pos + 1;
end

% now, build a struct out of this cell array.
ressourceStruct = struct('database','','id','');
ressourceStruct(1) = []; %Clear the empty element.
cvtermStruct = struct(struct('qualifier','','qualifierType','','ressources',ressourceStruct));
cvtermStruct(1) = [];
annotations = struct('id','rxn1','cvterms',cvtermStruct);
annotations(numElements).id = '';

% as a reminder, this is the structure of the array:
% Dim1 -> one entry per element
% Dim2 -> one entry per either database or annotations Field
% Dim3 -> 1: qualifierType ; 2: qualifier ; 3: Database ; 4: IDs ; 

for i = 1:numElements
    cvtermsIndex = 1;
    % initialize the elements
    annotations(i).id = ids{i};
    annotations(i).cvterms = cvtermStruct;
    % fill the actual cvterms (if any)
    currentCVtermsStruct = cvtermStruct;    
    % take all qualifierTypes which have non empty entries for this element
    relArray = resultArray(i,:,:);
    currentQualifiers = unique(resultArray(i,:,2));
    % we go over each qualifier, and will then look for the qualifierType to
    % distinguish
    for j = 1:numel(currentQualifiers)
        % get the current qualifier
        cQualifier = currentQualifiers{j};
        qualIndex = strcmp(resultArray(i,:,2),cQualifier);
        qualifierTypes = unique(resultArray(i,qualIndex,1));        
        for k = 1:numel(qualifierTypes)
            % and qualifier typee
            cQualifierType = qualifierTypes{k};            
            cStruct = struct('qualifier',cQualifier,'qualifierType',cQualifierType,'ressources',ressourceStruct);
            cDBArray = {};
            cIDArray = {};
            relIndices = strcmp(resultArray(i,:,1),cQualifierType) & qualIndex;
            databases = resultArray(i,relIndices,3);
            dbids = resultArray(i,relIndices,4);
            for cdb = 1:length(databases)
                % and the ressources
                cDatabase = databases{cdb};
                cIDs = strsplit(dbids{cdb},'; '); %IDs are split by ; in the fields.                
                if ~all(cellfun(@isempty, cIDs))
                    cDBArray = [cDBArray , repmat({cDatabase},1,numel(cIDs))];
                    cIDArray = [cIDArray , cIDs];
                end
            end
            if ~isempty(cIDArray)
                % if we have at least one ID
                cRessourcestruct = ressourceStruct;
                cRessourceStruct(numel(cIDArray)).id = '';
                [cRessourceStruct(:).id] = deal(cIDArray{:});
                [cRessourceStruct(:).database] = deal(cDBArray{:});
                cStruct.ressources = cRessourceStruct;           
                currentCVtermsStruct(cvtermsIndex) = cStruct;
                cvtermsIndex = cvtermsIndex + 1;                           
            end
            annotations(i).cvterms = currentCVtermsStruct; %Either empty or with data.
        end        
    end
end

end


