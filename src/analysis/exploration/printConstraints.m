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

reversibleRxnBool = model.lb > minInf & model.lb~=0 & model.ub < maxInf & model.ub~=0 & rxnBool;
fwdRxnBool = model.lb > minInf & model.lb~=0 & ~reversibleRxnBool & rxnBool;
revRxnBool = model.ub < maxInf & model.ub~=0 & ~reversibleRxnBool & rxnBool;

if ~any(fwdRxnBool)
    fprintf('%s\n','No forward reactions with non-default constraints.');
else
    fprintf('%s\n', 'Table of forward reactions with non-default constraints:');
    if exist('modelAfter','var')
        T = table(model.rxns(fwdRxnBool),model.rxnNames(fwdRxnBool),model.lb(fwdRxnBool),modelAfter.lb(fwdRxnBool),model.ub(fwdRxnBool),modelAfter.ub(fwdRxnBool),'VariableNames',{'Reaction','Name','lb_before','lb_after','ub_before','ub_after'});
    else
        T = table(model.rxns(fwdRxnBool),model.rxnNames(fwdRxnBool),model.lb(fwdRxnBool),model.ub(fwdRxnBool),'VariableNames',{'Reaction','Name','lb','ub'});
    end
    disp(T);
end

if ~any(revRxnBool)
    fprintf('%s\n','No  reverse reactions with non-default constraints.');
else
    fprintf('%s\n','Table of reverse reactions with non-default constraints:');
    if exist('modelAfter','var')
        T = table(model.rxns(revRxnBool),model.rxnNames(revRxnBool),model.lb(revRxnBool),modelAfter.lb(revRxnBool),model.ub(revRxnBool),modelAfter.ub(revRxnBool),'VariableNames',{'Reaction','Name','lb_before','lb_after','ub_before','ub_after'});
    else
        T = table(model.rxns(revRxnBool),model.rxnNames(revRxnBool),model.lb(revRxnBool),model.ub(revRxnBool),'VariableNames',{'Reaction','Name','lb','ub'});
    end
    disp(T);
end

if ~any(reversibleRxnBool)
    fprintf('%s\n','No  reversible reactions with non-default constraints.');
else
    fprintf('%s\n','Table of reversible reactions with non-default constraints:');
    if exist('modelAfter','var')
        T = table(model.rxns(reversibleRxnBool),model.rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),modelAfter.lb(reversibleRxnBool),model.ub(reversibleRxnBool),modelAfter.ub(reversibleRxnBool),'VariableNames',{'Reaction','Name','lb_before','lb_after','ub_before','ub_after'});
    else
        T = table(model.rxns(reversibleRxnBool),model.rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),model.ub(reversibleRxnBool),'VariableNames',{'Reaction','Name','lb','ub'});
    end
    disp(T);
end

fprintf('\n');
