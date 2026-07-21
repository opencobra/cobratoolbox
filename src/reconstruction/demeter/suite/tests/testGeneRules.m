function incorrectGeneRules = testGeneRules(model)
% Finds gene rules that have an incorrect nomenclature.
%
% USAGE:
%
%    incorrectGeneRules = testGeneRules(model)
%
% INPUTS:
%    model:                 COBRA model structure with fields:
%
%                             * .rules - Gene-protein-reaction rules in
%                               computable form
%
% OUTPUTS:
%    incorrectGeneRules:    Cell array listing entries in model.rules that
%                           have incorrect nomenclature.
%
% .. Author: - Almut Heinken, Oct 2019

cnt=1;
incorrectGeneRules={};

for i=1:length(model.rules)
   tf = verifyRuleSyntax(model.rules{i});
   if ~tf
       incorrectGeneRules{cnt}=i;
       cnt=cnt+1;
   end
end

end