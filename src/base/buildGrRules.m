function rulesOut = buildGrRules(parsedGPR)
% 
% Takes the output of GPRparser (a cell array where each cell contains 
% the parsed representation of a GPR rule) and converts it back into a 
% string representation with parentheses around each gene complex. 
% It also removes duplicate gene entries within each complex and duplicate
% complexes across the rule.
%
% USAGE:
%       [rulesOut] = buildGrRules(parsedGPR) 
%
%   For example, if a parsed rule is given as:
%       { {'geneA', 'geneB', 'geneA'}, {'geneC'}, {'geneA', 'geneB'} }
%   then the output string will be:
%       '(geneA and geneB) or (geneC)'
%
% INPUT:
%       parsedGPR  - Cell array containing parsed GPR rules.
%
% OUTPUT:
%       rulesOut   - Cell array of strings with the reconstructed GPR rules.
%
% EXAMPLE:
%   if a parsed rule is given as:
%       { {'geneA', 'geneB', 'geneA'}, {'geneC'}, {'geneA', 'geneB'} }
%   then the output string will be:
%       {'(geneA and geneB) or (geneC)'}
%
% AUTHORS: Farid Zare, April 2025

numRxns = numel(parsedGPR);
rulesOut = cell(numRxns, 1);

for i = 1:numRxns
    ruleData = parsedGPR{i};
    
    % If the rule is empty, output an empty string.
    if isempty(ruleData) || (iscell(ruleData) && all(cellfun(@isempty, ruleData)))
        rulesOut{i} = '';
        continue;
    end
    
    % Check if ruleData is nested (each term is a cell array)
    if iscell(ruleData) && ~isempty(ruleData) && iscell(ruleData{1})
        % Nested structure: each inner cell array is a gene complex.
        terms = cell(1, numel(ruleData));
        for j = 1:numel(ruleData)
            genes = ruleData{j};
            if isempty(genes)
                termStr = '';
            else
                % Remove duplicates within the gene complex while preserving order
                uniqueGenes = unique(genes, 'stable');
                termStr = ['(' strjoin(uniqueGenes, ' and ') ')'];
            end
            terms{j} = termStr;
        end
    else
        % Flat structure: treat entire ruleData as one gene complex.
        uniqueGenes = unique(ruleData, 'stable');
        terms = {['(' strjoin(uniqueGenes, ' and ') ')']};
    end
    
    % Remove any empty terms.
    terms = terms(~cellfun('isempty', terms));
    % Remove duplicate complexes (e.g., (A and B) appearing twice)
    terms = unique(terms, 'stable');
    
    % Join the complexes with ' or ' to form the final rule string.
    if isempty(terms)
        rulesOut{i} = '';
    else
        rulesOut{i} = strjoin(terms, ' or ');
    end
end

end
