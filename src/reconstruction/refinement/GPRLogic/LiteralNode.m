classdef (HandleCompatible) LiteralNode < Node
    % LiteralNode is a class that represents a literal in a logical formula
    % For further documentation please have a look at the Node Class.
    % .. Authors
    %     - Thomas Pfau 2016
    
    properties
        id;
    end
    
    methods
        function obj = LiteralNode(id)
            obj@Node();
            obj.id = id;
        end
        
        function dnfNode = convertToDNF(self)
            dnfNode = AndNode();
            litnode = LiteralNode(self.id);
            dnfNode.addChild(litnode);
        end
        
        function cnfNode = convertToCNF(self)
            cnfNode = OrNode();
            litnode = LiteralNode(self.id);
            cnfNode.addChild(litnode);
        end
        
        function tf = deleteLiteral(self,literalID, keepClauses)
            %This function is not applicable to a literal node, as a
            %literal node cannot delete itself.            
            error('Cannot delete from a Literal Node.');
        end
        
        function res = evaluate(self,assignment, printLevel)
            if ~exist('printLevel','var')
                printLevel = 0;
            end
            res = assignment(self.id);
            if printLevel >= 1
                fprintf('%s : %i\n',self.id,res);
            end
        end
        
        function id = getID(self)
            id = self.id;
        end
        
        function res = toString(self,PipeAnd)
            if nargin < 2
                PipeAnd = 0;
            end
            res = [ 'x(' self.id ')'];
        end
        
        function reduce(self)
            
        end
        
        function res = contains(self,literal)
            if strcmp(self.id,literal)
                res = true;
            else
                res = false;
            end
        end
        function literals = getLiterals(self)
            literals = {self.id};
        end
    end
    
    
    
end

