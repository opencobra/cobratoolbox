function flag = isValidPrintFields(fields)
% Subroutine called by `surfNet` for validating the input for printFields
% (fields to be printed when calling surfNet)
%
% USAGE:
%    flag = isValidPrintFields(fields)
%
% INPUT:
%    fields:    field content from a COBRA model
%
% OUTPUT:
%    flag:      true if the content can be printed by surfNet

flag = false;
isCellString = @(x) iscellstr(x) || (exist('isstring', 'builtin') && isstring(x));
if ~(ischar(fields) || isCellString(fields)  || (numel(fields) == 2 && all(cellfun(isCellString, fields))))
    error(['Must be (1) a cell array of two cells, '...
        '1st cell being a character array for met fields and 2nd for rxn fields, ' ...
        'or (2) a character array of field names recognizable from the field names or the sizes.']);
else
    flag = true;
end

end