% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
function [elements,newRule] = parseBoolean(str,tokens,allowedElementChars)
%parseBoolean Parses a Boolean logic statement
%
% [elements,newRule] = parseBoolean(str,tokens,allowedElementChars)
%
% str                   Input string
% tokens                Allowed operators in boolean statements (optional, default '()&|~')
% allowedElementChars   Allowed characters in elements of teh statement
%
% elements              Non-operator elements
% newRule               New rule translated to element numbers
%
% Markus Herrgard 5/11/04

if (nargin < 2)
    % Allowed separators for tokenizer
    tokens = '()&|~';
end
if (nargin < 3)
    % Allowed characters in elements
    allowedElementChars = '[A-Za-z0-9_\.\-]'; 
end
% changes (and, not, or) for (&, ~, |) within the string
str1=str;
%str1 = regexprep(str1, '+',' & ');
%str1 = regexprep(str1, ',',' | ');
str1 = regexprep(str1, 'and ', '& ','ignorecase');
str1 = regexprep(str1, 'or ', '| ','ignorecase');
str1 = regexprep(str1, 'not ', '~ ','ignorecase');
str1 = regexprep(str1,'\[','');
str1 = regexprep(str1,'\]','');
newRule = str1;

elements = {};
endStr = str1;
cnt = 0;
tmpRule = [];
while (~isempty(endStr))
    % Tokenize the input string (one token at a time)
    [tok,endStr] = strtok(endStr,tokens);
    % Empty token?
    if (~isempty(tok))
        % Non-whitespace characters?
        if (regexp(tok,'\S') > 0)
            % Remove white space
            tok = tok(~isspace(tok));
            % Have we already got this token?
            if (sum(strcmp(elements,tok)) == 0)
                % If not add this
                cnt = cnt + 1;
                elements{end+1} = tok;
            end
            % The replacement token
            newTok = ['x(' num2str(cnt) ')'];
            % Remove troublesome characters ([])
            tok = regexprep(tok,'\[','');
            tok = regexprep(tok,'\]','');
            % Find all the instances of the original token 
            [s,f] = regexp(newRule,tok);
            % Get the length of the rule (for replacing below)
            ruleLength = length(newRule);
            % Loop through all the instances
            replaceThisVector = false(length(s),1);
            % Find out which instances to replace (do not want to replace
            % instances that are parts of other tokens)
            for i = 1:length(s)
                % It's the only token so go ahead and replace
                if ((s(i) == 1) & (f(i) == ruleLength))
                   replaceThisFlag = true;
                elseif (s(i) == 1) % Token at the beginning of string
                    if (isempty(regexp(newRule(f(i)+1),allowedElementChars)))
                        % It's not a part of another token - replace
                        replaceThisFlag = true;    
                    else
                        % Part of another token - do not replace
                        replaceThisFlag = false;
                    end
                elseif (f(i) == ruleLength) % Token at the end of string
                    if (isempty(regexp(newRule(s(i)-1),allowedElementChars)))
                        % It's not a part of another token - replace
                        replaceThisFlag = true;    
                    else
                        % Part of another token - do not replace
                        replaceThisFlag = false;
                    end
                else % Token in the middle of the string
                    if (isempty(regexp(newRule(f(i)+1),allowedElementChars)) & isempty(regexp(newRule(s(i)-1),allowedElementChars)))
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
                        tmpRule = newRule(1:(s(i)-1));
                    else
                        tmpRule = [];
                    end
                end
                % Add the new token
                tmpRule = [tmpRule newTok];
                % Add the remainder of the string until the next token (if
                % there is one)
                if (i < nRep)
                    tmpRule = [tmpRule newRule((f(i)+1):(s(i+1)-1))];    
                end
                % Add the end of the string for the last token
                if (i == nRep)
                    if (f(i) < ruleLength)
                        tmpRule = [tmpRule newRule(f(i)+1:end)];       
                    end
                end
            end
            newRule = tmpRule;
        end
    end
end
    
