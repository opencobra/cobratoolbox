classdef (HandleCompatible) OrNode < Node 
    % OrNode is a class that represents OR connections in a logical formula
    % For further documentation please have a look at the Node Class.
    % .. Authors
    %     - Thomas Pfau 2016

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
            % Assuming this is a DNF head node, removeDNFDuplicates checks
            % all present AND nodes for equality and removes replicates.
            % 
            % USAGE:
            %    Node.removeDNFduplicates()
            %            
            % OUTPUTS:
            %    Node:    A OrNode with all duplicate And nodes removed.
            %
            i = 1;
            literals = self.getLiterals();
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
           child = 1;            
            delchilds = [];
            while child <= numel(self.children)
                cchild = self.children(child);                
                %Merge Nodes from the same class.
                if strcmp(class(self.children(child)),class(self))                                        
                    %reduce the child, merging and removing "singular
                    %nodes"
                    cchild.reduce();
                    for cc = 1:numel(cchild.children)
                        cchildchild = cchild.children(cc);                        
                        self.children(end+1) = cchildchild;
                        cchildchild.parent = self;
                    end
                    delchilds(end+1) = child;
                %If a child is not a literal but has only one child, move
                %that child up.
                else
                    while ( numel(cchild.children) <= 1 && ~(isa(cchild,'LiteralNode')) )
                        cchildchild = cchild.children(1);                        
                        self.children(child) = cchildchild;
                        cchildchild.parent = self;
                        %we can't continue yet, as this child could now be
                        %an AND node. 
                        cchild = cchildchild;
                    end
                end   
                child = child + 1;
            end
            %Remove Merged childs
            self.children(delchilds)  = [];
            %And reduce all non literal and non same class children,
            %everything else should already be reduced.
            for child = 1:numel(self.children)
                if ~(strcmp(class(self.children(child)),class(self)) && ~(isa(cchild,'LiteralNode')) ) 
                    cchild = self.children(child);
                    cchild.reduce();
                end
            end
        end
        

    end
    
end

