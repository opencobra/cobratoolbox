function modelNew = addRatioReaction(model, listOfRxns, ratioCoeff)
% Adds ratio reaction.
%
% USAGE:
%
%    modelNew = addRatioReaction(model, listOfRxns, ratioCoeff)
%
% INPUTS:
%    model:         COBRA model structure
%    listOfRxns:    List of 2 Reactions
%    ratioCoeff:    Array of ratio coefficient between the 2 reactions
%
% OUTPUT:
%    modelNew      COBRA model structure containing the ratio
%
% EXAMPLE:
%    %1 v_EX_ac(e) = 2 v_EX_for(e):
%    modelNew = addRatioReaction(model, {'EX_ac(e)' 'EX_for(e)'}, [1 2])
%
% .. Author: - Ines Thiele 02/09

modelNew = model;

[rows, cols] = size(model.S);

[A, Loc] = ismember(listOfRxns,model.rxns);

modelNew.S(rows+1,:) = 0;
modelNew.S(rows+1,Loc) = [-ratioCoeff(1) ratioCoeff(2)];
modelNew.b(rows+1) = 0;
modelNew.mets{rows+1} = strcat('Ratio_',listOfRxns{1},'_',listOfRxns{2});
modelNew.metName{rows+1} = strcat('Ratio_',listOfRxns{1},'_',listOfRxns{2});
if isfield(modelNew,'note')
    modelNew.note = strcat(modelNew.note,listOfRxns{1},' and ',listOfRxns{2}, 'are set to have a ratio of',ratioCoeff(1),' to ' ,ratioCoeff(2),'.');
else
    modelNew.note = strcat(listOfRxns{1},' and ',listOfRxns{2}, 'are set to have a ratio of ',num2str(ratioCoeff(1)),':' ,num2str(ratioCoeff(2)),'.');
end
