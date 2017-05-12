function [model ModifiedRxns] = changeRxnMets(model,Mets2change,NewMets,Rxn,NewStoich)
%changeRxnMets Change metabolites in a specified reaction, or
% randomly chosen reactions.
%
% [model ModifiedRxns] = changeRxnMets(model,Mets2change,NewMets,Rxn,NewStoich)
%
%INPUTS
% model               COBRA model structure
% Mets2change         Cell array of metabolites to change
% NewMets             Cell array of replacement metabolites (must be in
%                     order of those that will be replaced
% Rxn                 reaction to change (string) or cell array, or if a number is put
%                     here, that number of reactions (with Mets2change) will
%                     be randomly chosen and the metabolites will be swapped
%
%OPTIONAL INPUT
% NewStoich           Stoichiometry of new metabs (conserved from old mets by default).
%                     If multiple reactions are being changed, this must be
%                     a mets x rxns matrix,
%                           e.g. for 2 new reactions: Rxn = {'r1','r2'}
%                                r1: 2 A + 3 B -> 1 C
%                                r2: 4 A + 3 B -> 3 C
%                               where A and C are the new metabolites,
%                               NewMets = {'A', 'C'}
%                               NewStoich = [ 2 4; 1 3]
%
%OUTPUTS
% model              COBRA model structure with changed reaction
% ModifiedRxns       Rxns which were modified
%
%  Nathan Lewis (Apr 24, 2009)

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
    RxnsInd = 1:length(model.rxns);
    tempS = full(model.S);
    for i = 1:length(OldMetInd)
        RxnsInd = intersect(find(tempS(OldMetInd(i),:)),RxnsInd);
    end
    if length(RxnsInd)<Rxn
        warning('Fewer reactions have your metabolites than the number you wanted to randomly choose!')
        RxnsToSwitch = RxnsInd(ceil(rand(length(RxnsInd),1)));
        Rxn = length(RxnsToSwitch);
    else
        %%% chose the reactions to randomize
        RxnsToSwitch = [];
         Rxns2Exclude = findRxnIDs(model,{'DM_SC_PRECUSOR'});
         for r=1:length(Rxns2Exclude)
             tmp = find(RxnsInd==Rxns2Exclude(r));
             if ~isempty(tmp)
                 RxnsInd(tmp) = [];
             end
         end
        while length(unique(RxnsToSwitch))<Rxn
                     
        RxnsToSwitch = RxnsInd(ceil(rand(length(RxnsInd),1)*length(RxnsInd)));
        RxnsToSwitch = RxnsToSwitch(1:Rxn);
        end
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