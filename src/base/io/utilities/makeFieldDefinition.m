function fieldDef = makeFieldDefinition(fieldName,xdim,ydim,fieldType,varargin)
% create a field definition cell array with some default values if nothing is provided
% USAGE:
%    fieldDef = makeFieldDefinition(fieldName,xdim,ydim,fieldType,varargin)
% 
% INPUTS:
%    fieldName:     The name of the defined field;
%    xdim:          The x-dimension (reference string or numeric value)
%    ydim:          The y-dimension (reference string or numeric value)
%    fieldType:     The type of the field ('numeric','cell','sparse',
%                   'char',sparselogical','struct')
%    varargin:      additional properties:
%                    * FBAField: true/(false);
%                    * LongName: char array (fieldName)
%                    * TypeField: true/(false)
%                    * BasicField: true/(false)
%                    * Validator: string to evaluate for validation (depends on fieldType)%                    
%                    * DefaultValue: (depends on fieldType)
%
% OUTPUT:
%    fieldDef:      A Cell array with the positions as defined in
%                   `getDefinedFieldProperties()`



switch fieldType
    % build defaults based on the field type
    case 'cell'
        defaultValidator = '@iscell(x)';
        defaultValue = {''};
    case 'char'
        defaultValidator = '@ischar(x)';
        defaultValue = ' ';
    case 'sparse'
        defaultValidator = '@issparse(x) && isnumeric(x)';
        defaultValue = 0;
    case 'logical'
        defaultValidator = '@islogical(x)';
        defaultValue = false;
    case 'sparselogical'
        defaultValidator = '@issparse(x) && islogical(x)';
        defaultValue = false;
    case 'numeric'
        defaultValidator = '@isnumeric(x)';
        defaultValue = 0;
    case 'double'
        defaultValidator = '@isnumeric(x)';
        defaultValue = 0;
    case 'struct'
        defaultValidator = '@isstruct(x)';
        defaultValue = struct();
    otherwise
        error('Field Type is invalid!');
end
parser = inputParser();
parser.addRequired('fieldName',@ischar);
parser.addRequired('xdim',@(x) ischar(x) || isnumeric(x));
parser.addRequired('ydim',@(x) ischar(x) || isnumeric(x));
parser.addRequired('fieldType',@ischar);

parser.addParameter('FBAField',false,@islogical);
parser.addRequired('LongName',fieldName,@ischar);
parser.addRequired('TypeField',false,@islogical);
parser.addRequired('BasicField',false,@islogical);
parser.addRequired('Validator',defaultValidator,@ischar);
parser.addRequired('defaultValue',defaultValue,@ischar);

% parse the inputs
parser.parse(fieldName,xdim,ydim,fieldType,varargin{:});

% fill the definition
fieldDef = cell(10,1);
fieldDef{1} = parser.Results.fieldName;
fieldDef{2} = parser.Results.xdim;
fieldDef{3} = parser.Results.ydim;
fieldDef{4} = parser.Results.Validator;
fieldDef{5} = parser.Results.defaultValue;
fieldDef{6} = parser.Results.BasicField;
fieldDef{7} = parser.Results.fieldType;
fieldDef{8} = parser.Results.FBAField;
fieldDef{9} = parser.Results.TypeField;
fieldDef{10} = parser.Results.LongName;

