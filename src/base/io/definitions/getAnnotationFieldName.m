function [fieldNames,dbIDs,relations] = getAnnotationFieldName(annotatedField,database,annotationQualifier, qualifierSelection, invertSelection)
% Get the cobra field corresponding to the given database for the annotion
% Qualifier and the given annotated field.
%
% USAGE:
%    fieldName = getAnnotationFieldName(annotatedField,database,annotationQualifier)
%
% INPUTS:
%    annotationFields:           The base field that is being annotated
%                                (e.g. 'rxns', 'model', 'comps', ...)
%    databases:                  The database names of the annotation. (e.g.
%                                kegg)
%    annotationQualifiers:       The annotation qualifier (see
%                                http://co.mbine.org/standards/qualifiers for possible qualifiers)
%
% OPTIONAL INPUTS:
%    qualifierSelection:         Exclude the qualifiers from mappings (default: {}).
%    invertSelection:            Invert the qualifierSelection i.e. use
%                                only those specified (default: false);
%
% OUTPUT:
%    fieldNames:                 The name of the field corresponding to the
%                                given annotation.
%    dbIDs:                      A Cell array with the DB IDs 
%    relations:                  The relations the field has with the db
%                                names (for defined fields, this can be a
%                                multiple tpes separated by ';'


if ~exist('qualifierSelection','var')
    qualifierSelection = {};
end

if ~exist('invertSelection','var')
    invertSelection = false;
end

knownMappings = getDatabaseMappings(annotatedField);

%function map = getMappingInfo(db,rel,knownMappings,field, excludeAnnotationType,inverseRelationSelection)
%Get mapping, and missing fields.
%repeat relations, this is a set of cvterms all under one qualifier
[mapping] = ismember(knownMappings(:,1),database) & ...
            ismember(knownMappings(:,2),annotationQualifier) & ...
            ~(ismember(knownMappings(:,2),qualifierSelection) ~=invertSelection) ;
[inverseMapping] = ismember(database,knownMappings(:,1)) &...
                   ismember(annotationQualifier,knownMappings(:,2) )|...
                   (ismember(annotationQualifier,qualifierSelection) ~=invertSelection);
fieldNames = [knownMappings(mapping,3);convertDBID(database(~inverseMapping),annotationQualifier(~inverseMapping),annotatedField)];
dbIDs = [knownMappings(mapping,1);database(~inverseMapping)];
relations = [knownMappings(mapping,2);annotationQualifier(~inverseMapping)];
  
   
end


function fieldID = convertDBID(dbid,relation,field)
% Convert dbID and a relation to a field name. 

fieldID = convertSBMLID(dbid);
fieldID = strcat(relation,fieldID);
fieldID = strcat(field,fieldID);
fieldID = strcat(fieldID,'ID');
end