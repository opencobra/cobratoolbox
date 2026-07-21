function x = getField(o, field, default)
% Return the value of a struct field, or a default when the field is absent
%
% USAGE:
%
%    x = getField(o, field, default)
%
% INPUTS:
%    o:          structure to query
%    field:      char, name of the field to read
%    default:    value returned when `o` has no field named `field`
%
% OUTPUTS:
%    x:          the value of `o.(field)` if present, otherwise `default`
%

if isfield(o, field)
   x = o.(field);
else
   x = default;
end