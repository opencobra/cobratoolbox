function searchModelForID(model,identifier)

%get fields to search for the identifier

%Basic fields:
baseFields = {'rxns','mets','vars','ctrs','genes','comps','prots'};
nameFields = regexprep(basicFields,'s$','Names');
annotationQualifiers = getBioQualifiers();

for field = 1:numel(baseFields)
    cField = baseFields{field};
    modelFields = getModelFieldsForType(model,cField);
    for modelField = 1:numel(modelFields)
        cModelField = modelFields(modelField);
        if strcmp(cModelField,cField)
        end
    end
end

            

            
function matchingIDs = findMatching(field,identifier)
    if length(identifier) < 4 %Only look for perfect matches - case independent.
        relVals = ~cellfun(@(x) isempty(strfind(lower(x),lower(identifier))),field);
    else
        %if its a longer query, check fr
    


function d = lev(s,t)
% Levenshtein distance between strings or char arrays.
% lev(s,t) is the number of deletions, insertions,
% or substitutions required to transform s to t.
% https://en.wikipedia.org/wiki/Levenshtein_distance

    s = char(s);
    t = char(t);
    m = length(s);
    n = length(t);
    distanceMatrix = zeros(m+1,n+1);
    for i = 1:n
        for j = 1:m
            
        end
    end
end

function dist = simDistance(a,b,edgePos)
    charequal = lower(a) == lower(b);    
    capEqual = a == b;
    replaceCost = 
    dist = ~(a==b);
    if edgePos
end
