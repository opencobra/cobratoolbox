function metadata = readMetadataForPersephone(metadataPath)
% readMetadataForPersephone
% 
% DESCRIPTION:
%    This function loads a metadata file into a MATLAB table. It accounts for:
%    - Preserving the full variable names by disabling automatic truncation.
%    - Capturing variable units if provided in the second row of the file.
%    - Storing the captured units in the 'VariableUnits' property of the table.
%
% USAGE:
%    metadata = readMetadataForPersephone(metadataPath)
%
% INPUTS:
%    metadataPath: A string specifying the path to the metadata file 
%                  (in CSV or XLSX format).
%
% OUTPUTS:
%    metadata: A MATLAB table containing the processed metadata. 
%              Variable units, if present in the second row of the file, 
%              are stored in the table's 'VariableUnits' property.
%
% NOTES:
%    - If variable names exceed 64 characters, they are truncated, but the 
%      true variable names are preserved in the 'VariableDescriptions' property.
%    - Warnings related to variable name truncation are suppressed to avoid 
%      unnecessary console output.
%
% AUTHORS:
%    Tim Hensen, January 2025
%

arguments
    metadataPath (1, :) {mustBeNonempty, mustBeText}
end

% Read the metadata table. If the variable names have more than 64
% characters, the variable names in the table will be truncated. We account
% for this later, so this warning is ignored here.
warning('off')
opts = detectImportOptions(metadataPath, 'VariableNamingRule', 'preserve'); 
opts = setvartype(opts, opts.VariableNames(1), 'string');
metadataTable = readtable(metadataPath, opts); 
warning('on')

% Check if metadata table is not empty
validateattributes(metadataTable, {'table'}, {'nonempty'}, mfilename, 'metadataTable')


% % If the metadata table has a second row with units, we need to remove that
% % row from the loaded metadataTable and store it in the VariableUnits
% % property.
if any(matches(metadataTable{1,1},{'unit','units'},'ignoreCase',true))
    % Remove the second header line from the table
    metadataTable(1,:) = [];
end

% Set output
metadata = metadataTable;
end
