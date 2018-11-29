function model = addMIRIAMAnnotations(model, elementIDs, databases, ids, varargin)
% Add a MIRIAM style annotation to the model
% 
% USAGE: 
%    model = addMIRIAMAnnotation(model, elementID, database, id, ...)
%
% INPUTS:
%    model:         A COBRA Style model struct
%    elementID:     The element IDs to annotate (either a single ID as a 
%                   char array, or a cell array of model IDs. Must be
%                   present in one of the basic fields of the model.
%    databases:     The databases for which annotations are added. Either a
%                   single char array if it is the same database for all
%                   annotated elements, or a cell array of strings with one
%                   element for each added element. The databases have to
%                   be registered with identifiers.org and must match
%                   either the identifiers.org prefix or the exact name!
%    ids:           The IDs to set for each element. Either a char array if
%                   only a single element is annotated, or a cell array of
%                   chars if multiple elements are annotated. 
%
% OPTIONAL INPUTS:
%    varargin:      Additional parameters either as parameter/value pairs
%                   or as a parameter struct with the following
%                   options/fieldnames:
%                    * referenceField - the field in which to look up the ids (e.g. rxns, mets, comps etc...) If this is 'model', than the annotation will be assumed to be a model annotation, and the ID will be ignored. If empty, the whole model will be checked, and all matching ids will be annotated.
%                    * annotationTypes - The type of the annotation. either 'bio' or 'model'. Default('bio')
%                    * annotationQualifiers - The qualifier of the annotation ( see http://co.mbine.org/standards/qualifiers ) for possible qualifiers (Default: 'is') 
%                    * replaceAnnotation - Replace existing annotations with those supplied now (Default: false)
%                    * printLevel - How much output to produce - 0, silent ; 1, verbose - (Default: 0) 
% OUTPUT:
%    model:         The COBRA model with the added annotations

definedModelFields = getDefinedFieldProperties();
% these are all base fields
baseFields = getCobraTypeFields();

% get the defined databases
dbs = getRegisteredDatabases();

% we assume everything is a cell array, so we translate provided char
% arrays. and bring them into the right format.
if ischar(ids)
    ids = {ids};
end
ids = columnVector(ids);

% get correctly formated elemntIDs
if ischar(elementIDs)
    elementIDs = {elementIDs};
end
elementIDs = columnVector(elementIDs);

% check the databases
if ischar(databases)
    databases = repmat({databases},numel(ids),1);
end
databases = columnVector(databases);

% parse the input
parser = inputParser();
parser.addParameter('referenceField','',@(x) isempty(x) || any(strcmpi(baseFields,x)) || strcmpi('model',x));
parser.addParameter('annotationTypes',repmat({'bio'},numel(elementIDs),1),@(x) (ischar(x) && any(strcmpi(x,{'model','bio'}))) ...
                                                                               || (iscell(x) && all(cellfun(@(y) any(strcmpi(y,{'model','bio'})),x))));
parser.addParameter('annotationQualifiers',repmat({'is'},numel(elementIDs),1),@(x) ischar(x) || iscellstr(x));
parser.addParameter('replaceAnnotation',false,@(x) islogical(x) || (isnumeric(x) && (x == 1 || x == 0)));
parser.addParameter('printLevel',0,@isnumeric);
parser.parse(varargin{:});

referenceField = parser.Results.referenceField;
annotationType = parser.Results.annotationTypes;
annotationQualifier = parser.Results.annotationQualifiers;
replaceAnnotation = parser.Results.replaceAnnotation;
printLevel = parser.Results.printLevel;

% convert element Ids to a column vector - ease of use
elementIDs = columnVector(elementIDs);

% and convert potential single elements to cell arrays refering to all
% elements
if ischar(annotationType)
    annotationType = repmat({annotationType},numel(ids),1);
end
annotationType = columnVector(annotationType);

% the same for the qualifier
if ischar(annotationQualifier)
    annotationQualifier = repmat({annotationQualifier},numel(ids),1);
end
annotationQualifier = columnVector(annotationQualifier);




% if the databases are not registered with registry.org we do not allow
% them.
db2prefix = [{dbs.name};{dbs.prefix}];
if ~all(ismember(unique(databases),db2prefix))
    missing = setdiff(unique(databases),db2prefix);
    error('The following databases are not defined on identifiers.org:\n%s',strjoin(missing,'\n'));
else
    % we allow the names (full names) and convert them to the corresponding
    % prefixes.
    [dbpres,dbpos] = ismember(databases,db2prefix(1,:));    
    if printLevel > 0
        fprintf('Replaced the provided Names by the following prefixes:\n%s',strjoin(cellfun(@(x,y) strcat(x, {': '}, y), database(dbpres), db2prefix(2,dbpos(dbpres)), 'Uniform',0),'\n'));
    end
    databases(dbpres) = db2prefix(2,dbpos(dbpres)); %Replace the name by the prefix    
end

% if referenceField is empty, determine the relevant fields
usedFields = {};
annotateModel = false;
if isempty(referenceField)
    for field = 1:numel(baseFields)        
        if isfield(model,baseFields{field}) && any(ismember(model.(baseFields{field}),elementIDs))
            usedFields{end+1} = baseFields{field};
        end
    end        
else
    % if its not empty, check for model and reference.
    if strcmpi('model',referenceField)
        usedFields = {'model'};
        annotateModel = true;
    else
        if any(ismember(model.(referenceField),elementIDs))
            usedFields = {referenceField};
        end
    end    
end

% if usedFields is empty, there is no field that contains the IDs.
if isempty(usedFields)
    error('None of the provided IDs was found in any of the model fields');
end

% we will run through each annotation database. 
annotationQualifiers = unique(annotationQualifier);
udatabases = unique(databases);


if annotateModel
    % if we annotate a model, we need to check, whether its a biological or
    % a model qualifier
    uQualTypes = unique(annotationType);
    for type = 1:numel(uQualTypes)
        % check all qualifier types 
        cQualType = uQualTypes{type};
        relForType = strcmp(annotationType,cQualType);
        for db = 1:numel(udatabases)
            % and all databases
            cdb = udatabases(db);
            relForDB = strcmp(databases,cdb);
            identifiersDBPos = ismember({dbs.prefix},cdb);
            dbpattern = dbs(identifiersDBPos).pattern;
            % validate the identifiers used vs the patterns
            if any(cellfun(@(x) isempty(regexp(x,dbpattern)),ids(relForDB)))
                relIDs = ids(relForDB);
                invalidIDs = cellfun(@(x) isempty(regexp(x,dbpattern)),relIDs);
                error('The following IDs are invalid for database %s which requires this pattern (%s):\n%s',cdb{1},dbpattern,strjoin(relIDs(invalidIDs),'\n'));
            end
            for annotQual = 1:numel(annotationQualifiers)
                cQual = annotationQualifiers{annotQual};
                relForAnnot = strcmp(annotationQualifier,annotationQualifiers(annotQual));
                if ~any(relForType & relForDB & relForAnnot)
                    % this is not a valid combination of DB, Annotation and
                    % qualifier type, so skip it, don't add fields
                    continue
                end
                % now, build the field, if it does not exist.
                fieldName = getAnnotationFieldName('model',cdb,cQual);
                fieldName = regexprep(fieldName{1},'^model',['model' cQualType(1)]);
                annotation = unique(ids(relForDB & relForAnnot & relForType));
                % if the field does not exist or the annotation is supposed
                % to be replaced we simply recreate the field. otherwise we
                % join data from the field with the new annotation.
                if replaceAnnotation || ~isfield(model,fieldName)
                    model.(fieldName) = strjoin(annotation, '; ');
                else                    
                    model.(fieldName) = strjoin(union(strsplit(model.(fieldName),'; '),annotation),'; ');                        
                end
            end
        end
    end         
    return % we are done here.
else
    if any(strcmp(annotationQualifier,'model'))
        error('Model annotations can only be assigned to the model!');
    end
end



% get all relevant IDs


% now, we have to go through all base Fields
for field = 1 : numel(usedFields)
    % for each field that has the identifier
    cField = usedFields{field};
    relevantIDs = ismember(elementIDs,model.(cField));
    usedIDs = unique(elementIDs(relevantIDs));
    for db = 1:numel(udatabases)        
        % and each database
        cdb = udatabases(db);
        relForDB = strcmp(databases,cdb);
        identifiersDBPos = ismember({dbs.prefix},cdb);
        dbpattern = dbs(identifiersDBPos).pattern;
        % we first check, whether the provided ids are valid identifiers
        % for this database
        if any(cellfun(@(x) isempty(regexp(x,dbpattern)),ids(relForDB)))
            relIDs = ids(relForDB);
            invalidIDs = cellfun(@(x) isempty(regexp(x,dbpattern)),relIDs);
            error('The following IDs are invalid for database %s which requires this pattern (%s):\n%s',cdb{1},dbpattern,strjoin(relIDs(invalidIDs),'\n'));
        end        
        % and then collect all qualifier types to assign the respective
        % values.
        for annotQual = 1:numel(annotationQualifiers)
            cQual = annotationQualifiers{annotQual};
            relForAnnot = strcmp(annotationQualifier,annotationQualifiers(annotQual));
            % now, build the field, if it does not exist.
            fieldName = getAnnotationFieldName(cField(1:end-1),cdb,cQual);
            fieldName = fieldName{1};
            if ~isfield(model,fieldName)
                %The field is a simple cell array of strings.
                model = createEmptyFields(model,fieldName,{fieldName,cField,1,'iscell(x)','''''',0,'cell'});
            end
            % after the field is present, we will now built the current
            % annotation field.
            % for each relevant ID, we will set the respective position                        
            annotations = cellfun(@(x) unique(ids(relForDB & relForAnnot & strcmp(x,elementIDs))),usedIDs,'Uniform', 0);
            [idpres,idpos] = ismember(model.(cField),usedIDs);            
            if replaceAnnotation
                % if the annotation is replaced, we simply overwrite
                % existing information for those elements where we have new information.
                newAnnotation = cellfun(@(x) strjoin(x,'; '),annotations, 'Uniform',0);
                model.(fieldName)(idpres) = newAnnotation(idpos(idpres));
            else
                % otherwise we join the annotation identifiers using '; '
                % as collation string.
                newPos = idpos(idpres);
                combinedAnnotation = model.(fieldName)(idpres);                
                emptyAnnotations = cellfun(@isempty, combinedAnnotation);                               
                combinedAnnotation(emptyAnnotations) = cellfun(@(x) strjoin(x,'; '),annotations(newPos(emptyAnnotations)), 'Uniform', 0);
                combinedAnnotation(~emptyAnnotations) = cellfun(@(x,y) strjoin(union(strsplit(x,'; '),y),'; '),combinedAnnotation(~emptyAnnotations),annotations(newPos(~emptyAnnotations)),'Uniform',0);
                model.(fieldName)(idpres) = combinedAnnotation;
            end
        end
    end
end
        
        
end
    