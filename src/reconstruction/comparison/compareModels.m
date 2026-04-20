function [isSameModel,diffTable,why] = compareModels(modelA,modelB)
%compares modelA with modelB, looking for differences between the
%structures. Assumes any pair of NaN are identical.
%
% INPUT
% modelA:       structure
% modelB:       structure
% printLevel:
%
% OUTPUT
% isSameModel:   true if identical models, false otherwise
%
% diffTable:     table listing differences between fields in the input structures, e.g.
%                   field       modelA        modelB
%               ___________    ____________    ____
%               "DrGtPrior"    "1"             "0"
%               "DrGtPrior"    "quadratic"     "none"
%
% differences:   structure listing differences between models
%               *.reason: gives a text stack of why the difference occurred
%                         as well as a field
%               *.where: contains the indices and subfields of the structure
%                        where the comparison failed.
%
%
% Note: This function depends on structeq.m and celleq.m
%


funh2string=false;
ignorenan=true;
[isSameModel, why] = structeq(modelA,modelB,funh2string, ignorenan);

if isSameModel
    diffTable = [];
    why = [];
else
    % Convert to table
    diffTable = struct2table(why,'AsArray',1);
    diffTable = diffTable(:,2:end);
    diffTable.Properties.VariableNames{1} = 'field';
    diffTable.Properties.VariableNames{2} = inputname(1);
    diffTable.Properties.VariableNames{3} = inputname(2);
    diffTable.field = string(diffTable.field);
    for j = 1:size(diffTable,1)
        str = string(diffTable{j,1});
        %    Find the position of the dot
        dotPos = strfind(str, '.');
        if ~isempty(dotPos)
            str = eraseBetween(str, 1, dotPos);
        end
        diffTable.field(j) = str;
    end

    % 2. Create a formatting function
    % If the value is empty, return an empty char array (renders as blank)
    % If it's a number/string, return it as a char array (renders without quotes)
    formatter = @(x) char(strjoin(string(x), ', '));

    try
        % 3. Apply to your columns
        diffTable.(inputname(1)) = cellfun(formatter, diffTable.(inputname(1)), 'UniformOutput', false);
        diffTable.(inputname(2)) = cellfun(formatter, diffTable.(inputname(2)), 'UniformOutput', false);
    catch
        
    end

    % 4. Convert 'field' to char as well if you want quotes gone there too
    diffTable.field = cellstr(diffTable.field);
end


