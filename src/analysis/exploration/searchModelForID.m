function results = searchModelForID(model,identifier,similarity)

%get fields to search for the identifier

if ~exist('similarity','var')
    similarity = 0.8;
end

%Basic fields:
baseFields = {'rxns','mets','vars','ctrs','genes','comps','prots'};
nameFields = regexprep(basicFields,'s$','Names');
knownFields = union(baseFields,nameFields);
dbFields = getDefinedFieldProperties('DataBaseFields',true);
knownFields = union(knownFields,dbFields(:,3));
annotationQualifiers = getBioQualifiers();
results = struct();
for field = 1:numel(baseFields)
    cField = baseFields{field};
    if ~isfield(model,cField)
        continue;
    end    
    modelFields = getModelFieldsForType(model,cField);
    resultList = cell(numel(model.(cField)),numel(modelFields));    
    for aqual = 1:numel(annotationQualifiers)  
       cAnnotType = regexprep(cField,'s$',annotationQualifiers{aqual});
       annotationsFields = modelfields(cellfun(@(x) strncmp(x,cAnnotType,length(cAnnotType)),modelfields));
    end
    for modelField = 1:numel(modelFields)
        cModelField = modelFields(modelField);
        if any(strcmp(cModelField,knownFields))
            isAnnotation = false;
            if strcmp(cModelField,'mets')
                if ~isempty(regexp(identifier,'\[[^\[]\]$'))
                    fieldToUse = regexprep(model.mets,'\[[^\[]\]$','');
                end
            else
                fieldToUse = model.(cModelField);
            end
        else      
            if any(strcmp(cModelField,annotationsFields))
                fieldToUse = model.(cModelField);
                isAnnotation = true;
            else
                %Field does nto match anything. don't search in it.
                continue 
            end
        end        
        [matchingIDs,positions] = findMatching(fieldToUse,identifier,isAnnotation,similarity);
        if ~isempty(positions)
            resultList(positions,modelField) = matchingIDs;
        end
    end
    if any(~cellfun(@isempty, resultList))
        results.(cfield) = struct();
        relRows = ~all(cellfun(@isempty,resulList),2);
        result.(cfield).id = '';        
        result.(cfield).matches = '';
        result.(cfield)(sum(relRows)).id = '';
        relResults = resultList(relRows,:);
        relResultPos = find(relRows);
        for result = 1:size(relResults,1)
            result.(cfield).id = model.(cField){relResultPos(result)};
            result.(cfield).matches = struct();
            %Init struct with size
            result.(cfield).matches.fields = ''
            result.(cfield).matches.values = ''
            
            
           
        end
    end 
end
         
        

