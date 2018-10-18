classdef (HandleCompatible) AndNode < Node
    % AndNode are an class that represents AND connections in a logical formula
    % For further documentation please have a look at the Node Class.
    % .. Authors
    %     - Thomas Pfau 2016
    properties
    end
    
    methods
        function res = evaluate(self,assignment, printLevel)
            if ~exist('printLevel','var')
                printLevel = 0;
            end
            res = true;
            for i=1:numel(self.children)
                child = self.children(i);
                if not(child.evaluate(assignment,printLevel))
                    res = false;
                end
            end
            if printLevel >= 1
                fprintf('%s : %i\n',self.toString(0),res);
            end
        end
        
        function tf = deleteLiteral(self,literalID, keepClauses)            
            tf = true;            
            if ~exist('keepClauses','var')
                keepClauses = true;
            end
            if ~keepClauses
                % reduce to properly delete elements
                self.reduce();
            end
            arrayfun(@(x) ~isa(x,'LiteralNode') && x.deleteLiteral(literalID, keepClauses), self.children);    
            % originalNodeString = self.toString(1);            
            literalMatches = arrayfun(@(x) (isa(x, 'LiteralNode') && x.contains(literalID) ), self.children);
            emptyChildren = arrayfun(@(x) (~isa(x,'LiteralNode') && numel(x.children) <= 1), self.children);
            if ~keepClauses
                % if we don't keep and clauses containing the literal
                if any(literalMatches)
                    % and the literal is a direct child of this clause
                    % we empty this node
                    self.children(:) = [];
                    return
                end
            end
            % otherwise, we only remove the child.
            % and check for one element entries
            mergeChildren = arrayfun(@(x) ~isa(x,'LiteralNode') && numel(x.children) == 1, self.children);            
            toDelete = literalMatches|emptyChildren;
            if any(mergeChildren)
                childsToMerge = self.children(mergeChildren);
                childrenToAdd = AndNode();
                for i = 1:numel(childsToMerge)
                    cchild = childsToMerge(i);
                    childrenToAdd(i) = cchild.children;
                end
                % the following works only on 2017b or newer, but is more
                % efficient.
                %childrenToAdd = arrayfun(@(x) x.children, self.children(mergeChildren));
            end             
            self.children(toDelete) = [];
            if exist('childrenToAdd','var')
                for child = 1:numel(childrenToAdd)
                    newChild = childrenToAdd(child);
                    self.children(end+1) = newChild;
                    newChild.parent = self;
                end            
            end
            %fprintf('Removing Literal %s from the following node:\n%s\nLeads to the node:\n%s\n',literalID,originalNodeString,self.toString(1));
        end   
        
        function res = toString(self,PipeAnd)
            if nargin < 2
                PipeAnd = 0;
            end
            res = '';
            for i=1:numel(self.children)
                child = self.children(i);
                if PipeAnd
                    res = [res child.toString(PipeAnd) ' & '];
                else
                    res = [res child.toString(PipeAnd) ' and '];
                end
                
            end
            if length(res) > 2
                if PipeAnd
                    res = res(1:end-3);
                else
                    res = res(1:end-5);
                end
            end
        end
        function cnfNode = convertToCNF(self)            
            cnfNode = AndNode();
            for i = 1:numel(self.children)
                if isa(self.children(i),'LiteralNode')
                    CNFChild = self.children(i).copy();
                else
                    CNFChild = self.children(i).convertToCNF();
                end                
                cnfNode.addChild(CNFChild);
            end
        end
            

        function dnfNode = convertToDNF(self)
            dnfNode = OrNode();
            childNodes = [];
            sizes = [];
            for c=1:numel(self.children)
                child = self.children(c);
                if isempty(childNodes)
                    childNodes = child.convertToDNF();
                else
                    childNodes(end+1) = child.convertToDNF();
                end
                convNode = childNodes(end);
                sizes(end+1) = numel(convNode.children);                               
            end
            %Now make and combinations of all items in the children
            step = ones(numel(sizes),1);
            while self.isValid(sizes,step)
                nextNode = AndNode();
                for i=1:numel(step)
                    convNode = childNodes(i);
                    if strcmp(class(convNode),'LiteralNode')
                        nextNode.addChild(convNode);
                    else
                        nextNode.addChild(convNode.children(step(i)));
                    end
                end
                dnfNode.addChild(nextNode);
                step = self.nextcombination(sizes,step);                
            end
            %finally, remove all duplicate literal nodes from this node.
            
            for c = 1:numel(dnfNode.children)
                literals = {};
                childrenToRemove = [];
                childNode = dnfNode.children(c);
                for i = 1 : numel(childNode.children)
                    if isa(childNode.children(i),'LiteralNode')
                        if ~any(~cellfun(@isempty, strfind(literals,childNode.children(i).toString())))
                            literals{end+1} = childNode.children(i).toString();
                        else
                            childrenToRemove(end+1) = i;
                        end
                    end
                end
                childNode.children(childrenToRemove) = [];
            end
        end
        
        function res = isValid(self,sizes,step)
            % Check whether a given step is a valid possibility (no step
            % element larger than sizes
            % USAGE:
            %    res = Node.isValid(sizes,step)
            %
            % INPUTS:
            %    sizes:     An array of sizes
            %    step:      An array of suggested selections
            %
            % OUTPUTS:
            %    res:       ~any(step > sizes')
            %
            res = ~any(step > sizes');
        end
        
        function combination = nextcombination(self,sizes,step)
            % Get the next combination given the current combination
            % USAGE:
            %    combination = Node.nextcombination(sizes,step)
            %
            % INPUTS:
            %    sizes:     An array of maximal sizes
            %    step:      The current combination
            %
            % OUTPUTS:
            %    combination:   The next allowed element of step
            %                   incremented, and potentially others reset
            %                   to 1.
            %            
            combination = step;
            combination(1) = combination(1) + 1;
            for i=1:numel(sizes)
                if combination(i) > sizes(i)
                    if i < numel(sizes)
                        combination(i) = 1;
                        combination(i+1) = combination(i+1)  + 1;
                    end
                else
                    break;
                end
            end
        end
        
        
        function reduce(self)
            %we can merge any children of and nodes directly.
            mergeNode.children = [];
            childrenChanged = false;
            for i = 1:numel(self.children)
                cchild = self.children(i);                
                cchild.reduce()              
                %Check if the child has exactly one child. I
                if numel(cchild.children) == 1
                    %If there is only one child, we can directly add the
                    %child to this node.
                    mergeNode.children = [mergeNode.children,cchild.children];
                    childrenChanged = true;
                elseif isa(cchild,'AndNode')
                    mergeNode.children = [mergeNode.children,cchild.children];                    
                    childrenChanged = true;
                else                    
                    mergeNode.children = [mergeNode.children,cchild];
                end
            end
            if childrenChanged
                self.children = mergeNode.children;
                for i = 1:numel(self.children)
                    self.children(i).parent = self;        
                end
            end
        end
    end
    
end

