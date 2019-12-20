function tf = verifyRuleSyntax(ruleString)
% try to verify if a given rule string is syntactically correct
% USAGE:
%    tf = verifyRuleSyntax(ruleString)
%
% INPUT:
%    ruleString:    The string in rule format (i.e. x(1) | x(2) & x(3) ...)
%
% OUTPUT:
%    tf:            Whether the given string is evaluateable (i.e. the syntax is correct) 
%                   
persistent x

if isempty(x)
    % 10000 genes should be large enough for most models.
    x = true(10000,1); 
end

tf = true;

if ~isempty(ruleString)
    try
        temp = eval(ruleString);
        % if we reach this point it is fine
    catch ME
        % now, either our x is not large enough, or the formula is invalid.
        % lets grab the largest number from the formula
        try
            res = regexp(ruleString,'tokens');
            vals = cellfun(@(x) str2num(x{1}),res);
            % update x to the given values 
            x = true(max(vals),1);
            temp = eval(ruleString);
            % if we reach this point it is fine
        catch ME
            tf = false;
        end
    end
end