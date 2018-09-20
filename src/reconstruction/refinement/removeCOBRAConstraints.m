function model = removeCOBRAConstraints(model, constraintsToRemove)
% Remove the specified Non Metabolic Constraints.
% USAGE:
%    model = removeCOBRAConstraint(model, constraintsToRemove)
%
% INPUTS:
%    model:                 model structure
%    constraintsToRemove:   cell array of Constraint IDs, or Constraint
%                           Positions to remove, or a boolean vector of
%                           positions to remove.
%
% OUTPUT:
%    model:                 the model with the constraints removed.
%
% Author: 
%   Thomas Pfau - Nov 2017

if ~isfield(model,'C')
    %There is nothing to be done. Just return
    return
end

if ischar(constraintsToRemove)
    constraintsToRemove = {constraintsToRemove};
end

if iscell(constraintsToRemove)
    [pres,pos] = ismember(constraintsToRemove,model.ctrs);            
    constraintsToRemove = pos(pres);        
end

model = removeFieldEntriesForType(model,constraintsToRemove,'ctrs',length(model.ctrs));

if isempty(model.C)
    ConstraintFields = intersect(fieldnames(model),{'C','D','d','dsense','ctrs','ctrNames'});
    model = rmfield(model,ConstraintFields);    
end
   

end