function printConstraints(model, minInf, maxInf)
% Print all network constraints that are not -Inf (minInf)or +Inf (maxInf)
%
% USAGE:
%
%    printConstraints(model, minInf, maxInf)
%
% INPUTS:
%    model:     COBRA model structure
%    minInf:    value that is considered as -Inf (or desired minimum cutoff value)
%    maxInf:    value that is considered as +Inf (or desired maximum cutoff value)
%
% .. Authors:
%       - Ines Thiele 02/09

minConstraints = intersect(find(model.lb > minInf), find(model.lb));
fprintf('MinConstraitns:\n');
for i = 1:length(minConstraints)
    fprintf('%s', model.rxns{minConstraints(i)});
    fprintf('\t');
    fprintf('%e', model.lb(minConstraints(i)));
    fprintf('\n');
end

maxConstraints = intersect(find(model.ub < maxInf), find(model.ub));
fprintf('maxConstraints:\n');
for i = 1:length(maxConstraints)
    fprintf('%s', model.rxns{maxConstraints(i)});
    fprintf('\t');
    fprintf('%e', model.ub(maxConstraints(i)));
    fprintf('\n');
end
