function formattedTable = readInputTableForPipeline(tablePath)
% Reads tables, such as text files, that are needed as input data for
% DEMETER in a format fit for the pipeline. The necessary inputs depend on
% the version of MATLAB.
%
% USAGE:
%
%    formattedTable = readInputTableForPipeline(tablePath)
%
% INPUT
% tablePath             Path to file with the table to read in text or
%                       table format
%
% OUTPUT
% formattedTable        Table in cell array format
%
% .. Author:
%       - Almut Heinken, 09/2021


if contains(tablePath,'.txt')
    if contains(version,'(R202') % for versions of MATLAB R2020a and newer
        formattedTable = readtable(tablePath, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', true);
        if ~isempty(formattedTable.Properties.VariableDescriptions)
            formattedTable = [formattedTable.Properties.VariableDescriptions;table2cell(formattedTable)];
        else
            formattedTable = [formattedTable.Properties.VariableNames;table2cell(formattedTable)];
        end
    else
        formattedTable = table2cell(readtable(tablePath, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', false, 'TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']));
    end
else % if the table is not a text file
    if contains(version,'(R202') % for versions of MATLAB R2020a and newer
        if contains(tablePath,'.tsv')
            % need workaround to read in tsv file
            gettab=tdfread(tablePath);
            getcols=fieldnames(gettab);
            formattedTable={};
            for j=1:length(getcols)
                formattedTable{1,j}=getcols{j};
                if isnumeric(gettab.(getcols{j}))
                    formattedTable(2:length(gettab.(getcols{j}))+1,j)=cellstr(num2str(gettab.(getcols{j})));
                    formattedTable(2:end,j) = strrep(formattedTable(2:end,j),' NaN','');
                    formattedTable(2:end,j) = strrep(formattedTable(2:end,j),'NaN','');
                else
                    formattedTable(2:length(cellstr(gettab.(getcols{j})))+1,j)=cellstr(gettab.(getcols{j}));
                end
            end
        else
            formattedTable = readtable(tablePath, 'ReadVariableNames', true);
            if ~isempty(formattedTable.Properties.VariableDescriptions)
                formattedTable = [formattedTable.Properties.VariableDescriptions;table2cell(formattedTable)];
            else
                formattedTable = [formattedTable.Properties.VariableNames;table2cell(formattedTable)];
            end
        end
        
    else
        if contains(tablePath,'.tsv')
            formattedTable = table2cell(readtable(tablePath, 'Delimiter', 'tab', 'FileType', 'text', 'ReadVariableNames', false));
        else
            formattedTable = table2cell(readtable(tablePath, 'ReadVariableNames', false));
        end
    end
end

end