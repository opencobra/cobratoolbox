function o = setField(o, value)
% o = setField(o, source)
% For each field of o such that it is a field in source,
% we set o.(field) = source.(field)

key = fieldnames(o);
for i = 1:length(key)
   if isfield(value, key{i}) || isprop(value, key{i})
      o.(key{i}) = value.(key{i});
   end
end

end