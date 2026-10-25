function value = resolvePickleProxies(value)
% Converts the list proxies used by `readPythonPickle` into column cell
% arrays, recursively. Python lists and sets are built in proxies
% (`containers.Map` objects with double keys 1, 2, ..., which are handle
% objects) so that objects referenced several times in a pickle (shared
% references) receive the items appended after they were memoized.
%
% USAGE:
%
%    value = resolvePickleProxies(value)
%
% INPUT:
%    value:    MATLAB representation of a pickled object, possibly with list
%              proxies (also inside cell arrays, structures and
%              dictionaries, i.e. `containers.Map` objects with char keys)
%
% OUTPUT:
%    value:    the same object with the proxies replaced by column cell
%              arrays
%
% EXAMPLE:
%
%    data = resolvePickleProxies(stack{end});
%
% NOTE:
%
%    Dictionaries are modified in place (they are handle objects).
%
% .. Author: - Sebastián N. Mendoza, 21/10/2026

if nargin < 1
    error('value must be provided.');
end
if isa(value, 'containers.Map')
    if strcmp(value.KeyType, 'double')
        % list proxy: items in the order of their keys
        value = values(value, num2cell(1:value.Count))';
        for i = 1:numel(value)
            value{i} = resolvePickleProxies(value{i});
        end
    else
        mapKeys = keys(value);
        for i = 1:numel(mapKeys)
            value(mapKeys{i}) = resolvePickleProxies(value(mapKeys{i}));
        end
    end
elseif iscell(value)
    for i = 1:numel(value)
        value{i} = resolvePickleProxies(value{i});
    end
elseif isstruct(value) && isscalar(value)
    fields = fieldnames(value);
    for i = 1:numel(fields)
        value.(fields{i}) = resolvePickleProxies(value.(fields{i}));
    end
end
end
