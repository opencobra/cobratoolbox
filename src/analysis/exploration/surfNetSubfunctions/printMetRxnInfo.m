function printMetRxnInfo(metRxnInfo, firstFieldWtComma, printFieldName, fieldNameExcluded, ordMagMin, ordMagMax, nCharMax)
% Called by `surfNet.m` for printing information about a metabolite or reaction
%
% USAGE:
%    printMetRxnInfo(metRxnInfo, firstFieldWtComma, printFieldName, fieldNameNotPrinted, ordMagMin, ordMagMax, nCharMax)
%
% INPUTS:
%    metRxnInfo:     2-by-N cell array for N fields to be printed. The first row contains the field names and the second row 
%                    contains the corresponding information for a particular metabolite/reaction to be printed
%    firstFieldWtComma: a positive integer indicating after which field has been printed, start adding a comma separating each field
%    printFieldName:    true to print field names, false not to.
%    fieldNameExcluded: fields whose field names are not printed (useful only if printFieldName = true)
%    ordMagMin:      min. order of magnitude to be used when calling `numToFormattedString.m`
%    ordMagMax:      max. order of magnitude to be used when calling `numToFormattedString.m`
%    nCharMax:       max. number of characters to be used when calling `numToFormattedString.m`   

isstringExist = exist('isstring', 'builtin');
for kF = 1:size(metRxnInfo, 2)
    if kF >= firstFieldWtComma
        fprintf(', ');
    end
    if printFieldName && ~any(strcmp(metRxnInfo{1, kF}, fieldNameExcluded))
        fprintf('%s: ', metRxnInfo{1, kF});
    end
    if iscellstr(metRxnInfo{2, kF}) || (isstringExist && isstring(metRxnInfo{2, kF}))
        % concatenate if the cell content is a cell array of strings
        ToPrint = strjoin(metRxnInfo{2, kF}, '|');
    elseif ischar(metRxnInfo{2, kF})
        % strings
        ToPrint = metRxnInfo{2, kF};
    elseif isnumeric(metRxnInfo{2, kF})
        % if it is a value, format it properly
        ToPrint = numToFormattedString(metRxnInfo{2, kF}, ordMagMin, ordMagMax, nCharMax);
        if ~isscalar(metRxnInfo{2, kF})
            % format a string representing the matrix
            str = ToPrint(:, 1);
            for j = 2:size(ToPrint, 2)
                str = strcat(str, ', ', ToPrint(:, j));
            end
            ToPrint = strjoin(str, '; ');
        end
    else
        ToPrint = metRxnInfo{2, kF};
    end
    fprintf('%s', ToPrint);
end
fprintf('\n');
end
