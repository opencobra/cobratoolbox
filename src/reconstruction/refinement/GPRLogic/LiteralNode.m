classdef (HandleCompatible) LiteralNode < Node 
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id;
    end
    
    methods
        function obj = LiteralNode(id)
            obj@Node();
            obj.id = id;
        end
        
        function dnfNode = convertToDNF(self)
            dnfNode = LiteralNode(self.id);            
        end
            
        function res = evaluate(self,assignment) 
            res = assignment(self.id);
            fprintf('%s : %i\n',self.id,res);
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
                res = 1;
            else
                res = 0;
            end
        end
%         function res = contains(self,literal)
%             if literal == self.id
%                 res = 1
%             else
%                 res = 0;
%             end
%         end
       function literals = getLiterals(self)    
           literals = {self.id};
        end
    end
    
       
        
end

