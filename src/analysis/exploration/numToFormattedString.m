function s = numToFormattedString(f, ordMagMin, ordMagMax, cellOutput)

if nargin < 4
    cellOutput = false;
end
if ~isscalar(f)
    s = cell(size(f));
    for jD = 1:numel(f)
        s{jD} = numToFormattedString(f(jD), ordMagMin, ordMagMax, false);
    end
    return
end
if abs(f) >= 1e-12 && (abs(f) >= 10^ordMagMax || abs(f) <= 10^(ordMagMin))
    s = sprintf('%.2e', f);  % exponential notation for very large and small values
else
    if isfloat(f)
        % decimal place or integer rounded to
        digitRound = floor(log10(abs(f)));
        digitRound = digitRound + (digitRound < 6);
        digitRound = min(-ordMagMin, ordMagMax - digitRound - 1);
        % need to use roundn(f, -digitRound) instead for R2014a or before
        s = sprintf(['%.' num2str(-ordMagMin) 'f'], round(f, digitRound));
        % trim trailing zeros
        s = regexprep(regexprep(s, '\.0+$', ''), '(\.\d*[1-9])0+$', '$1');
    else
        s = num2str(f); %convert to string directly for non-floating values (integer)
    end
end
if cellOutput
    s = {s};
end
end