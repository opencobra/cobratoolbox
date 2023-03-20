function [fluxChanges, uniqueDiet1, uniqueDiet2] = compareDiets(diet1, diet2, one2Two)
% Calculates the changes in metabolite flux composition between two diets.
% It also calculates unique metabolites in each diets. It defaults to
% calculating the differences in diet2 from diet1
%
% [fluxChanges, uniqueDiet1, uniqueDiet2] = compareDiets(diet1,diet2,one2Two)
%
% Example: compareDiets(diet1,diet2,false)
%
% INPUTS:
%   diet1:         A cell array with the first column the metabolite
%                  identifiers and the second with flux values as doubles
%                  or strings
%   diet2:         A cell array with the first column the metabolite
%                  identifiers and the second with flux values as doubles
%                  or strings
% OPTIONAL INPUTS:
%   one2Two:       true(0) or false(1) to state if the default of 
%                  calculating the differences in diet2 from diet1 should 
%                  be used. If false(0) differences in diet1 from diet2 
%                  will be calculated.    
%
% OUTPUT:
%    fluxChanges:  Cell array with the first column the metabolite
%                  identifier and the second column the changed flux value
%    uniqueDiet1:  Cell array with unique metabolites in diet1 compared to
%                  diet2
%    uniqueDiet2:  Cell array with unique metabolites in diet2 compared to
%                  diet1
%
% .. Authors: - Bram Nap - June 2022 

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
