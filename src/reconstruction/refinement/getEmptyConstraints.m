function emptyConstraints = getEmptyConstraints(model)
% Get a list of empty constraints (i.e. constraints that have no non-zero
% values.
%
% USAGE:
%
%    emptyConstraints = getEmptyConstraints(model)
%
% INPUTS:
%    model:                 model structure with fields:
%
%                             * .C - `ctrs x n` additional constraints matrix
%                             * .D - `ctrs x evars` coupling matrix between extra variables and constraints
%                             * .ctrs - `ctrs x 1` cell array of constraint identifiers
%
% OUTPUT:
%    emptyConstraints:      A list of IDs of empty constraints.
%
% .. Author:
%       Thomas Pfau - Sep 2018

if ~isfield(model,'C')
    emptyConstraints = [];
    return
end

emptyConstraints = sum(model.C ~= 0,2) == 0;
if isfield(model, 'evars')
    emptyConstraints = emptyConstraints & sum(model.D ~= 0,2) == 0;
end

emptyConstraints = model.ctrs(emptyConstraints);

    