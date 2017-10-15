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
        res = evaluate(self,assignment);
        % evaluate the node with the current GPR assignment
        % USAGE:
        %    res = Node.evaluate(assignment)
        %
        % INPUTS:
        %    assignment:    a containers.Map of the assignment of
        %                   true/false values for each literal. The
        %                   literals are assumed to be the numbers from the
        %                   parsed formula.
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
        reduce(self);
        % Reduce the node elimiating subnodes of the same type and singular
        % value non literal subnodes.
        % USAGE:
        %    Node.reduce()                
        %    
        % OUTPUTS:
        %    Node:    The Node is modified in this process.
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
            if isempty(self.children)
                self.children = childNode;
            else
                self.children(end+1) = childNode;
            end            
            childNode.parent = self;
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
                geneSets{1} = geneNames(pos);
            else
                geneSets = cell(numel(dnfNode.children),1);
                genePos = cell(numel(dnfNode.children),1);
                for i = 1:numel(dnfNode.children)                    
                    childliterals = dnfNode.children(i).getLiterals();
                    pos = cellfun(@str2num, childliterals);
                    genePos{i} = pos;
                    geneSets{i} = geneNames(pos);
                end
            end
        end
    end
    
end

