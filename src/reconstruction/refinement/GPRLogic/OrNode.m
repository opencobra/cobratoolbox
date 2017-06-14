classdef (HandleCompatible) OrNode < Node 
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function res = evaluate(self,assignment) 
            res = false;
            for i=1:numel(self.children)
                child = self.children(i);
                if child.evaluate(assignment)
                    res = true;
                    break;
                end
            end        
            %fprintf('%s : %i\n',self.toString(),res);
        end
        
                
        function dnfNode = convertToDNF(self)            
            dnfNode = OrNode();
            for c=1:numel(self.children)
                child = self.children(c);
                dnfNode.addChild(child.convertToDNF());
            end                       
        end
        
        function removeDNFduplicates(self)
            i = 1;
            literals = {};
            for i = 1:numel(self.children)
                child = self.children(i);
                literals = [literals, child.getLiterals];
            end
            literals = unique(literals);
            comps = false(numel(self.children),numel(literals));
            for i = 1:numel(self.children)
                comps(i,:) = ismember(literals,self.children(i).getLiterals());
            end
            [~,select] = unique(comps,'rows');
            self.children = self.children(select);            
        end
        
        function res = toString(self,PipeAnd)
            if nargin < 2
                PipeAnd = 0;
            end
            res = '(';
            for i=1:numel(self.children)
                child = self.children(i);
                if PipeAnd
                    res = [res child.toString(PipeAnd) ' | '];    
                else
                    res = [res child.toString(PipeAnd) ' or '];
                end
            end
            if length(res) > 2
                if PipeAnd
                    res = res(1:end-3);
                else
                    res = res(1:end-4);
                end
            end
            res = [res ')'];
        end
        function reduce(self)
            c = numel(self.children);
            delchilds = [];
            for child = 1:c
                cchild = self.children(child);
                %potentially add it to this node
                if not(strcmp(class(cchild),'LiteralNode'))
                    if numel(cchild.children) <= 1
                        for cc = 1:numel(cchild.children)
                            cchildchild = cchild.children(cc);
                            cchildchild.reduce();
                            self.children(child) = cchildchild;
                            cchildchild.parent = self;
                            cchild = cchildchild;
                        end
                    end
                end
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
            self.children(delchilds)  = [];
            for child = 1:numel(self.children)
                cchild = self.children(child);
                cchild.reduce();
            end   
        end
        
%         function res = contains(self,literal)
%             res = 0;
%             for c=1:numel(self.children)
%                 child = self.children(c);
%                 if child.contains(literal)
%                     res = 1;
%                     break;
%                 end
%             end
%         end
%             
    end
    
end

