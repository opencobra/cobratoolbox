function o = setField(o, value)
% Copy matching fields from a source struct/object into a template struct
%
% USAGE:
%
%    o = setField(o, value)
%
% INPUTS:
%    o:          template structure whose field names determine what is copied
%    value:      structure or object supplying the new field values
%
% OUTPUTS:
%    o:          `o` with each field also present in `value` overwritten from `value`

key = fieldnames(o);
for i = 1:length(key)
   if isfield(value, key{i}) || isprop(value, key{i})
      o.(key{i}) = value.(key{i});
   end
end

end