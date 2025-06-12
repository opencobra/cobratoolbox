function [grRules] = calculateGR(model, gvalue)
% calculateGR is a function of gDel_minRN that reads
% a COBRA model and a 0-1 assignment for genes and outputs whether
% each reaction is repressed or not.
%
% USAGE:
%
%    function [grRules] = calculateGR(model, gvalue)
%
% INPUTS:
%    model:    COBRA model structure containing the following required fields to perform gDel_minRN.
%
%        *.rxns:       Rxns in the model
%        *.mets:       Metabolites in the model
%        *.genes:      Genes in the model
%        *.grRules:    Gene-protein-reaction relations in the model
%        *.S:          Stoichiometric matrix (sparse)
%        *.b:          RHS of Sv = b (usually zeros)
%        *.c:          Objective coefficients
%        *.lb:         Lower bounds for fluxes
%        *.ub:         Upper bounds for fluxes
%        *.rev:        Reversibility of fluxes
%
%    gvalue:    The first column is the list of genes in the original model.
%               The second column contains a 0/1 vector indicating which genes should be deleted.
%                   0: indicates genes to be deleted.
%                   1: indecates genes to be remained.
%
% OUTPUT:
%    grRules:    The first column is the list of GPR-rules. If a reaction does
%                not have a GPR-rule, it is represented as 1.
%                In the second columun, each gene is converted to 0 or 1 based
%                on the given 0-1 assignment, with AND converted to * and OR
%                converted to +.
%                The third comumn contains the calculation results from the
%                second column.
%                The fourth column is 0 if the third column is 0 and 1 if it is
%                greater. If it is 0, the reaction is repressed; if it is 1, it
%                is not repressed.
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

