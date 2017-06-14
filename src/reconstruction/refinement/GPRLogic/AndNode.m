classdef (HandleCompatible) AndNode < Node
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function res = evaluate(self,assignment)
            res = true;
            for i=1:numel(self.children)
                child = self.children(i);
                if not(child.evaluate(assignment))
                    res = false;
                end
            end
            fprintf('%s : %i\n',self.toString(0),res);
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
                if strcmp(class(convNode),'LiteralNode')
                    sizes(end+1) = 1;
                else
                    sizes(end+1) = numel(convNode.children);
                end
                
                
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
                step = self.nextcombination(sizes,step);
                dnfNode.addChild(nextNode);
            end
            
        end
        
        function res = isValid(self,sizes,step)
            combination = step;
            for i=1:numel(sizes)
                if combination(i) > sizes(i)
                    res = 0;
                    break;
                else
                    res = 1;
                end
            end
        end
        
        function combination = nextcombination(self,sizes,step)
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
            c = numel(self.children);
            delchilds = [];
            for child = 1:c
                cchild = self.children(child);
                %If its not a literal node but only contains one child,
                %this can be merged (should normally not happen)
                if not(strcmp(class(cchild),'LiteralNode'))
                    if numel(cchild.children) <= 1
                        cchildchild = cchild.children(1);
                        cchildchild.reduce();
                        self.children(child) = cchildchild;
                        cchildchild.parent = self;
                        %we can't continue yet, as this child could now be
                        %an AND node. 
                        cchild = cchildchild;
                    end
                end
                %Add "AndNodes" directly to this node as they are
                %compatible
                if strcmp(class(self.children(child)),class(self))
                    for cc = 1:numel(cchild.children)
                        cchildchild = cchild.children(cc);
                        cchildchild.reduce();
                        self.children(end+1) = cchildchild;
                        cchildchild.parent = self;
                    end
                    delchilds(end+1) = child;
                end
                
            end
            %Remove Merged childs
            self.children(delchilds)  = [];
            %and reduce all children again.
            for child = 1:numel(self.children)
                
                cchild = self.children(child);
                cchild.reduce();
            end
        end
    end
    
end

