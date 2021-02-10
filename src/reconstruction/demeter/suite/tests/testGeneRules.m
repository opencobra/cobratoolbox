function incorrectGeneRules = testGeneRules(model)
% Finds gene rules that have an incorrect nomenclature.
%
% INPUT
% model             COBRA model structure
%
% OUTPUT
% incorrectGeneRules       Cell array listing entries in model.rules that
%                          have incorrect nomenclature.
%
% Almut Heinken, Oct 2019

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