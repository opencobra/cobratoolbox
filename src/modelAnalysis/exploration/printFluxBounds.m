function printFluxBounds(model)
%PRINTFLUXBOUNDS prints the reactionID and upper/lower flux bounds.
%INPUT
% model      The model to print 
%
% Author - Thomas Pfau May 2017

rxnlength = cellfun(@length,model.rxns);
maxlength = max([rxnlength;11]);
fprintf(['%' num2str(maxlength) 's\t%14s\t%14s\n'],'Reaction ID','Lower Bound','Upper Bound');
for i = 1: numel(model.rxns)
    fprintf(['%' num2str(maxlength) 's\t%14.3f\t%14.3f\n'],model.rxns{i},model.lb(i),model.ub(i));
end

