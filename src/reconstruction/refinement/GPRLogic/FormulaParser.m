classdef FormulaParser < handle
    %Class to handle Formulas in COBRA Style reconstructions
    %   Detailed explanation goes here
    
    properties
        literalpat = 'x\([0-9]+\)';
        pat = '(?!\(.*\(.*?\))(\((.*?)\))'
        subformulas;
    end
    
    methods
        function obj = FormulaParser()
            obj.subformulas = containers.Map();
        end
        
        function Head = parseFormula(self,formula)            
            id = 1;
            %Lets replace our rules (x([0-9])) by the corresponding number
            formula = regexprep(formula,'x\(([0-9]+)\)','$1');
            exp = regexp(formula,self.pat,'match');
            newf = formula;
            if not(isempty(exp))
                self.subformulas(['$' num2str(id)]) = exp;
                newf = strrep(formula,exp{1},['$' num2str(id)]);
                finalid = ['$' num2str(id)];
                id = id +1;
            else
                if not(length(formula) == 0)
                    exp = formula;
                    self.subformulas(['$' num2str(id)]) = {exp};
                    newf = strrep(formula,exp,['$' num2str(id)]);
                    finalid = ['$' num2str(id)];
                    id = id+1;
                end
            end
            while not(strcmp(newf,formula))
                exp = regexp(newf,self.pat,'match');
                formula = newf;
                if not(isempty(exp))
                    self.subformulas(['$' num2str(id)]) = exp;
                    newf = strrep(newf,exp{1},['$' num2str(id)]);
                    finalid = ['$' num2str(id)];
                    id = id +1;
                else
                    
                    if length(formula) > length(['$' num2str(id)])
                        exp = formula;
                        self.subformulas(['$' num2str(id)]) = {exp};
                        newf = strrep(formula,exp,['$' num2str(id)]);
                        finalid = ['$' num2str(id)];
                        id = id+1;
                    end
                end
                
            end
            Head = self.createNodeStructure(finalid);
        end
        
        
        function reduceFormula(self,Formula)            
            FormString = Formula.toString(0);
            Formula.reduce();
            while not(strcmp(FormString,Formula.toString(0)))
                FormString = Formula.toString(0);
                Formula.reduce();
            end
            
        end
        
        function HeadNode = createNodeStructure(self,finalid)
            if self.subformulas.isKey(finalid)
                currentstring = self.subformulas(finalid);
                currentstring = currentstring{1};
                pos = find(regexp(currentstring,'( or )|( OR )|( Or )| \| | \|\|'));
                if not(isempty(pos))
                    HeadNode = OrNode();
                    literals = strsplit(regexprep(currentstring,'( or )|( OR )|( Or )|( \| )|( \|\| )', '$$'),'$$');
                    for i=1:numel(literals)
                        pos = find(regexp(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )'));
                        if not(isempty(pos))
                            NewNode = AndNode();
                            HeadNode.addChild(NewNode);
                            andliterals = strsplit(regexprep(literals{i},'( and )|( AND )|( And )|( \& )|( \&\& )', '$$'),'$$');
                            for j = 1:numel(andliterals)
                                literal = andliterals{j};
                                literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                                %                                literal = literal{1};
                                NewNode.addChild(self.createNodeStructure(literal));
                            end
                        else
                            literal = literals{i};
                            literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                            %literal = literal{1};
                            HeadNode.addChild(self.createNodeStructure(literal));
                        end
                        
                    end
                else
                    pos = find(regexp(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )'));
                    if not(isempty(pos))
                        %there are only Ands in this node
                        HeadNode = AndNode();
                        literals = strsplit(regexprep(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )', '$$'),'$$');
                        for i=1:numel(literals)
                            literal = literals{i};
                            literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                            %                                literal = literal{1};
                            HeadNode.addChild(self.createNodeStructure(literal));
                        end
                    else
                        %We have literals which were seperated by brackets
                        %(or additional brackets). so just parse the
                        %current node ignoring the brackets.
                        nodestring = regexprep(currentstring,'\[|\]|\{|\}|\(|\)|\s','');
                        HeadNode = self.createNodeStructure(nodestring);
                    end
                end
                
            else
                %this either represents a literal OR the Head node without
                %any brackets
                currentstring = finalid;
                pos = find(regexp(currentstring,'( or )|( OR )|( Or )|( \| )|( \|\| )'));
                if not(isempty(pos))
                    HeadNode = OrNode();
                    literals = strsplit(regexprep(currentstring,'( or )|( OR )|( Or )|( \| )|( \|\| )', '$$'),'$$');
                    for i=1:numel(literals)
                        pos = find(regexp(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )'));
                        if not(isempty(pos))
                            NewNode = AndNode();
                            HeadNode.addChild(NewNode);
                            andliterals = strsplit(regexprep(literals{i},'( and )|( AND )|( And )|( \& )|( \&\& )', '$$'),'$$');
                            for j = 1:numel(andliterals)
                                literal = andliterals{j};
                                literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                                %                                literal = literal{1};
                                NewNode.addChild(self.createNodeStructure(literal));
                            end
                        else
                            literal = literals{i};
                            literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                            %literal = literal{1};
                            HeadNode.addChild(self.createNodeStructure(literal));
                        end
                        
                    end
                else
                    pos = find(regexp(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )'));
                    if not(isempty(pos))
                        %there are only Ands in this node
                        HeadNode = AndNode();
                        literals = strsplit(regexprep(currentstring,'( and )|( AND )|( And )|( \& )|( \&\& )', '$$'),'$$');
                        for i=1:numel(literals)
                            literal = andliterals{j};
                            literal = regexprep(literal,'\[|\]|\{|\}|\(|\)|\s','');
                            %                                literal = literal{1};
                            HeadNode.addChild(self.createNodeStructure(literal));
                        end
                    else
                        %Now there are no ORs nor ANDs in the node, so it
                        %is a literal!
                        %This SHOULD be a node representing a single literal.
                        %thus we will remove any whitespace, and any brackets and
                        %create a literal node.
                        literalstring = regexprep(finalid,'\[|\]|\{|\}|\(|\)|\s','');
                        %literalstring = literalstring{1};
                        HeadNode = LiteralNode(literalstring);
                    end
                    
                end
                
            end            
            
        end
        
    end
    
end

