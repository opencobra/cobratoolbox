function printConstraints(model, minInf, maxInf, rxnBool, modelAfter, printLevel)
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
% OPTIONAL INPUTS:
%   modelAfter: model after some perturbation to the bounds
%   printLevel:
%

% .. Authors:
%       - Ines Thiele 02/09, Ronan Fleming 2020

if ~exist('rxnBool','var')
    rxnBool=true(size(model.S,2),1);
end
if ~exist('printLevel','var')
    printLevel=1;
end
if exist('modelAfter','var')
    if isempty(modelAfter)
        clear modelAfter
    end
end

if ischar(rxnBool) || iscell(rxnBool)
    rxnBool = ismember(model.rxns,rxnBool);
end

closedRxnBool = model.lb == model.ub & model.lb==0 & rxnBool;
reversibleRxnBool = model.lb > minInf & model.lb<0 & model.ub < maxInf & model.ub>0 & rxnBool;
fwdRxnBool = model.lb > minInf & model.lb>=0 & ~reversibleRxnBool & rxnBool & model.ub~=maxInf;
revRxnBool = model.lb~=minInf & model.ub < maxInf & model.ub<=0 & ~reversibleRxnBool & rxnBool;

rxnNames=model.rxnNames;
for j=1:size(model.S,2)
    rxnNames{j}=rxnNames{j}(1:min(60,length(rxnNames{j})));
end

if ~any(closedRxnBool)
    if printLevel>0
        fprintf('%s\n','No closed reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n', ['...closed reaction constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(closedRxnBool),rxnNames(closedRxnBool),model.lb(closedRxnBool),modelAfter.lb(closedRxnBool),model.ub(closedRxnBool),modelAfter.ub(closedRxnBool),printRxnFormula(model, 'rxnAbbrList',model.rxns(closedRxnBool),'printFlag',0),'VariableNames',{'Closed_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(closedRxnBool),rxnNames(closedRxnBool),model.lb(closedRxnBool),model.ub(closedRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(closedRxnBool),'printFlag',0),'VariableNames',{'Closed_reaction','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(fwdRxnBool)
    if printLevel>0
        fprintf('%s\n','No forward reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n', ['...forward reactions with non-[0, ' num2str(maxInf) '] constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(fwdRxnBool),rxnNames(fwdRxnBool),model.lb(fwdRxnBool),modelAfter.lb(fwdRxnBool),model.ub(fwdRxnBool),modelAfter.ub(fwdRxnBool),printRxnFormula(model, 'rxnAbbrList',model.rxns(fwdRxnBool),'printFlag',0),'VariableNames',{'Forward_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(fwdRxnBool),rxnNames(fwdRxnBool),model.lb(fwdRxnBool),model.ub(fwdRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(fwdRxnBool),'printFlag',0),'VariableNames',{'Forward_Reaction','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(revRxnBool)
    if printLevel>0
        fprintf('%s\n','No reverse reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n',['...reverse reactions with non-[' num2str(minInf)  ', 0]  constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(revRxnBool),rxnNames(revRxnBool),model.lb(revRxnBool),modelAfter.lb(revRxnBool),model.ub(revRxnBool),modelAfter.ub(revRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBool),'printFlag',0),'VariableNames',{'Reverse_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(revRxnBool),rxnNames(revRxnBool),model.lb(revRxnBool),model.ub(revRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBool),'printFlag',0),'VariableNames',{'Reverse_Reaction','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(reversibleRxnBool)
    if printLevel>0
        fprintf('%s\n','No reversible reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n',['...reversible reactions with non-[' num2str(minInf)  ', ' num2str(maxInf) ']  constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(reversibleRxnBool),rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),modelAfter.lb(reversibleRxnBool),model.ub(reversibleRxnBool),modelAfter.ub(reversibleRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(reversibleRxnBool),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(reversibleRxnBool),rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),model.ub(reversibleRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(reversibleRxnBool),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb','ub','equation'});
    end
    disp(T);
end

fprintf('\n');
