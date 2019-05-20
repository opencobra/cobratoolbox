
function defValue = getDefaultValue(value)
% get the default value for a given value (NaN for numeric, empty strings for textual, false for logical)
% USAGE:
%    defValue = getDefaultValue(value)
%
% INPUT:
%    value:     The value to get a default for
%
% OUTPUT:
%    defValue:    The default value for the given values type.

    if isnumeric(value)
        valClass = class(value);
        defValue = cast(NaN,valClass);
        defValue = repmat(defValue,size(value));
    elseif isstring(value)
        defValue = string('');
    elseif ischar(value)
        defValue = '';
    elseif islogical(value)
        defValue = false;
        defValue = repmat(defValue,size(value));
    elseif iscell(value)
        % recursive use, get the default for each element of the cell
        % array.
        defValue = cellfun(@(x) getDefaultValue(x),value,'Uniform',false);
    end
end
