function [grRules] = calculateGR(model, gvalue)
% calculateGR is a submodule of gDel_minRN that reads a COBRA model and a
% 0/1 assignment for the genes and determines, for each reaction, whether it
% is repressed under that gene-deletion assignment.
%
% USAGE:
%
%    [grRules] = calculateGR(model, gvalue)
%
% INPUTS:
%    model:    COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .genes - gene identifiers (g x 1 cell array)
%                * .grRules - gene-protein-reaction association rules (n x 1 cell array)
%
%    gvalue:    gene-deletion assignment. Column 1 lists the genes of the
%              original model; column 2 is a 0/1 vector (0 = gene deleted,
%              1 = gene retained)
%
% OUTPUT:
%    grRules:    cell array describing, per reaction, whether it is repressed:
%
%                * column 1 - the GPR rule of the reaction (1 if the reaction
%                  has no GPR rule)
%                * column 2 - the GPR rule with each gene replaced by its 0/1
%                  value and AND/OR replaced by * / +
%                * column 3 - the numeric result of evaluating column 2
%                * column 4 - 1 if column 3 is greater than 0 (reaction active),
%                  0 if column 3 is 0 (reaction repressed), -1 if there is no rule
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

grRules = cell(size(model.rxns));
for i=1:size(model.grRules, 1)
    grRules{i, 1} = model.grRules{i,1};
end
for i = 1:size(model.rxns, 1)
    if isempty(grRules{i, 1})==1
        grRules{i,1} = '1';
    end
end
grRules(:, 2) = strrep(grRules, 'or', '+');
grRules(:,2) = strrep(grRules(:,2), 'and', '*');

[xname2, index] = sortrows(gvalue(:,1), 'descend');
for i=1:size(index, 1)
   sorted_gvalue(i, 1) = gvalue{index(i, 1), 2}; 
end
for i = 1:size(model.genes, 1)
    grRules(:, 2) = strrep(grRules(:, 2), xname2{i, 1},num2str(sorted_gvalue(i, 1)));
end
for i = 1:size(grRules, 1)
    %i
    if isempty(grRules{i, 2}) == 0
        grRules{i, 3} = eval(grRules{i, 2});
        if grRules{i, 3} > 0.9
            grRules{i, 4} = 1;
        else
            grRules{i, 4} = 0;
        end
    else
       grRules{i, 4} = -1; 
    end
end
end

