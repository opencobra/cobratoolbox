function mappedFields = mapAnnotationsToFields(model,databases,identifiers,relations,field,relationSelection, inverseRelationSelection)
%MAPANNOTATIONSTOFIELDS maps annotations in bioql/MIRIAM annotation from SBML to model fields.
%
% USAGE:
%
%    mappedFields = mapAnnotationsToFields(model,databases,identifiers,relations,field,relationSelection, exclusiveSelection)
%
% INPUT:
%
%    model:        the COBRA model to annotate
%    databases:    a cell array of cell arrays containing databases
%    identifiers:  a cell array of cell arrays containing the identifiers
%                  associated with the databases above
%    relations:    a cell array of cell arrays containing the bioql relations
%                  associated with the databases above
%    field:        the model field (met/gene/rxn/protein/comp etc) to
%                  annotate. Note that there is an s missing here.
% OPTIONAL INPUT:
%
%    relationSelection:            whether only a specific relation is choosen
%                                  and all others are ignored (default {})
%    inverseRelationSelection:     whether the relation specified by
%                                  relationSelection is inverted (i.e. all
%                                  other fields are used (default true))
%
% OUTPUT:
%
%    mappedFields:         a struct with fields for each encountered
%                          annotation database (Known databases like e.g.
%                          HMDB will be mapped to their corresponding field
%                          metHMDBID, while unknown fields will be mapped
%                          to: [field relation convertSBMLID(database)]
%
% .. Authors:
%       - Thomas Pfau May 2017 

if~exist('relationSelection','var')
    relationSelection = {};
end
if ~exist('inverseRelationSelection','var')
    inverseRelationSelection = true;
end
%All fields need to be initialized with the same size.
%Now, get all known mappings from databases to model fields. (knownMappings
%is a cell array of typedb, relation  triplets.
knownMappings = getDatabaseMappings(field);


%Not sure, whether we can transform this to a cellfun, but at the moment, I
%doubt it...
[fieldNames,dbIDs,rels] = cellfun(@(db,rel)getAnnotationFieldName(field,db,rel, relationSelection, ~inverseRelationSelection), databases',relations','Uniform',0);
modelFields = [vertcat(dbIDs{:}),vertcat(fieldNames{:}),vertcat(rels{:})];
%Create ids with relations to cpature everything.
uid = strcat(modelFields(:,1),modelFields(:,3));
[~,pos] = unique(uid);
dbFields = modelFields(pos,:);
fieldsToBuild = unique(modelFields(pos,2));

%Create the annotation fields in the model Structure.
for modelField = 1:numel(fieldsToBuild)    
    model.(fieldsToBuild{modelField}) = cellfun(@(db,rel, ids) fillField(fieldsToBuild{modelField},dbFields,db,rel,ids), databases, relations, identifiers,'UniformOutput',0);
    model.(fieldsToBuild{modelField}) = columnVector(model.(fieldsToBuild{modelField}));
end

mappedFields = model;
end


function field = fillField(fieldName, dbFields, databases,relations,identifiers)
dbs = ismember(dbFields(:,2),fieldName);
matchingentries = cellfun(@(db,rel) any(ismember(dbFields(dbs,1),db) & ismember(dbFields(dbs,3),rel)), databases,relations);
field = strjoin(identifiers(matchingentries),'; ');
end
            
function [idstring] = getID(databases,relations,ids,currentDB,relation)
    idstring = strjoin(ids(ismember(databases,currentDB) & ismember(relations,relation)),'; ');
end
