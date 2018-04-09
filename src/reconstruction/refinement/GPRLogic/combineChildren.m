function [outputNode] = combineChildren(CNFNode1,CNFNode2)
%COMBINECHILDREN Summary of this function goes here
%   Detailed explanation goes here
if isempty(CNFNode1.children)
    outputNode = CNFNode2;
    return
end
if isempty(CNFNode2.children)
    outputNode = CNFNode1;
    return
end

outputNode = AndNode();
childSets = {};
for child1 = 1:numel(CNFNode1.children)               
    for child2 = 1:numel(CNFNode2.children)
        if isa(CNFNode1.children(child1),'LiteralNode')
            c1node = OrNode();
            c1node.addChild(CNFNode1.children(child1).copy());
        else
            c1node = CNFNode1.children(child1).copy();
        end
        c2node = CNFNode2.children(child2).copy();
        c1node.addChild(c2node);
        currentLiterals = c1node.getLiterals();
        existing = cellfun(@(x) all(ismember(x,currentLiterals)),childSets);
        superseeded = cellfun(@(x) all(ismember(currentLiterals,x)),childSets);
        if any(superseeded)
            outputNode.children(superseeded) = [];
            childSets(superseeded) = [];
        end
        if ~any(existing)
            childSets{end+1} = currentLiterals;
            c1node.reduce();
            c1node.removeDuplicateLiterals();
            outputNode.addChild(c1node);
        end        
    end
end
%Check for duplicates.




end

