function defaultValues = getDefaultsForField(model,  referenceField, varargin)
% Get default values for all elements in a model for a specified field. We
% will assume, that the field is a column vector
% USAGE:
%    defaultValues = getDefaultsForField(model, fieldName, referenceField, fieldType)
%
% INPUT:
%    model:                 A COBRA style model
%    referenceField:        The type field this field references.
%    varargin:              Parameter/Value pairs. 
%                            * `fieldName` if the fieldname is part of the defined field properties, the defaults from there will be used.
%                            * `fieldType` if a field type is given, the basic defaults for that field type will be used.
%
% OUTPUT:
%    defaultValues:         A vector of default values for the given field.
%
% NOTE:
%    if both fieldName and fieldType are given, fieldName will take
%    precedence if it is a defined field, otherwise it will be ignored.

parser = inputParser();
parser.addParameter('fieldName','',@ischar);
parser.addParameter('fieldType','',@ischar);

parser.parse(varargin{:});
    
if all(ismember({'fieldName','fieldType'}, parser.UsingDefaults))
    error('Either a fieldName or a field type is needed to build a default');
end

if ~ismember('fieldName',parser.UsingDefaults)    
    % So, we have a field name, try to use it.
    try        
        fieldDefinition = getDefinedFieldProperties('specificFields',{parser.Results.fieldName});   
    catch
        % if it does not exist, we will use a basic default again.
        fieldDefinition = makeFieldDefinition(parser.Results.fieldName,referenceField,1,parser.Results.fieldType);
    end
else
    % so we only got the field type
    fieldDefinition = makeFieldDefinition('NewField',referenceField,1,parser.Results.fieldType);
end
% just create the empty field.
model = createEmptyFields(model,fieldDefinition{1},fieldDefinition);
% and return it.
defaultValues = model.(fieldDefinition{1});

