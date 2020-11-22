function printConstraints(model, minInf, maxInf, rxnBool)
% Print all network constraints that are not `-Inf (minInf)` or `+Inf (maxInf)`
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

if ~exist('rxnBool','var')
    rxnBool=true(size(model.S,2),1);
end

minConstraints = model.lb > minInf & model.lb~=0 & rxnBool;

if ~any(minConstraints)
    fprintf('No non-default maximum constraints.\n');
else
    fprintf('Table of minimum constraints:\n');
    T = table(model.rxns(minConstraints),model.rxnNames(minConstraints),model.lb(minConstraints),model.ub(minConstraints),'VariableNames',{'Reaction','Name','lb','ub'});
   disp(T);
end

maxConstraints = model.ub < maxInf & model.ub~=0 & rxnBool;
if ~any(maxConstraints)
    fprintf('No non-default maximum constraints.\n');
else
    fprintf('Table of maximum constraints:\n');
    T = table(model.rxns(maxConstraints),model.rxnNames(maxConstraints),model.lb(maxConstraints),model.ub(maxConstraints),'VariableNames',{'Reaction','Name','lb','ub'});
    disp(T);
end
fprintf('\n');