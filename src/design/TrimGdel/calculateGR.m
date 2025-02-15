function [grRules] = calculateGR(model, xname)

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

[xname2, index] = sortrows(xname(:,1), 'descend');
for i=1:size(index, 1)
   sorted_gvalue(i, 1) = xname{index(i, 1), 2}; 
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

