function param = mergeCobraParams(param1,param2)
% Merge the structures with preference to param1 fields over param2 fields

param = param2;  % Start with the first structure
fields = fieldnames(param1);  % Get the field names of the second structure
for i = 1:numel(fields)
    param.(fields{i}) = param1.(fields{i});  % struct2 values will overwrite struct1 values if overlap occurs
end

end

