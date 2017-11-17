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
%    modelNew:      COBRA model structure containing the ratio
%
% EXAMPLE:
%
%    %1 v_EX_ac(e) = 2 v_EX_for(e):
%    modelNew = addRatioReaction(model, {'EX_ac(e)' 'EX_for(e)'}, [1 2])
%
% .. Author: - Ines Thiele 02/09

ConstraintName = ['Ratio_',listOfRxns{1},'_',listOfRxns{2}];
modelNew = addNMConstraint(model,listOfRxns,'c',[-ratioCoeff(1) ratioCoeff(2)],'d',0,'dsense','E','ConstraintID',ConstraintName);
