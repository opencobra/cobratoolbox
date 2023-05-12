function x = getField(o, field, default)
if isfield(o, field)
   x = o.(field);
else
   x = default;
end