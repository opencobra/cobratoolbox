function str = numToFormattedString(num, ordMagMin, ordMagMax, nChar, cellOutput)
% Convert numerical values in Matlab into formatted strings within a maximum
% of characters with format specific to the order of magnitude of the values. 
% For values larger or small than the thresholds, scientific notation is 
% used, otherwise decimal expression.
%
% USAGE:
%    s = numToFormattedString(num, ordMagMin, ordMagMax, cellOutput)
%
% INPUT:
%    num:         array of numerical values
%
% OPTIONAL INPUTS:
%    ordMagMin:   order of magitude below which the formatted string is in scientific notation (default -6, i.e., for values < 1e-6)
%    ordMagMin:   order of magitude above which the formatted string is in scientific notation (default 8, i.e., for values >= 1e8)
%    nChar:       number of character in the converted string, excluding the sign (default 8)
%    cellOutput:  true to have the output being a single cell of string if the input `num` is scalar, otherwise a string (default false) 
%
% OUTPUT:
%    str:         the formatted string or cell array of strings

if nargin < 2 || isempty(ordMagMin)
    ordMagMin = -6;
end
if nargin < 3 || isempty(ordMagMax)
    ordMagMax = 8;
end
if nargin < 4 || isempty(nChar)
    nChar = 8;
end
if nargin < 5
    cellOutput = false;
end
if nChar < 5
    % smallest possible is 5 character (considering scientific notation)
    nChar = 5;
end
if ordMagMax > nChar
    % no way to display e.g. 12345 in decimal expression  with only <= 4 characters
    ordMagMax = nChar;
end
if -ordMagMin > nChar - 2
    ordMagMin = 2 - nChar;
end
if ~isscalar(num)
    str = cell(size(num));
    for jD = 1:numel(num)
        str{jD} = numToFormattedString(num(jD), ordMagMin, ordMagMax, false);
    end
    return
end

if num ~= 0 && (abs(num) >= 10^ordMagMax || abs(num) < 10^(ordMagMin))
    str = sprintf(['%.' num2str(max([0, nChar - 6])) 'e'], num);  % exponential notation for very large and small values
else
    if isfloat(num)
        % digit used for the integral part of the number
        digitUsedInt = 1;  % 1 for any numbers of magnitude <= 1
        if abs(num) > 1
            digitUsedInt = floor(log10(abs(num))) + 1;
        end
        if  nChar - digitUsedInt <= 1
            % no decimal place is possible as it takes at least two characters
            str = num2str(round(num, 0));
        else
            % can round up to nChar - digitUsedInt - 1 decimal places
            str = sprintf(['%.' num2str(nChar - digitUsedInt - 1) 'f'], num);
            % trim trailing zeros
            str = regexprep(regexprep(str, '\.0+$', ''), '(\.\d*[1-9])0+$', '$1');
        end
    else
        str = num2str(num); %convert to string directly for non-floating values (integer)
    end
end
if cellOutput
    str = {str};
end
end