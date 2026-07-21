function [fluxChanges, uniqueDiet1, uniqueDiet2] = compareDiets(diet1, diet2, one2Two)
% Calculate the changes in metabolite flux composition between two diets and
% the metabolites unique to each diet
%
% By default the differences in diet2 relative to diet1 are calculated.
%
% USAGE:
%
%    [fluxChanges, uniqueDiet1, uniqueDiet2] = compareDiets(diet1, diet2, one2Two)
%
% INPUTS:
%    diet1:          Cell array with the metabolite identifiers in the first
%                    column and flux values (doubles or strings) in the second
%    diet2:          Cell array with the metabolite identifiers in the first
%                    column and flux values (doubles or strings) in the second
%
% OPTIONAL INPUTS:
%    one2Two:        true(1) or false(0) selecting the comparison direction.
%                    When true (default) the differences in diet2 relative to
%                    diet1 are calculated; when false the differences in diet1
%                    relative to diet2 are calculated
%
% OUTPUTS:
%    fluxChanges:    Cell array with the metabolite identifier in the first
%                    column and the changed flux value in the second
%    uniqueDiet1:    Cell array of metabolites unique to diet1 compared to
%                    diet2
%    uniqueDiet2:    Cell array of metabolites unique to diet2 compared to
%                    diet1
%
% .. Author: - Bram Nap, June 2022

if isempty(one2Two)
    one2Two=true;
elseif one2Two<0 || one2Two>1
    warning('one2Two has to be true(1) or false(0), defaulting to true(1)')
end


uniqueDiet1 = setdiff(diet1(:,1),diet2(:,1));
uniqueDiet2 = setdiff(diet2(:,1),diet1(:,1));

allMets = [diet1(:,1); diet2(:,1)];
allMets = unique(allMets);

% What is changed in Diet2 when compared to Diet1
for i = 1:length(allMets)
   met = allMets{i}; 
   indexDiet1 = find(contains(diet1(:,1), met));
   indexDiet2 = find(contains(diet2(:,1), met));
   if ~isempty(indexDiet1) && ~isempty(indexDiet2)   
       value1 = diet1{indexDiet1,2};
       value2 = diet2{indexDiet2,2};        
   elseif isempty(indexDiet1) && ~isempty(indexDiet2)
       value1 = 0;
       value2 = diet2{indexDiet2,2};
   elseif ~isempty(indexDiet1) && isempty(indexDiet2)
       value1 = diet1{indexDiet1,2};
       value2 = 0;
   end
   
   if isa(value1, 'char')
       value1 = str2double(value1);
   end
   if isa(value2, 'char')
       value2 = str2double(value2);
   end
   
   change = value2-value1;
   allMets(i,2) = {change}; 
   fluxChanges = allMets;
   
   if one2Two == false 
       fluxChanges = fluxChanges*-1;
   end
end
