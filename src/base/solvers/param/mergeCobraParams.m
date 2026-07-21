function param = mergeCobraParams(param1, param2)
% Merge the structures with preference to param1 fields over param2 fields
%
% USAGE:
%
%    param = mergeCobraParams(param1, param2)
%
% INPUTS:
%    param1:    Structure whose fields take precedence on overlap
%    param2:    Structure providing the base set of fields
%
% OUTPUTS:
%    param:     Structure containing all fields of `param2`, with any
%               fields also present in `param1` overwritten by `param1`

param = param2;  % Start with the first structure
fields = fieldnames(param1);  % Get the field names of the second structure
for i = 1:numel(fields)
    param.(fields{i}) = param1.(fields{i});  % struct2 values will overwrite struct1 values if overlap occurs
end

end

