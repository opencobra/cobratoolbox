function [model ModifiedRxns] = changeRxnMets(model, Mets2change, NewMets, Rxn, NewStoich)
% Changes metabolites in a specified reaction, or
% randomly chosen reactions.
%
% USAGE:
%
%    [model ModifiedRxns] = changeRxnMets(model, Mets2change, NewMets, Rxn, NewStoich)
%
% INPUTS:
%    model:           COBRA model structure
%    Mets2change:     Cell array of metabolites to change
%    NewMets:         Cell array of replacement metabolites (must be in
%                     order of those that will be replaced
%    Rxn:             reaction to change (string) or cell array, or if a number is put
%                     here, that number of reactions (with `Mets2change`) will
%                     be randomly chosen and the metabolites will be swapped
%
% OPTIONAL INPUT:
%    NewStoich:       Stoichiometry of new metabs (conserved from old mets by default).
%                     If multiple reactions are being changed, this must be
%                     a `mets` x `rxns` matrix,
%
%                     e.g. for 2 new reactions: Rxn = {'r1', 'r2'},
%
%                       * r1: 2 A + 3 B -> 1 C
%                       * r2: 4 A + 3 B -> 3 C
%
%                     where A and C are the new metabolites,
%                     NewMets = {'A', 'C'}
%                     NewStoich = [ 2 4; 1 3]
%
% OUTPUTS:
%    model:           COBRA model structure with changed reaction
%    ModifiedRxns:    `Rxns` which were modified
% AUTHORS:
%    Nathan Lewis (Apr 24, 2009)

if nargin ==4
    NewStoich = [];
end

%%% make sure metabolites are in the model
OldMetInd = findMetIDs(model,Mets2change);
NewMetInd = findMetIDs(model,NewMets);
if min(OldMetInd) == 0 || min(NewMetInd) == 0
    error('A metabolite wasn''t found in your model!')
end
if ~all(isnumeric(Rxn))
    %%% make sure rxns are in the model
    RxnsInd = findRxnIDs(model,Rxn);
    if min(RxnsInd == 0)
        error('A reaction wasn''t found in your model!')
    end
    model = changeMets(model,OldMetInd,NewMetInd,RxnsInd,NewStoich);
    ModifiedRxns = model.rxns(RxnsInd);
else
    %%% find all reactions with the old mets, and choose the specified number of rxns
    %%% Preferably those with all the metabolites. 
    
    RxnsIndAll = find(all(model.S(OldMetInd,:)));
    RxnsIndAny = find(any(model.S(OldMetInd,:)));
    if length(RxnsIndAll)<Rxn
        warning('Fewer reactions have all your metabolites than the number you wanted to randomly choose! Selecting additional ones from those which have ANY.')
        if numel(RxnsIndAny) + numel(RxnsIndAll) < Rxn
            warning('Fewer reactions have any of your metabolites than the number you wanted to randomly choose! Using all which do have a matching metabolite.')
            RxnsToSwitch = union(RxnsIndAll,RxnsIndAny);
            Rxn = length(RxnsToSwitch);
        else
            RxnsToSwitch = union(RxnsIndAll,RxnsIndAny(randperm(numel(RxnsIndAny),Rxn-numel(RxnsIndAll))));
        end
    else
        RxnsToSwitch = RxnsIndAll(randperm(numel(RxnsIndAll),Rxn));
    end
    model = changeMets(model,OldMetInd,NewMetInd,RxnsToSwitch,NewStoich);
    ModifiedRxns = model.rxns(RxnsToSwitch);
end
end
function model = changeMets(model,OldMetInd,NewMetInd,RxnsInd,NewStoich)
if isempty(NewStoich)
    NewStoich = model.S(OldMetInd,RxnsInd);
end
for i = 1:length(RxnsInd)
    model.S(OldMetInd,RxnsInd(i))=0;
    model.S(NewMetInd,RxnsInd(i))=NewStoich(:,i);
end
end
