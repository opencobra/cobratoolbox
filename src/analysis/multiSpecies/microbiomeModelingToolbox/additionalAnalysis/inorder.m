function [visitedmets, visitedrxns] = inorder(node, model, visitedmets, visitedrxns, levels)

% Concatenates all reactions and metabolites connected over levels
%
% USAGE:
%
%                       [visitedmets, visitedrxns] = inorder(node, model, visitedmets, visitedrxns, levels)
% INPUTS:
%    node:               char with the name of the starting node
%    model:              COBRA model of a community/microbe
%                        one microbe model that can carry flux
%    visitedmets:        list of metabolites that are excluded
%                        (already visited)
%    visitedrxns:        list of reactions that are excluded
%                        (already visited)
% 	 levels               indicates how many levels from the starting node (metabolite) are
%                        considered
% OUTPUTS:
%    visitedmets:        list of all metabolites that are connected over
%                        the levels
%    visitedrxns:        list of all reactions that are connected over
%                        the levels
    if isempty(node)
        return;   
    else
        childrenrxns = find(model.S(node,:));
        childrenmets = [];
        childrenrxns = setdiff(childrenrxns, visitedrxns);
        visitedmets = [visitedmets, node];
        visitedrxns = [visitedrxns, childrenrxns];

        for i=1:length(childrenrxns)
            childrenmets = [childrenmets, find(model.S(:,childrenrxns(i)))'];
        end

        childrenmets = setdiff(childrenmets, visitedmets);
        visitedmets = unique([visitedmets, childrenmets]);
        total = length(childrenmets);

        for i=1:total
            if(i==1)
                levels = levels -1;
            end
            if(levels<1)
                return;
            else
            [visitedmets, visitedrxns] = inorder(childrenmets(i), model, visitedmets, visitedrxns, levels);
            end
        end

        if isempty(childrenmets)
             [visitedmets, visitedrxns] = inorder(childrenmets, model, visitedmets, visitedrxns, levels);
        end

    end

end

