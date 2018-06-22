function annotations = getMIRIAMAnnotations(model, type, bioQualifiers)
% Get the MIRIAM Annotations a struct array of annotation structs for the given type
%
% USAGE:
%    annotations = getMIRIAMAnnotations(model,field)
%
% INPUTS:
%    model:             The COBRA  model structure. 
%    type:              the basic field to get annotations for (e.g. rxn, met, or
%                       model
%
% OPTIONAL INPUT:
%    bioQualifiers:     A Cell array of BioQualifiers to look for
%                       if not provided, or empty, all bioQualifiers
%                       defined in `getBioQualifiers()` will be used
%
% OUTPUT:
%    annotations:       A struct array with the following structure:
%                        * .annotation -> A Struct array with one element per element of the given type.
%                        * .annotation.cvterms -> A Struct array of controlled vocabulary terms with one element per qualifier used
%                        * .annotation.cvterms.qualifier -> the bioQualifier for this all ressourcesof this cvterm 
%                        * .annotation.cvterms.qualifierType -> the Qualifier type (modelQualifier or bioQualifier) for all ressources of this cvterm 
%                        * .annotation.cvterms.ressources -> struct with the following fields:
%                        * .annotation.cvterms.ressources.database -> the database for this ressource.
%                        * .annotation.cvterms.ressources.id-> The ID in the database for this ressource.

if ~exist('bioQualifiers','var') || isempty(bioQualifiers)
    [bioQualifiers,standardQualifiers] = getBioQualifiers();
else
    [~,standardQualifiers] = getBioQualifiers();
end

%We have to handle some things special for model annotations (e.g. they can
%have model qualifiers)
if strcmp(type,'model')
    numElements = 1;
    annotations = cell(1);
    modelAnnot = true;
    bioQualifiers = [strcat('m',bioQualifiers),strcat('b',bioQualifiers)];
    ids = {'model'};
else
    numElements = length(model.([type 's']));
    modelAnnot = false;
    modelQualString = '';
    ids = model.([type 's']);
end

modelFields = fieldnames(model);
unusedFields = true(size(modelFields));
databaseFields = getDatabaseMappings(type);
%Ok, these can be converted
databaseFields = databaseFields(ismember(databaseFields(:,3),modelFields),:);
%So we first convert the databaseFields
%But we will first filter so that we only get the standard qualifiers for
%each db.
databaseFields = databaseFields(ismember(databaseFields(:,2),standardQualifiers(:,1)),:);

%Now we know the database fields, so we will check for the non default
%Annotation fields
relfields = modelFields(cellfun(@(x) strncmp(x,type,length(type)),modelFields));        
annotationsFields = relfields(cellfun(@(x) any(cellfun(@(y) strncmp(x,[type, y],length([type y])),bioQualifiers)),relfields));

%Now, we can initialize the result cell array. 
%this array has the following form:
% Dim1 -> one entry per element
% Dim2 -> one entry per either database or annotations Field
% Dim3 -> 1: qualifierType ; 2: qualifier ; 3: Database ; 4: IDs ; 
resultArray = cell(numElements,size(databaseFields,1)+ numel(annotationsFields), 4);
arrayDim2Pos = 1;
for i = 1:size(databaseFields,1)
    cField = databaseFields{i,3};
    cSource = databaseFields(i,1);
    cQual = databaseFields(i,2);
    cValues = model.(cField);
    cQualType = databaseFields(i,6);
    resultArray(:,arrayDim2Pos,:) = [repmat(cQualType,numElements,1),repmat(cQual,numElements,1),repmat(cSource,numElements,1),cValues];
    arrayDim2Pos = arrayDim2Pos + 1;
end

for i = 1:numel(annotationsFields)
    cField = annotationsFields{i};
    cValues = model.(annotationsFields{i});
    %get the correct qualifier for this field.
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
    resultArray(:,arrayDim2Pos,:) = [repmat({cQualType},numElements,1),repmat({cQual},numElements,1),repmat({cSource},numElements,1),cValues];
    arrayDim2Pos = arrayDim2Pos + 1;
end

%Now, build a struct out of this cell array.
annotations = struct('id','rxn1','cvterms',struct('qualifier','','qualifierType','','ressources',struct('database','','id','')));
annotations(numElements).id = '';

% As a reminder, this is the structure of the array:
% Dim1 -> one entry per element
% Dim2 -> one entry per either database or annotations Field
% Dim3 -> 1: qualifierType ; 2: qualifier ; 3: Database ; 4: IDs ; 

for i = 1:numElements
    cvtermsIndex = 1;
    annotations(i).id = ids{i};
    cvtermsStruct = struct('qualifier','','qualifierType','','ressources',struct('database','','id',''));
    %Take all qualifierTypes which have non empty entries for this element
    relArray = resultArray(i,:,:);
    currentQualifiers = unique(resultArray(i,:,2));
    %We go over each qualifier, and will then look for the qualifierType to
    %distinguish
    for j = 1:numel(currentQualifiers)
        %Get the current qualifier
        cQualifier = currentQualifiers{j};
        qualIndex = strcmp(resultArray(i,:,2),cQualifier);
        qualifierTypes = unique(resultArray(i,qualIndex,1));        
        for k = 1:numel(qualifierTypes)
            %QAnd qualifier typee
            cQualifierType = qualifierTypes{k};            
            cStruct = struct('qualifier',cQualifier,'qualifierType',cQualifierType,'ressources',struct('database','','id',''));
            cDBArray = {};
            cIDArray = {};
            relIndices = strcmp(resultArray(i,:,1),cQualifierType) & qualIndex;
            databases = resultArray(i,relIndices,3);
            dbids = resultArray(i,relIndices,4);
            for cdb = 1:length(databases)
                %And the ressources
                cDatabase = databases{cdb};
                cIDs = strsplit(dbids{cdb},'; '); %IDs are split by ; in the fields.                
                if ~all(cellfun(@isempty, cIDs))
                    cDBArray = [cDBArray , repmat({cDatabase},1,numel(cIDs))];
                    cIDArray = [cIDArray , cIDs];
                end
            end
            if ~isempty(cIDArray)
                %if we have at least one ID
                ressourceStruct = struct('database','','id','');
                ressourceStruct(numel(cIDArray)).id = '';
                [ressourceStruct(:).id] = deal(cIDArray{:});
                [ressourceStruct(:).database] = deal(cDBArray{:});
                cStruct.ressources = ressourceStruct();           
                cvtermsStruct(cvtermsIndex) = cStruct;
                cvtermsIndex = cvtermsIndex + 1;                           
            end
            annotations(i).cvterms = cvtermsStruct; %Either empty or with data.
        end        
    end
end

end