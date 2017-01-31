function [intracellRxnList] = findIntracellularRxns(model)
%% function [intracellRxnList] = findIntracellularRxns(model)
%
% This function finds all reactions that do not contain metabolites in [e]
% comparment.
%
% INPUT
% model             Model structure
%
% OUTPUT
% intracellRxnList  List of intracellular reactions in model
%
% July 2013
% Ines Thiele, http://thielelab.eu.

%%

intracellRxnList = zeros(length(model.rxns),1);

% exclude extracellular reactions
RL = printRxnFormula(model,model.rxns,false);
for i = 1 : length(RL)
    tmp = regexp(RL{i},'\[e\]');
    if isempty(tmp) % intracellular reaction
        intracellRxnList(i,1)=1;
    end
end
intracellRxnList = model.rxns(find(intracellRxnList));