function [ruleString, totalGeneList, newGeneList] = parseGPR(grRuleString, currentGenes, preparsed, positions)
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
%    [ruleString, totalGeneList, newGeneList] = parseGPR(grRuleString, currentGenes, preparsed)
%
% INPUT:
%    grRuleString:     The rule string in textual format.
%    currentGenes:     Names of all currently known genes. Encountered
%                      genes (column cell Array of Strings)
% OPTIONAL INPUT:
%    preparsed:        Whether the sring inserted into the function was
%                      preparsed or not. If provided, it is assumed, that
%                      currentGenes ONLY contains the genes in this rule
%                      AND that positions is the actual position of each
%                      gene to be used for the rule.
%    positions:        Only used when preparsed is true.
%                      positions(ismember(currentGenes,gene)) will become
%                      the number used for that gene in the rule.
% OUTPUT:
%    ruleString:       The logical formula representing the grRuleString.
%                      Any position refers to the totalGeneList returned.
%    totalGeneList:    The concatenation of currentGenes and newGeneList
%    newGeneList:      A list of gene Names that were not present in
%                      currentGenes
%
% .. Author: -  Thomas Pfau Okt 2017

if nargin < 3 %This is faster than checking exist)
    preparsed = false;
end

%Preparsing and providing IDs allows a lot of things to be ignored, so we
%essentially have 2 distinct functions. One for preparsed and one for non
%preparsed.
if ~preparsed
    newGeneList = {};
    if isempty(grRuleString) || ~isempty(regexp(grRuleString,'^[\s\(\{\[\}\]\)]*$'))
        %If the provided string is empty or consists only of whitespaces or
        %brackets, i.e. it does not contain a rule
        ruleString = '';
        totalGeneList = currentGenes;
        return
    end
    grRuleString = preparseGPR(grRuleString);
    %Now, genes are items which do not have brackets, operators or whitespace characters
    genes = regexp(grRuleString,'([^\(\)\|\&\s]+)','match');

    %We have a new Gene List (which can be empty).
    for i = 1:length(genes)
        if ~any(strcmp(genes{i}, currentGenes))
            newGeneList{end+1} = genes{i};
        end
    end
    % make sure that the list is a column list
    if ~isempty(newGeneList)
        newGeneList = columnVector(unique(newGeneList));
    end
    %So generate the new gene list.
    totalGeneList = [currentGenes;newGeneList];
    % define the internal function for convertGenes
    convertGenes = @(x) sprintf('x(%d)',  find(strcmp(x, totalGeneList)));

else
    newGeneList = {};
    totalGeneList = currentGenes;
    convertGenes = @(x) sprintf('x(%d)',  positions(strcmp(x, totalGeneList)));
end

ruleString = regexprep(grRuleString, '([^\(\)\|\&\s]+)', '${convertGenes($0)}');
ruleString = regexprep(ruleString, '[\s]?x\(([0-9]+)\)[\s]?', ' x($1) '); %introduce spaces around entries.
ruleString = strtrim(ruleString); %Remove leading and trailing spaces
end