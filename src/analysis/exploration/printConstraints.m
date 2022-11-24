function printConstraints(model, minInf, maxInf, rxnSelection, modelAfter, printLevel)
% Print all network constraints that are between `-Inf (minInf)` or `+Inf
% (maxInf) inclusive` 
%
% USAGE:
%
%    printConstraints(model, minInf, maxInf)
%
% INPUTS:
%    model:     COBRA model structure
%
% OPTIONAL INPUTS:
%   minInf:       value that is considered as -Inf (or desired minimum cutoff value)
%   maxInf:       value that is considered as +Inf (or desired maximum cutoff value)
%   rxnSelection: boolean vector or cell array of reaction abbreviations for the reactions to be printed
%   modelAfter:   model after some perturbation to the bounds
%   printLevel:
%

% .. Authors:
%       - Ines Thiele 02/09, Ronan Fleming 2020

if ~exist('minInf','var')|| isempty(minInf)
    minInf=-Inf;
end
if ~exist('maxInf','var') || isempty(maxInf)
    maxInf=Inf;
end
if ~isfield(model,'S')
    if isfield(model,'A')
        model.S = model.A(ismember(model.csense,'E'),:);
        model.dsense = model.csense(~ismember(model.csense,'E'));
        model.csense = model.csense(ismember(model.csense,'E'));
        model.C = model.A(~ismember(model.csense,'E'),:);
    else
        error('model.S missing')
    end
end
if ~exist('rxnSelection','var')
    rxnSelection=true(size(model.S,2),1);
end
if ~exist('printLevel','var')
    printLevel=0;
end
if exist('modelAfter','var')
    if isempty(modelAfter)
        clear modelAfter
    end
end

if ischar(rxnSelection) || iscell(rxnSelection)
    rxnSelection = ismember(model.rxns,rxnSelection);
end

if ~any(rxnSelection)
    return
end

closedRxnBool = model.lb == model.ub & model.lb == 0 & rxnSelection;
reversibleRxnBool = model.lb >= minInf & model.lb < 0 & model.ub <= maxInf & model.ub > 0 & rxnSelection;
%Forward and reverse reactions with NON-ZERO bounds
fwdRxnBoolNon0b = model.lb >= minInf & model.lb > 0 & ~reversibleRxnBool & ~closedRxnBool & model.ub <= maxInf & rxnSelection;
revRxnBoolNon0b = model.lb >= minInf & model.ub <= maxInf & model.ub < 0 & ~reversibleRxnBool & ~closedRxnBool & rxnSelection;
%Forward and reverse reactions with ZERO bounds (standard)
fwdRxnBool0b = model.lb >= minInf & model.lb == 0 & ~reversibleRxnBool & ~closedRxnBool & model.ub <= maxInf & rxnSelection;
revRxnBool0b = model.lb >= minInf & model.ub <= maxInf & model.ub == 0 & ~reversibleRxnBool & ~closedRxnBool & rxnSelection;


if ~any(closedRxnBool | reversibleRxnBool | fwdRxnBool0b | revRxnBool0b | fwdRxnBoolNon0b | revRxnBoolNon0b)
    boolRemainder = rxnSelection & ~(closedRxnBool | reversibleRxnBool | fwdRxnBool | revRxnBool);
    warning('no subset with bounds between [minInf maxInf]')
else
    boolRemainder=0;
end

if any(closedRxnBool & reversibleRxnBool) || any(closedRxnBool & fwdRxnBool0b) || any(closedRxnBool & revRxnBool0b) || any(fwdRxnBool0b & revRxnBool0b)
    warning('inconsistent boolean variables')
end

if isfield(model,'rxnNames')
rxnNames=model.rxnNames;
else
    rxnNames=cell(size(model.S,2),1);
end
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

if ~any(fwdRxnBool0b)
    if printLevel>0
        fprintf('%s\n','No forward reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n', ['...forward reactions with non-[0, ' num2str(maxInf) '] constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(fwdRxnBool0b),rxnNames(fwdRxnBool0b),model.lb(fwdRxnBool0b),modelAfter.lb(fwdRxnBool0b),model.ub(fwdRxnBool0b),modelAfter.ub(fwdRxnBool0b),printRxnFormula(model, 'rxnAbbrList',model.rxns(fwdRxnBool0b),'printFlag',0),'VariableNames',{'Forward_Reaction, 0 bound','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(fwdRxnBool0b),rxnNames(fwdRxnBool0b),model.lb(fwdRxnBool0b),model.ub(fwdRxnBool0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(fwdRxnBool0b),'printFlag',0),'VariableNames',{'Forward_Reaction, 0 bound','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(revRxnBool0b)
    if printLevel>0
        fprintf('%s\n','No reverse reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n',['...reverse reactions with non-[' num2str(minInf)  ', 0]  constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(revRxnBool0b),rxnNames(revRxnBool0b),model.lb(revRxnBool0b),modelAfter.lb(revRxnBool0b),model.ub(revRxnBool0b),modelAfter.ub(revRxnBool0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBool0b),'printFlag',0),'VariableNames',{'Reverse_Reaction, 0 bound','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(revRxnBool0b),rxnNames(revRxnBool0b),model.lb(revRxnBool0b),model.ub(revRxnBool0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBool0b),'printFlag',0),'VariableNames',{'Reverse_Reaction, 0 bound','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(fwdRxnBoolNon0b)
    if printLevel>0
        fprintf('%s\n','No forward reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n', ['...forward reactions with non-[0, ' num2str(maxInf) '] constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(fwdRxnBoolNon0b),rxnNames(fwdRxnBoolNon0b),model.lb(fwdRxnBoolNon0b),modelAfter.lb(fwdRxnBoolNon0b),model.ub(fwdRxnBoolNon0b),modelAfter.ub(fwdRxnBoolNon0b),printRxnFormula(model, 'rxnAbbrList',model.rxns(fwdRxnBoolNon0b),'printFlag',0),'VariableNames',{'Forward_Reaction, non-0 bound','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(fwdRxnBoolNon0b),rxnNames(fwdRxnBoolNon0b),model.lb(fwdRxnBoolNon0b),model.ub(fwdRxnBoolNon0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(fwdRxnBoolNon0b),'printFlag',0),'VariableNames',{'Forward_Reaction, non-0 bound','Name','lb','ub','equation'});
    end
    disp(T);
end

if ~any(revRxnBoolNon0b)
    if printLevel>0
        fprintf('%s\n','No reverse reactions with non-default constraints.');
    end
else
    if printLevel>0
        fprintf('%s\n',['...reverse reactions with non-[' num2str(minInf)  ', 0]  constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(revRxnBoolNon0b),rxnNames(revRxnBoolNon0b),model.lb(revRxnBoolNon0b),modelAfter.lb(revRxnBoolNon0b),model.ub(revRxnBoolNon0b),modelAfter.ub(revRxnBoolNon0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBoolNon0b),'printFlag',0),'VariableNames',{'Reverse_Reaction, non-0 bound','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(revRxnBoolNon0b),rxnNames(revRxnBoolNon0b),model.lb(revRxnBoolNon0b),model.ub(revRxnBoolNon0b),printRxnFormula(model, 'rxnAbbrList', model.rxns(revRxnBoolNon0b),'printFlag',0),'VariableNames',{'Reverse_Reaction, non-0 bound','Name','lb','ub','equation'});
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

% if ~any(reversibleRxnBool)
%     if printLevel>0
%         fprintf('%s\n','No reversible reactions with non-default constraints.');
%     end
% else
%     if printLevel>0
%         fprintf('%s\n',['...reversible reactions with non-[' num2str(minInf)  ', ' num2str(maxInf) ']  constraints:']);
%     end
%     if exist('modelAfter','var')
%         T = table(model.rxns(reversibleRxnBool),rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),modelAfter.lb(reversibleRxnBool),model.ub(reversibleRxnBool),modelAfter.ub(reversibleRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(reversibleRxnBool),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
%     else
%         T = table(model.rxns(reversibleRxnBool),rxnNames(reversibleRxnBool),model.lb(reversibleRxnBool),model.ub(reversibleRxnBool),printRxnFormula(model, 'rxnAbbrList', model.rxns(reversibleRxnBool),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb','ub','equation'});
%     end
%     disp(T);
% end

if any(boolRemainder)
    if printLevel>0
        fprintf('%s\n',['...reversible reactions with non-[' num2str(minInf)  ', ' num2str(maxInf) ']  constraints:']);
    end
    if exist('modelAfter','var')
        T = table(model.rxns(boolRemainder),rxnNames(boolRemainder),model.lb(boolRemainder),modelAfter.lb(boolRemainder),model.ub(boolRemainder),modelAfter.ub(boolRemainder),printRxnFormula(model, 'rxnAbbrList', model.rxns(boolRemainder),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb_before','lb_after','ub_before','ub_after','equation'});
    else
        T = table(model.rxns(boolRemainder),rxnNames(boolRemainder),model.lb(boolRemainder),model.ub(boolRemainder),printRxnFormula(model, 'rxnAbbrList', model.rxns(boolRemainder),'printFlag',0),'VariableNames',{'Reversible_Reaction','Name','lb','ub','equation'});
    end
    disp(T);
end

fprintf('\n');
