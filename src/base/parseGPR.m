function [ruleString, totalGeneList,newGeneList] = parseGPR( grRuleString, currentGenes)
% Convert a GPR rule in string format to a rule in logic format. 
% We assume the following properties of GPR Rules:
% 1. There are no genes called "and" or "or" (in any capitalization).
% 2. A gene name does not contain any of the following characters:
% (),{},[],|,& and no whitespace.
% 3. The general format of a GPR is: Gene1 or Gene2 and (Gene3 or Gene4)
% 4. 'and' and 'or' operators as well as gene names have to be followed and preceded by either a
% whitespace character or a opening or closing bracket, respectively. Gene
% Names can also be at the beginning or the end of the string.
% 
% 
% USAGE:
%
%    [newGeneList,totalGeneList,ruleString] = generateRules(grRuleString,currentGenes)
%
% INPUT:
%    grRuleString:     The rule string in textual format.
%    currentGenes:     Names of all currently known genes. Encountered
%                      genes (column cell Array of Strings)
% OUTPUT:
%    ruleString:       The logical formula representing the grRuleString.
%                      Any position refers to the totalGeneList returned.
%    totalGeneList:    The concatenation of currentGenes and newGeneList
%    newGeneList:      A list of gene Names that were not present in
%                      currentGenes
%
% .. Author: -  Thomas Pfau Okt 2017 

if isempty(grRuleString) || ~isempty(regexp(grRuleString,'^[\s\(\{\[\}\]\)]*$')) 
    %If the provided string is empty or consists only of whitespaces or
    %brackets, i.e. it does not contain a rule
    ruleString = '';
    totalGeneList = currentGenes;
    newGeneList = {};
    return
end
    
tmp = regexprep(grRuleString, '[\]\}]',')'); %replace other brackets by parenthesis.
tmp = regexprep(tmp, '[\[\{]','('); %replace other brackets by parenthesis.
tmp = regexprep(tmp,'([\(])\s*','$1'); %replace all spaces after opening parenthesis
tmp = regexprep(tmp,'\s*([\)])','$1'); %replace all spaces before closing paranthesis.
tmp = regexprep(tmp, '([\)]\s?|\s)\s*(?i)(and)\s*?(\s?[\(]|\s)\s*', '$1&$3'); %Replace all ands
tmp = regexprep(tmp, '([\)]\s?|\s)\s*(?i)(or)\s*?(\s?[\(]|\s)\s*', '$1|$3'); %replace all ors
tmp = regexprep(tmp, '[\s]?&[\s]?', ' & '); %introduce spaces around ands
tmp = regexprep(tmp, '[\s]?\|[\s]?', ' | '); %introduce spaces around ors.

%Now, genes are items which do not have brackets, operators or whitespace
%characters
genes = regexp(tmp,'([^\(\)\|\&\s]+)','match');
%We have a new Gene List (which can be empty).
newGeneList = columnVector(setdiff(genes,currentGenes));
%So generate the new gene list.
totalGeneList = [currentGenes;newGeneList];
convertGenes = @(x) sprintf('x(%d)', find(ismember(totalGeneList,x)));
ruleString = regexprep(tmp, '([^\(\)\|\&\s]+)', '${convertGenes($0)}');
ruleString = regexprep(ruleString, '[\s]?x\(([0-9]+)\)[\s]?', ' x($1) '); %introduce spaces around entries.
ruleString = strtrim(ruleString); %Remove leading and trailing spaces
