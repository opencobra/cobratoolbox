function orphans = findOrphanRxns(model)
% Finds all orphan reactions in model (reactions with no
% associated genes), not including exchange `rxns`
%
% USAGE:
%
%    orphans = findOrphanRxns(model)
%
% INPUT:
%    model:      a COBRA model with GPRs
%
% OUTPUT:
%    orphans:    all orphan reactions in the model
%
% .. Author: - Jeff Orth 4/15/09


rxns = find(strcmp('',model.rules));
[selExc,selUpt] = findExcRxns(model,true,false);
orphans = model.rxns(setdiff(rxns,find(selExc)));
