function parsed = cobraParseModelFormula(formula, variableNames)
% Parses a model formula in Wilkinson notation (the subset used by fitglm and
% fitlm call sites), without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    parsed = cobraParseModelFormula(formula, variableNames)
%
% INPUTS:
%    formula:        character vector or string scalar 'response ~ terms', where terms
%                    are separated by '+' and are a variable name, an interaction 'a:b'
%                    (any number of factors), a crossing 'a*b' (= a + b + a:b), a removal
%                    '- term', or a random-effects term '(1|g)'
%    variableNames:  cell array of the variable names that may appear (for example
%                    tbl.Properties.VariableNames)
%
% OUTPUT:
%    parsed:         structure with fields
%
%                      * response - name of the response variable
%                      * terms - 1 x t cell array; each term is a 1 x k cell array of the
%                        variable names it multiplies (k = 1 for a main effect), ordered by
%                        k (main effects first) and, within k, by first appearance
%                      * randomGroups - 1 x r cell array of the grouping variables of the
%                        random-intercept terms (1|g), empty when there is none
%                      * predictors - unique variable names of the terms, in order of
%                        first appearance
%
% EXAMPLE:
%
%    parsed = cobraParseModelFormula('y ~ a*b - a:b + c', {'y', 'a', 'b', 'c'});
%    % parsed.terms = {{'a'}, {'b'}, {'c'}}
%
% NOTE:
%    Helper of cobraFitglm and cobraFitlm (plain-MATLAB replacements of fitglm and fitlm);
%    semantics: specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G3
%    section 6. The intercept is always included (explicit '1', '-1', '0', powers '^',
%    nesting '/' and random slopes raise an error naming the term). Whitespace is ignored.
%    The order of the terms within one interaction order follows the formula (MathWorks
%    documents main effects before interactions; its order within an order is
%    UNCONFIRMED, and the call sites give the variables in formula order).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~(ischar(formula) || (isstring(formula) && isscalar(formula)))
    error('COBRA:cobraParseModelFormula:invalidInput', 'cobraParseModelFormula: formula must be a character vector or string scalar.');
end
text = regexprep(char(formula), '\s', '');
sides = strsplit(text, '~');
if numel(sides) ~= 2 || isempty(sides{1}) || isempty(sides{2})
    error('COBRA:cobraParseModelFormula:invalidInput', 'cobraParseModelFormula: formula must have the form ''response ~ terms''.');
end
response = sides{1};
checkName(response, variableNames);

% random-effects terms (1|g)
randomGroups = regexp(sides{2}, '\(1\|([A-Za-z]\w*)\)', 'tokens');
randomGroups = cellfun(@(t) t{1}, randomGroups, 'UniformOutput', false);
fixedText = regexprep(sides{2}, '\+?\(1\|[A-Za-z]\w*\)', '');
if contains(fixedText, '(') || contains(fixedText, ')')
    error('COBRA:cobraParseModelFormula:unsupportedTerm', ...
        'cobraParseModelFormula: unsupported term in ''%s'' (only random intercepts (1|g) are supported).', sides{2});
end

% split into signed terms: a leading '-' removes the term
[tokens, signs] = splitSigned(fixedText);
terms = {};
removed = {};
for k = 1:numel(tokens)
    expanded = expandTerm(tokens{k}, variableNames);
    if signs(k) > 0
        terms = [terms, expanded]; %#ok<AGROW>
    else
        removed = [removed, expanded]; %#ok<AGROW>
    end
end
% canonical keys (factors sorted) for duplicate and removal detection
keyOf = @(term) strjoin(sort(term), ':');
termKeys = cellfun(keyOf, terms, 'UniformOutput', false);
[~, firstIndex] = unique(termKeys, 'stable');
terms = terms(firstIndex);
termKeys = termKeys(firstIndex);
if ~isempty(removed)
    removedKeys = cellfun(keyOf, removed, 'UniformOutput', false);
    terms = terms(~ismember(termKeys, removedKeys));
end
% main effects first, then by order, stable within an order
orders = cellfun(@numel, terms);
[~, byOrder] = sort(orders);
terms = terms(byOrder);
for k = 1:numel(randomGroups)
    checkName(randomGroups{k}, variableNames);
end
predictors = unique([terms{:}], 'stable');
parsed = struct('response', response, 'terms', {terms}, 'randomGroups', {randomGroups}, ...
    'predictors', {predictors});
end

function [tokens, signs] = splitSigned(text)
% Splits 'a+b-c' into {'a','b','c'} with signs [1 1 -1]
tokens = {};
signs = [];
current = '';
sign = 1;
for character = [text '+']
    if character == '+' || character == '-'
        if ~isempty(current)
            tokens{end + 1} = current; %#ok<AGROW>
            signs(end + 1) = sign; %#ok<AGROW>
        end
        current = '';
        sign = 1 - 2 * (character == '-');
    else
        current(end + 1) = character; %#ok<AGROW>
    end
end
end

function expanded = expandTerm(token, variableNames)
% Expands one term: a, a:b, a*b (all sub-interactions); returns a cell of terms
if any(strcmp(token, {'1', '0'})) || contains(token, '^') || contains(token, '/')
    error('COBRA:cobraParseModelFormula:unsupportedTerm', 'cobraParseModelFormula: unsupported term ''%s''.', token);
end
if contains(token, '*')
    factors = strsplit(token, '*');
    expanded = {};
    for subsetSize = 1:numel(factors)
        combinations = nchoosek(1:numel(factors), subsetSize);
        for row = 1:size(combinations, 1)
            expanded{end + 1} = factors(combinations(row, :)); %#ok<AGROW>
        end
    end
else
    expanded = {strsplit(token, ':')};
end
for k = 1:numel(expanded)
    for f = 1:numel(expanded{k})
        checkName(expanded{k}{f}, variableNames);
    end
end
end

function checkName(name, variableNames)
% The name must be one of the variables
if ~any(strcmp(name, variableNames))
    error('COBRA:cobraParseModelFormula:unknownVariable', 'cobraParseModelFormula: unknown variable ''%s'' in the formula.', name);
end
end
