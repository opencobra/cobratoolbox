function [elements, newRule, rxnGeneMat] = parseBoolean(str, tokens, allowedElementChars)
% Parses a Boolean logic statement
%
% USAGE:
%
%     [elements, newRule] = parseBoolean(str, tokens, allowedElementChars)
%
% INPUTS:
%    str:                   Input string or cell array of boolean statements
%    tokens:                Allowed operators in boolean statements (optional,
%                           default '()&|~')
%    allowedElementChars:   Allowed characters in elements of the statement
%
% OUTPUTS:
%    elements:     Non-operator elements
%    newRule:      New rule translated to element numbers
%    rxnGeneMat:   If str is a cell array, rxnGeneMat is the normal
%                  COBRA rxnGeneMat (a matrix with rows corresponding
%                  to reactions, and columns corresponding to genes).
%
% .. Authors:
%       - Markus Herrgard 5/11/04
%       - Ben Heavner 5/20/13  (add cell array and rxnGeneMat functionality.)

if (nargin < 2)
    % Allowed separators for tokenizer
    tokens = '()&|~';
end
if (nargin < 3)
    % Allowed characters in elements
    allowedElementChars = '[A-Za-z0-9_\.\-]';
end

if ischar(str)  % if it's a string, use MH's code

    % changes (and, not, or) for (&, ~, |) within the string
    str1 = str;
    % str1 = regexprep(str1, '+',' & ');
    % str1 = regexprep(str1, ',',' | ');
    str1 = regexprep(str1, 'and ', '& ', 'ignorecase');
    str1 = regexprep(str1, 'or ', '| ', 'ignorecase');
    str1 = regexprep(str1, 'not ', '~ ', 'ignorecase');
    str1 = regexprep(str1, '\[', '');
    str1 = regexprep(str1, '\]', '');
    newRule = str1;

    elements = {};
    endStr = str1;
    cnt = 0;
    tmpRule = [];
    while (~isempty(endStr))
        % Tokenize the input string (one token at a time)
        [tok, endStr] = strtok(endStr, tokens);
        % Empty token?
        if (~isempty(tok))
            % Non-whitespace characters?
            if (regexp(tok, '\S') > 0)
                % Remove white space
                tok = tok(~isspace(tok));
                % Have we already got this token?
                if (sum(strcmp(elements, tok)) == 0)
                    % If not add this
                    cnt = cnt + 1;
                    elements{end + 1} = tok;
                end
                % The replacement token
                newTok = ['x(' num2str(cnt) ')'];
                % Remove troublesome characters ([])
                tok = regexprep(tok, '\[', '');
                tok = regexprep(tok, '\]', '');
                % Find all the instances of the original token
                [s, f] = regexp(newRule, tok);
                % Get the length of the rule (for replacing below)
                ruleLength = length(newRule);
                % Loop through all the instances
                replaceThisVector = false(length(s), 1);
                % Find out which instances to replace (do not want to
                % replace instances that are parts of other tokens)
                for i = 1:length(s)
                    % It's the only token so go ahead and replace
                    if ((s(i) == 1) && (f(i) == ruleLength))
                        replaceThisFlag = true;
                    elseif(s(i) == 1)  % Token at the beginning
                        replaceThisFlag = false;
                        if (isempty(regexp(newRule(f(i) + 1), ...
                                           allowedElementChars)))
                            % It's not a part of another token - replace
                            replaceThisFlag = true;
                        end
                    elseif(f(i) == ruleLength)  % Token at the end
                        replaceThisFlag = false;
                        if (isempty(regexp(newRule(s(i) - 1), ...
                                           allowedElementChars)))
                            % It's not a part of another token - replace
                            replaceThisFlag = true;
                        end
                    else  % Token in the middle of the string
                        if (isempty(regexp(newRule(f(i) + 1), ...
                                           allowedElementChars)) && ...
                            isempty(regexp(newRule(s(i) - 1), ...
                                           allowedElementChars)))
                            % It's not a part of another token - replace
                            replaceThisFlag = true;
                        else
                            % Part of another token - do not replace
                            replaceThisFlag = false;
                        end
                    end
                    replaceThisVector(i) = replaceThisFlag;
                end
                % Only replace the correct tokens
                s = s(replaceThisVector);
                f = f(replaceThisVector);
                nRep = length(s);
                for i = 1:nRep
                    % Add the beginning of the string for the first token
                    if (i == 1)
                        if (s(i) > 1)
                            tmpRule = newRule(1:(s(i) - 1));
                        else
                            tmpRule = [];
                        end
                    end
                    % Add the new token
                    tmpRule = [tmpRule newTok];
                    % Add the remainder of the string until the next token
                    % (if there is one)
                    if (i < nRep)
                        tmpRule = [tmpRule newRule((f(i) + 1):(s(i + 1) - 1))];
                    end
                    % Add the end of the string for the last token
                    if (i == nRep)
                        if (f(i) < ruleLength)
                            tmpRule = [tmpRule newRule(f(i) + 1:end)];
                        end
                    end
                end
                newRule = tmpRule;
            end
        end
    end

    if nargout == 3  % deal with a bad function call
        rxnGeneMat = [];
        string = ['rxnGeneMat is not meaningful when parseBoolean ' ...
                  'is called with a string. Did you mean to use a cell '...
                  'array? Empty matrix returned for rxnGeneMat.'];
        warning(string);
    end

elseif iscell(str)  % if it's a cell array, use BH code

    % changes (and, not, or) for (&, ~, |)
    newRule = regexprep(str, 'and ', '& ', 'ignorecase');
    newRule = regexprep(newRule, 'or ', '| ', 'ignorecase');
    newRule = regexprep(newRule, 'not ', '~ ', 'ignorecase');
    newRule = regexprep(newRule, '\[', '');
    newRule = regexprep(newRule, '\]', '');

    % make a cell array of all genes in each rule. This regexp assumes
    % genes are named with word characters, dashes, and/or hyphens.
    elements = regexp(newRule, '[\w-\.]*', 'match');
    elements = unique([elements{:}])';

    % initialize rxnGeneMat
    rxnGeneMat = zeros(length(str), length(elements));

    % pad gene names in grRules with a space to facilitate later regexp -
    % thanks to James Eddy for this bit of cleverness
    grRules_tmp = regexprep(strcat(newRule, {' '}), '\)', ' )');

    % loop over genes, replace grRules gene names with index from gene list
    % and build rxnGeneMat
    for gene_index = 1:length(elements)
        % populate rxnGeneMat
        rxnGeneMat(:, gene_index) = ~cellfun('isempty', ...
                                             regexp(grRules_tmp, [elements{gene_index}, '\s']));

        % build newRule
        number = int2str(gene_index);
        string = ['x(' number ') '];
        grRules_tmp = regexprep(grRules_tmp, ...
                                strcat(elements(gene_index), {' '}), string);
    end
    rxnGeneMat = sparse(rxnGeneMat);

    newRule = grRules_tmp;

    % string-based approach has & and | padded by whitespace, but rules
    % aren't. So manage the whitespace to ensure backwards compatibility
    newRule = regexprep(newRule, '\s', '');  % remove whitespace
    newRule = regexprep(newRule, '&', ' & ');  % pad &
    newRule = regexprep(newRule, '\|', ' | ');  % pad |

else
    string = ['The str variable passed to parseBoolean must be a '...
              'string or cell array.'];
    error(string)
end

end
