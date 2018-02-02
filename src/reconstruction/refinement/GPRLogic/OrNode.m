classdef (HandleCompatible) OrNode < Node
    % OrNode is a class that represents OR connections in a logical formula
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
            res = false;
            for i=1:numel(self.children)
                child = self.children(i);
                if child.evaluate(assignment,printLevel)
                    res = true;
                    break;
                end
            end
            if printLevel >= 1
                fprintf('%s : %i\n',self.toString(),res);
            end
        end
        
        
        function dnfNode = convertToDNF(self)
            dnfNode = OrNode();
            for c=1:numel(self.children)
                child = self.children(c);
                %If the child is again an or node, we need to add all
                %children of that child directly to this node.
                if isa(child,'OrNode')
                    DNFChild = child.convertToDNF();
                    for cc = 1:numel(DNFChild.children)
                        dnfNode.addChild(DNFChild.children(cc))
                    end
                else
                    dnfNode.addChild(child.convertToDNF());
                end
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
        
        function deleteLiteral(self,literalID)
            toDelete = false(size(self.children));
           % originalNodeString = self.toString(1);            
            for child = 1:numel(self.children)
                cchild = self.children(child);
                if cchild.contains(literalID)
                    if isa(cchild,'LiteralNode')
                        toDelete(child) = true; %This is a child that needs to be removed.
                    else
                        %Remove it from the child
                        cchild.deleteLiteral(literalID)
                        %and, if that child now only has one child left,
                        %move that child up.
                        if numel(cchild.children) <= 1
                            if numel(cchild.children) == 1
                                %Add the child only if there is anything.
                                if ~exist('childrenToAdd','var')
                                    childrenToAdd = cchild.children;
                                else
                                    childrenToAdd(end+1) = cchild.children;
                                end
                            end
                            toDelete(child) = true; %This child is discarded
                        end
                    end
                end
            end
            self.children(toDelete) = [];
            if exist('childrenToAdd','var')
                for child = 1:numel(childrenToAdd)
                    newChild = childrenToAdd(child);
                    self.children(end+1) = newChild;
                    newChild.parent = self;
                end
            end
          %  fprintf('Removing Literal %s from the following node:\n%s\nLeads to the node:\n%s\n',literalID,originalNodeString,self.toString(1));
        end
        
        function reduce(self)
            mergeNode.children = [];
            for i = 1:numel(self.children)
                cchild = self.children(i);
                cchild.reduce()
                %Check if the child has exactly one child. I
                if numel(cchild.children) == 1
                    %If there is only one child, we can directly add the
                    %child to this node.
                    mergeNode.children = [mergeNode.children,cchild.children];
                elseif isa(cchild,'OrNode')
                    %If its an OR node, we can directly add all children to
                    %this node.
                    mergeNode.children = [mergeNode.children,cchild.children];
                else
                    mergeNode.children = [mergeNode.children,cchild];
                end
            end
            self.children = mergeNode.children;
            for i = 1:numel(self.children)
                self.children(i).parent = self;
            end
        end
        
        
    end
    
end

