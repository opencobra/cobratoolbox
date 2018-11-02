function model = createEmptyFields(model,fieldNames, fieldDefinitions)
% Create the specified model field with its default values. Works only for
% fields defined in the toolbox if fieldDefinitions are not supplied.
%
% USAGE:
%    model = createEmptyFields(model,fieldName, fieldDefinitions)
%
% INPUTS:
%
%    model:                 The model to add a field to
%    fieldNames:            The names of the fields to add.
%
% OPTIONAL INPUTS:
%    fieldDefinitions:      The Specifications of the field. Only necessary
%                           if a field which is not defined yet should be
%                           added.
%
% OUTPUTS:
%
%    model:                 The original model struct with the specified
%                           field added.
%
% Author:
%    Thomas Pfau Nov 2017

if ischar(fieldNames)
    fieldNames = {fieldNames};
end

if ~exist('fieldDefinitions','var') || isempty(fieldDefinitions)
    fieldDefinitions = getDefinedFieldProperties('SpecificFields',fieldNames);
end

if isempty(fieldDefinitions)
    error('Supplied Field name invalid.')
end
for field = 1:length(fieldNames)
    %Get the dimensions
    xdim = fieldDefinitions{field,2};
    ydim = fieldDefinitions{field,3};
    
    %And adjust if necessary
    if isnan(xdim)
        xdim = 1;
    end
    
    %If its listed as a char, it refers to a field (and the first dimension
    %of that field)
    if ischar(xdim)
        if isfield(model,xdim)
            xdim = size(model.(xdim),1);
        else
            xdim = 0;
        end
    end
    
    if isnan(ydim)
        ydim = 1;
    end
    
    %If its listed as a char, it refers to a field (and the first dimension
    %of that field)
    if ischar(ydim)
        if isfield(model,ydim)
            ydim = size(model.(ydim),1);
        else
            ydim = 0;
        end
    end
    
    %Get the field definitions
    fieldType = fieldDefinitions{field,7};
    defaultValue = fieldDefinitions{field,5};    
    %define i, for checks relating to model fields which have non ''
    %defaults
    i = 1;    
    switch fieldType
        case 'sparse'
            model.(fieldNames{field}) = sparse(xdim,ydim);            
        case 'cell'
            model.(fieldNames{field}) =cell(xdim,ydim);
            % need to both check, whether the eval is a char AND if it is empty.
            if xdim > 0 && ischar(eval(defaultValue)) && strcmp(eval(defaultValue),'') 
                model.(fieldNames{field})(:) = {''};
            else
                for i = 1:xdim
                    eval(['currentvalue = ' defaultValue ';' ]);
                    model.(fieldNames{field}){i} = currentvalue;
                end
            end
        case 'numeric'
            model.(fieldNames{field}) = repmat(defaultValue,xdim,ydim);            
        case 'sparselogical'
            model.(fieldNames{field}) = sparse(repmat(logical(defaultValue),xdim,ydim));            
        case 'char'
            model.(fieldNames{field}) = repmat(defaultValue,xdim,ydim);            
    end
end
