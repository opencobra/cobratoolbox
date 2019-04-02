function model = addAnnotations(model, values, varargin)
% Set the annotations for a given set of IDs.
%
% USAGE:
%    model = setAnnotations(model, values, field, ids, database, varargin)
% 
% INPUTS:
%    model:         A COBRA style model structure
%    values:        The values of the given annotation. if the field is
%                   defined, these will be checked for validity.
%                   See the note for allowed options. 
% OPTIONAL INPUTS:
%    varargin:      Additional parameter/value pairs or a parameter struct
%                   to further specify the annotation, or add additional
%                   properties with the following parameters:
%                    * `annotationQualifier` - The bioql qualifier to retrieve the info for (Default: 'is')
%                    * `annotationType` - The type of the annotation. either 'bio' or 'model'. 'model' is only applicable if the referenceField is set to 'model'. Default('bio')
%                    * `replaceAnnotation` - replace any existing values for the given annotation (Default: false)
%                    * `ids` - The ids (or positions) of the elements for which to add/set annotations. If positions are given, the field parameter has to be set.
%                    * `referenceField` - the type field referenced (e.g. 'rxns', or 'mets'). If none is given, annotations will be assigned to all possible matching model ids.     
%                    * `database` - the database to retrieve data from (e.g. KEGG, BiGG etc) must be provided, if the values are not a struct. 
%                    * `annotationType` - the 
% OUTPUT:
%    model:         The model with the updated annotations
% 
% NOTE:
%       The input format of values can be either a cell array of strings,
%       or a cell array of cell arrays. In the former case multiple IDs are
%       separated by '; '. In the latter case, each cell in the cell array
%       contains exactly one ID.
%       If only a single value is set, the input values can also be a
%       single string, or a cell array of strings (for multiple IDs).
%       Finally, the annotations can be supplied as an sbml type struct
%       (with cvterms and corresponding specifications), as returned by
%       getAnnotations(). If this is given, 

baseFields = getCobraTypeFields();


parser = inputParser();
parser.addParameter('database','',@ischar);
parser.addParameter('ids','',@(x) iscell(x) || ischar(x) || isnumeric(x) || islogical(x));
parser.addParameter('referenceField','',@(x) isempty(x) || any(strcmpi(baseFields,x)) || strcmpi('model',x));
parser.addParameter('annotationType','bio',@(x) (ischar(x) && any(strcmpi(x,{'model','bio'}))));
parser.addParameter('annotationQualifier','is',@(x) ischar(x) );
parser.addParameter('replaceAnnotation',false,@(x) islogical(x) || (isnumeric(x) && (x == 1 || x == 0)));
parser.addParameter('printLevel',0,@isnumeric);
parser.parse(varargin{:});

% check the inputs for validity
if strcmp(parser.Results.annotationType,'model') && ~strcmp(parser.Results.referenceField,'model')
    error('Model Qualifiers can only be assigned to a model');
end
if isnumeric(parser.Results.ids) && isempty(parser.Results.referenceField)
    error('Numeric IDs are only acceptable if there is a referenced field')
end



% assign values
referenceField = parser.Results.referenceField;
% handle different types of IDs
ids = parser.Results.ids;
if ischar(ids)
    ids = {ids};
elseif islogical(ids) || isnumeric(ids)
    ids = model.(referenceField)(ids);
end

annotationType = repmat({parser.Results.annotationType},numel(ids),1);
annotationQualifier = repmat({parser.Results.annotationQualifier},numel(ids),1);
database = repmat({lower(parser.Results.database)},numel(ids),1);
replaceAnnotation = parser.Results.replaceAnnotation;
dbValues = values;

if isstruct(values)
    allids = {values.id};    
    ids = {};
    dbValues = {};
    database = {};
    annotationQualifier = {};
    annotationType = {};
    for i = 1:numel(allids)        
        cQuals = {values(i).cvterms.qualifier};
        cType = strrep({values(i).cvterms.qualifierType},'Qualifier','');
        for j = 1:numel(values(i).cvterms)            
            cdbs = {values(i).cvterms(j).ressources.database};
            database = [database, cdbs];
            dbValues = [dbValues,{values(i).cvterms(j).ressources.id}];
            ids = [ids,repmat(allids(i),1,numel(cdbs))];           
            annotationQualifier = [annotationQualifier, repmat(cQuals(j),1,numel(cdbs))];            
            annotationType = [annotationType, repmat(cType(j),1,numel(cdbs))];            
        end 
    end

else    
    
end


%now, add the annotations
model = addMIRIAMAnnotations(model,ids, database,dbValues,'annotationTypes',annotationType,...
                                'annotationQualifiers',annotationQualifier,'replaceAnnotation',replaceAnnotation,...
                                'referenceField',parser.Results.referenceField);
end