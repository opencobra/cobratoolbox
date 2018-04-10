function [outputNode] = combineChildren(CNFNode1,CNFNode2)
% Combine the children of two nodes such that all children of node 1 are mixed with children of node 2.
% Conjunct clauses which are superseeded are removed.
% USAGE:
%    [outputNode] = combineChildren(CNFNode1,CNFNode2)
% 
% INPUTS:
%    CNFNode1:        A Node in CNF format 
%    CNFNode2:        A Node in CNF format 
%
% OUTPUTS:
%    outputNode:      A node with all children of the input nodes mixed.
%
% NOTE:
%    The function will mix all combinations of nodes. E.g. if node 1 is (A | B) & (C | D) and node 2 is (E | F) & G
%    the resulting node will be (A | B | E | F) & (A | B | G) & (C | D | E | F) & (C | D | G)
%
% .. Author: Thomas Pfau, Apr 2018

if isempty(CNFNode1.children)
    %If one of the nodes is empty simply return the other node.
    outputNode = CNFNode2;
    return
end

if isempty(CNFNode2.children)
    outputNode = CNFNode1;
    return
end

%Create a new empty And Node.
outputNode = AndNode();
childSets = {};
for child1 = 1:numel(CNFNode1.children)               
    for child2 = 1:numel(CNFNode2.children)
        %if child1 is a literalnode, we have to add it to a new or node to be able to mix.
        %otherwise we take a copy of the node.
        if isa(CNFNode1.children(child1),'LiteralNode')
            c1node = OrNode();
            c1node.addChild(CNFNode1.children(child1).copy());
        else
            c1node = CNFNode1.children(child1).copy();
        end
        %Add copies of all children of node2 to the copy of node 1
        c2node = CNFNode2.children(child2).copy();
        c1node.addChild(c2node);
        %Filter clauses which are unnecessary (e.g. if (A | B | C) is one clause (A | B) is pointless.
        currentLiterals = c1node.getLiterals();
        existing = cellfun(@(x) all(ismember(x,currentLiterals)),childSets); %Check if it already exists
        superseeded = cellfun(@(x) all(ismember(currentLiterals,x)),childSets); %Or if it contains clauses that can be removed.
        %Remove superseeded clauses
        if any(superseeded)
            outputNode.children(superseeded) = [];
            childSets(superseeded) = [];
        end
        %And add the current clause if it does not exist.
        if ~any(existing)
            childSets{end+1} = currentLiterals;
            c1node.reduce();
            c1node.removeDuplicateLiterals();
            outputNode.addChild(c1node);
        end        
    end
end


end

