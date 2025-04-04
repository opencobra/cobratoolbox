function modelOut = generateRules(model)
% This function generates standard rules field in a genome-scale model
%
% USAGE:
%           modelOut = generateRules(model)
%
% INPUTS:
%   model - COBRA model structure with fields 'genes' and 'grRules'
%
% OUTPUTS:
%   modelOut - updated model with 'rules' field populated
%
% ...Author: Farid Zare, April 2025
%

    % Initialise rules cell array
    model.rules = cell(size(model.grRules));

    % Loop through each grRule
    for i = 1:length(model.grRules)
        grRule = strtrim(model.grRules{i});

        if isempty(grRule)
            model.rules{i} = '';
            continue;
        end

        % Escape parentheses and split on gene names using regex
        tokens = regexp(grRule, '[^\s()]+', 'match');  % Extract tokens (genes and operators)

        % Replace gene names with x(index) format
        for j = 1:length(tokens)
            gene = tokens{j};

            if any(strcmpi(gene, {'and', 'or'}))
                continue;  % skip logical operators
            end

            % Find gene index in model.genes
            geneIndex = find(strcmp(model.genes, gene), 1);
            if isempty(geneIndex)
                error(['Gene "' gene '" not found in model.genes.']);
            end

            % Replace gene name with x(index)
            grRule = regexprep(grRule, ['(?<!\w)' regexptranslate('escape', gene) '(?!\w)'], ['x(' num2str(geneIndex) ')']);
        end

        % Replace logical operators
        grRule = strrep(grRule, 'and', '&');
        grRule = strrep(grRule, 'or', '|');

        % Store in model.rules
        model.rules{i} = grRule;
    end

    % Return updated model
    modelOut = model;

end
