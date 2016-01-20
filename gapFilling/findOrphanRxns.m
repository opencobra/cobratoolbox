function orphans = findOrphanRxns(model)
%findOrphanRxns find all orphan reactions in model (reactions with no 
%associated genes), not including exchange rxns
%
% orphans = findOrphanRxns(model)
%
%INPUT
% model         a COBRA model with GPRs
%
%OUTPUT
% orphans       all orphan reactions in the model
%
% Jeff Orth 4/15/09

rxns = find(strcmp('',model.grRules));
[selExc,selUpt] = findExcRxns(model,true,false);
orphans = model.rxns(setdiff(rxns,find(selExc)));



