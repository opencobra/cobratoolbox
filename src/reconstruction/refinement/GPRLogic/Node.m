classdef (Abstract,HandleCompatible) Node < handle & matlab.mixin.Heterogeneous
    % Node are an Abstract class that handles different types of logical Nodes
    % for a tree representation of a logical formula.
    %
    % .. Authors Thomas Pfau 2016
    properties
        children;
        parent;
    end
    
    methods(Abstract)
        res = evaluate(self,assignment,printLevel);
        % evaluate the node with the current GPR assignment
        % USAGE:
        %    res = Node.evaluate(assignment)
        %
        % INPUTS:
        %    assignment:    a containers.Map of the assignment of
        %                   true/false values for each literal. The
        %                   literals are assumed to be the string numbers from the
        %                   parsed formula.
        %
        % OPTIONAL INPUTS:
        %
        %    printLevel:    whether to rpint out result for individual
        %                   nodes (default 0)
        %
        % OUTPUTS:
        %    res:           The evaluation of the Node (true or false)
        %
        res = toString(self,PipeAnd);
        % print the Node to a string
        % USAGE:
        %    res = Node.toString()
        %
        % OPTIONAL INPUTS:
        %    PipeAnd:       Whether to use | as the symbol for OR and & as
        %                   the symbol for AND. (default false)
        %
        % OUTPUTS:
        %    res:           The String representation of the GPR-Node
        %
        dnfNode = convertToDNF(self);
        % Convert to a DNF Node.
        % USAGE:
        %    dnfNode = Node.convertToDNF()
        %
        % OUTPUTS:
        %    res:           A Node in DNF form (i.e. and clauses separated
        %                   by or )
        %        
        cnfNode = convertToCNF(self);
        % Convert to a CNF Node.
        % USAGE:
        %    dnfNode = Node.convertToCNF()
        %
        % OUTPUTS:
        %    res:           A Node in CNF form (i.e. and or-clauses separated
        %                   by and )
        %
        reduce(self);
        % Reduce the node elimiating subnodes of the same type and singular
        % value non literal subnodes.
        % USAGE:
        %    Node.reduce()
        %
        % OUTPUTS:
        %    Node:    The Node is modified in this process.
        %
        
        deleteLiteral(self,literalID)
        % Delete a literal from this Node and all children
        % USAGE:
        %    newHead = node.deleteLiteral(literalID)
        % 
        % INPUT:
        %    literalID: The LiteralID (As string or number)
        %        
        % NOTE:
        %    The Node will no longer contain the corresponding literal
        %
        
        
    end
    methods
        function obj = Node()
            % Default Node constructor.
            % USAGE:
            %    obj = Node()
            %
            % OUTPUTS:
            %    obj:    The Node Object
            %
            obj.children = [];
        end
        
        function nodeCopy = copy(self)
            if isa(self,'LiteralNode')
                nodeCopy = LiteralNode(self.id);
            else
                nodeCopy = eval(class(self));
            end
            for i = 1:numel(self.children)
                cchild = self.children(i);
                childCopy = cchild.copy();
                nodeCopy.addChild(childCopy);
            end
        end
        
        function id = getID(self)
            % Get the ID (commonly the class except for Literals
            % USAGE:
            %    id = Node.getID()
            %
            % OUTPUTS:
            %    id:   The id for literals the represented literal, or classname for other nodes of the node
            %
            id = class(self);
        end
        
        
        
        function addChild(self,childNode)
            % Add A Child to the node
            % USAGE:
            %    Node.addchild(childNode)
            %
            % INPUTS:
            %    childNode:   The child to add to the node.
            %   
            
            if isa(childNode,class(self)) %if the nodes are of the same class, we just add the children.
                for i=1:numel(childNode.children)
                    if isempty(self.children)
                        self.children = childNode.children(i);
                    else                                          
                        self.children(end+1) = childNode.children(i);
                    end
                    childNode.children(i).parent = self.parent;
                end
            else
                if isempty(self.children)
                    self.children = childNode;
                else                    
                    self.children(end+1) = childNode;                    
                end
                childNode.parent = self;
            end            
        end
        function res = contains(self,literal)
            % Check whether the given literal is part of this node.
            % USAGE:
            %    res = Node.contains(literal)
            %
            % INPUTS:
            %    literal:   The literal to look up (a string representation of
            %               a number from a rule
            %
            % OUTPUTS:
            %    res:       Whether the literal is present in the tree starting
            %               at this node.
            %
            for c=1:numel(self.children)
                child = self.children(c);
                res = child.contains(literal);
                if res
                    break;
                end
            end
        end
        
        function literals = getLiterals(self)
            % Get the set of literals present in the tree below this node.
            % USAGE:
            %    literals = Node.getLiterals()
            %
            % OUTPUTS:
            %    literals:   A cell array of all literals present in the tree under this node
            %
            literals = [];
            for c=1:numel(self.children)
                child = self.children(c);
                literals = [literals child.getLiterals()];
            end
        end
        
        function removeDuplicateLiterals(self)
            % Remove all duplicate literal nodes in this node.
            % USAGE:
            %    node.removeDuplicateLiterals()
            % 
            if ~isa(self,'LiteralNode')
                literals = find(arrayfun(@(x) isa(x,'LiteralNode'),self.children));
                literalIDs = arrayfun(@(x) x.id,self.children(literals),'Uniform',false);
                [~,toKeep] = unique(literalIDs);
                toRemove = setdiff(literals,toKeep);
                self.children(toRemove) = [];
            end
        end
        
        function [geneSets,genePos] = getFunctionalGeneSets(self,geneNames)
            % Get all functional gene sets useable for this node
            % USAGE:
            %    geneSets = Node.getFunctionalGeneSets(geneNames)
            %
            % INPUTS:
            %    geneNames:   the genes in the order represented by the
            %                 literals (which represent positions)
            %
            % OUTPUTS:
            %    geneSets:    A cell array of gene Combinations that would make this node active
            %
            %    genePos:     A set of positions (according to the parsed
            %                 Rules) of genes that would make this tree
            %                 evaluate to true.
            %
            dnfNode = self.convertToDNF();
            if isa(dnfNode,'LiteralNode')
                geneSets = cell(1,1);
                genePos = cell(1,1);
                literals = dnfNode.getLiterals();
                pos = cellfun(@str2num, literals);
                genePos{1} = pos;
                geneSets{1} = geneNames(sort(pos));
            else
                geneSets = cell(numel(dnfNode.children),1);
                genePos = cell(numel(dnfNode.children),1);
                for i = 1:numel(dnfNode.children)
                    childliterals = dnfNode.children(i).getLiterals();
                    pos = cellfun(@str2num, childliterals);
                    genePos{i} = pos;
                    geneSets{i} = geneNames(sort(pos));
                end
            end
        end
        
        function tf = isequal(self,otherNode)
            % Get all functional gene sets useable for this node
            % USAGE:
            %    tf = Node.isequal(otherNode)
            %
            % INPUTS:
            %    otherNode:   The node to compare this node with            
            %
            % OUTPUTS:
            %    tf:          true, if this node is equal to the other
            %                 node, i.e. it represents the same boolean truth table.
            %
            list= cellfun(@str2num , self.getLiterals());
            otherlist = cellfun(@str2num , otherNode.getLiterals());
            if ~isempty(setxor(list,otherlist))
                tf = false;
                return
            end
            maxpos = max(list);
            geneNames = cellfun(@num2str, num2cell(1:maxpos),'UniformOutput',0);
            %Now, since the positions are ordered, AND we can directly
            %convert the numbers and we will hack...
            [geneSets] = self.getFunctionalGeneSets(geneNames);
            [otherGeneSets] = otherNode.getFunctionalGeneSets(geneNames);
            presentsets = {};
            tf = true;
            while ~isempty(geneSets)
                setFound = false;
                for i = 1:numel(otherGeneSets)
                    if isempty(setxor(geneSets{1},otherGeneSets{i}))
                        presentsets{end+1} = geneSets{1};
                        geneSets(1) = [];
                        otherGeneSets(i) = [];
                        setFound = true;
                        break
                    end
                end
                if ~setFound
                    for i = 1:numel(presentsets)
                        if isempty(setxor(geneSets{1},presentsets{i}))
                            geneSets(1) = [];
                            setFound = true;
                            break
                        end
                    end
                end
                if ~setFound
                    tf = false;
                    return
                end
            end
            while ~isempty(otherGeneSets)
                setFound = false;
                for i = 1:numel(presentsets)
                    if isempty(setxor(geneSets{1},presentsets{i}))
                        geneSets(1) = [];
                        setFound = true;
                        break
                    end
                end
                if ~setFound
                    tf = false;
                    return
                end
            end
            
        end
    end
end
