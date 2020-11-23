function printConstraints(model, minInf, maxInf, rxnBool, modelAfter)
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

if ~exist('modelAfter','var')
    minConstraints = model.lb > minInf & model.lb~=0 & rxnBool;
    if ~any(minConstraints)
        fprintf('%s\n','No non-default maximum constraints.');
    else
        fprintf('%s\n', 'Table of minimum constraints:');
        T = table(model.rxns(minConstraints),model.rxnNames(minConstraints),model.lb(minConstraints),model.ub(minConstraints),'VariableNames',{'Reaction','Name','lb','ub'});
        disp(T);
    end
    
    maxConstraints = model.ub < maxInf & model.ub~=0 & rxnBool;
    if ~any(maxConstraints)
        fprintf('%s\n','No non-default maximum constraints.');
    else
        fprintf('%s\n','Table of maximum constraints:');
        T = table(model.rxns(maxConstraints),model.rxnNames(maxConstraints),model.lb(maxConstraints),model.ub(maxConstraints),'VariableNames',{'Reaction','Name','lb','ub'});
        disp(T);
    end
    fprintf('\n');
else
    minConstraints = model.lb > minInf & model.lb~=0 & rxnBool;
    if ~any(minConstraints)
        fprintf('%s\n','No non-default maximum constraints.');
    else
        fprintf('%s\n','Table of minimum constraints:');
        T = table(model.rxns(minConstraints),model.rxnNames(minConstraints),model.lb(minConstraints),modelAfter.lb(minConstraints),model.ub(minConstraints),modelAfter.ub(minConstraints),'VariableNames',{'Reaction','Name','lb_before','lb_after','ub_before','ub_after'});
        disp(T);
    end
    
    maxConstraints = model.ub < maxInf & model.ub~=0 & rxnBool;
    if ~any(maxConstraints)
        fprintf('%s\n','No non-default maximum constraints.');
    else
        fprintf('%s\n','Table of maximum constraints:');
        T = table(model.rxns(maxConstraints),model.rxnNames(maxConstraints),model.lb(maxConstraints),modelAfter.lb(maxConstraints),model.ub(maxConstraints),modelAfter.ub(maxConstraints),'VariableNames',{'Reaction','Name','lb_before','lb_after','ub_before','ub_after'});
        disp(T);
    end
    fprintf('\n');
end