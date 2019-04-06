function printMetRxnInfo(metRxnInfo, firstFieldWtComma, printFieldName, fieldNameNotPrinted, ordMagMin, ordMagMax)
isstringExist = exist('isstring', 'builtin');
for kF = 1:size(metRxnInfo, 2)
    if kF >= firstFieldWtComma
        fprintf(', ');
    end
    if printFieldName && ~any(strcmp(metRxnInfo{1, kF}, fieldNameNotPrinted))
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
        ToPrint = numToFormattedString(metRxnInfo{2, kF}, ordMagMin, ordMagMax);
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
