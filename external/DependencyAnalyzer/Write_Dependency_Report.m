%% #######################     HEADER START    ############################
%*************************************************************************
%
% Filename:				Write_Dependency_Report.m
%
% Author:				A. Mering
% Created:				22-Feb-2013
%
% Changed on:			XX-XX-XXXX  by USERNAME		SHORT CHANGE DESCRIPTION
%						XX-XX-XXXX  by USERNAME		SHORT CHANGE DESCRIPTION
%
%*************************************************************************
%
% Description:
%		Starting from dependency report, fill and format the excel file
% 
%
% Input parameter:
%		- directory_structure:		Structure containing the informatino about the directory structure
%		- file_list:				Cell array of file names for which the dependency is analysed
%		- usage_list:				Cell array of logical arrays indicating the dependencies resolved
%
% Output parameter:
%		- output_arg1:		DESCRIPTION
%		- output_arg2:		DESCRIPTION
%
%*************************************************************************
%
% Intrinsic Subfunctions
%		- ColumnNumbers_to_ExcelRange	Build Excel range out of continous list of column numbers
%		- Put_FileNames_to_Table		Write the structure information to the excel table
%
% Intrinsic Callbacks
%		- callback1
%
% #######################      HEADER END     ############################

%% #######################    FUNCTION START   ############################
function Write_Dependency_Report(directory_structure, file_list, usage_list)

%% Initialization
num_header_height = directory_structure.Statistics_Num_Dir_Level_Below + 2;
num_header_width  = directory_structure.Statistics_Num_Files_Below + directory_structure.Statistics_Num_Files_Current;

left_table_offset = 1 + num_header_height;
upper_table_offset = 1 + num_header_width;

%% Open Excel instance and initialize
fprintf('Creating Excel instance...\n');
try
	excel = actxGetRunningServer('Excel.Application');
	
catch
	excel = actxserver('Excel.Application');
end

excel.Visible = 0;          % DEBUG only

% Creat new document with one sheet
workbook = excel.Workbooks.Add;

sheets = workbook.Sheets;
for n = sheets.Count : -1 : 2
    sheets.Item(n).Delete;
end
sheet = sheets.Item(1);

sheet.Name = 'Dependency_Map';

%% Set up dependency table

range = ColumnNumbers_to_ExcelRange(sheet,  left_table_offset + [0:num_header_width ], left_table_offset + [0:num_header_width ]);
range.Borders.Color = 0;

range = ColumnNumbers_to_ExcelRange(sheet,  2:left_table_offset, 2:left_table_offset);
range.Merge;
range.Borders.Color = 0;
range.Border.Weight = 4;
range.Border.Item(5).Weight = 4;

% Put header and tell order of file names
fprintf('Writing filenames to the table header...\n');
FileName_List = Put_FileNames_to_Table(sheet, left_table_offset + 1, 2, 2 + directory_structure.Statistics_Num_Dir_Level_Below + 1, num_header_width + left_table_offset, 1, directory_structure);

% Indicate the dependencies

% remap the file_list entries to the order of the Excel file
for n = 1: length(file_list)
	file_list_FileName_pos(n) = find(strcmp(FileName_List, file_list{n}), 1, 'first');	
end

% Get the dependency map
fprintf('Generating dependency map...\n');
dependency_map = cell(length(FileName_List), length(FileName_List));
for n = 1: length(file_list)
	dependency_map(file_list_FileName_pos(n), file_list_FileName_pos(usage_list{n})) = {'X'};
end

% Write the dependency map
range = ColumnNumbers_to_ExcelRange(sheet,  left_table_offset + [1:num_header_width], left_table_offset + [1:num_header_width]);
range.HorizontalAlignment = 3;
range.VerticalAlignment = 3;
range.Font.Bold = 1;
range.Value = dependency_map;

% finalize layout
fprintf('Finalize layout...\n');
range = ColumnNumbers_to_ExcelRange(sheet,  2 + [0:num_header_width + directory_structure.Statistics_Num_Dir_Level_Below + 1], 2 + [0:num_header_width + directory_structure.Statistics_Num_Dir_Level_Below + 1]);
range.Border.Item(7).Weight = 4;
range.Border.Item(8).Weight = 4;
range.Border.Item(9).Weight = 4;
range.Border.Item(10).Weight = 4;



% Fit cell width
sheet.Rows.AutoFit;
sheet.Columns.AutoFit;

excel.Visible = 1;
% fix window
fprintf('Finish dependency map...\n');
range = ColumnNumbers_to_ExcelRange(sheet,  left_table_offset+ 1, left_table_offset+ 1);
range.Select
excel.ActiveWindow.FreezePanes = 1;

% #######################     FUNCTION END    ############################

%% #######################  SUBFUNCTION START  ############################

%% Write filenames to the excel table
function filename_list = Put_FileNames_to_Table(sheet, start_column, start_row, end_row_header, end_row_table, directory_level, directory_structure)

% directory_name_color_level = cellfun(@(x) x*[1, 1, 1], {160/255, 175/255, 190/255, 205/255, 220/255, 235/255, 250/255}, 'UniformOutput', false);
directory_name_color_level = {[180 180 180]/255, [255 229 191]/255, [200 200 200]/255, [255 209 140]/255,  [180 180 180]/255};

RGB_to_Excel_Color = @(x) hex2dec(sprintf('%s',dec2hex(fliplr(x)*255,2)'));

if ~exist('filename_list')
	filename_list = {};
end

% write directory header
num_files = directory_structure.Statistics_Num_Files_Below + directory_structure.Statistics_Num_Files_Current;
% horizontal entries
range = ColumnNumbers_to_ExcelRange(sheet, start_row, start_column + [0:num_files - 1]);
range.Merge;
range.Value = directory_structure.DirName;
range.HorizontalAlignment = 3;
range.VerticalAlignment = 2;
range.Font.Bold = 1;
range.Font.Size = 12;
range.Font.Name = 'Arial';
range.Border.Color = RGB_to_Excel_Color([0,0,0]);
range.Border.Weight = -4138;
range.Interior.Color = RGB_to_Excel_Color(directory_name_color_level{directory_level});
% range.WrapText = 1;

% vertical entries
range = ColumnNumbers_to_ExcelRange(sheet,  start_column + [0:num_files - 1], start_row);
range.Merge;
range.Value = directory_structure.DirName;
range.VerticalAlignment = 2;
range.HorizontalAlignment = 3;
range.Font.Bold = 1;
range.Font.Size = 12;
range.Font.Name = 'Arial';
range.Border.Color = RGB_to_Excel_Color([0,0,0]);
range.Border.Weight = -4138;
range.Orientation = 90;
range.Interior.Color = RGB_to_Excel_Color(directory_name_color_level{directory_level});
% range.WrapText = 1;

% set border of directory block
range = ColumnNumbers_to_ExcelRange(sheet, start_row:end_row_table,  start_column + [0:num_files - 1]);
range.Borders.Item(10).Color = RGB_to_Excel_Color([0,0,0]);
range.Borders.Item(10).Weight = -4138;
range = ColumnNumbers_to_ExcelRange(sheet,  start_column + [0:num_files - 1], start_row:end_row_table);
range.Borders.Item(9).Color = RGB_to_Excel_Color([0,0,0]);
range.Borders.Item(9).Weight = -4138;

directory_content = fieldnames(directory_structure);

file_pos = find(~cellfun('isempty', regexp(directory_content, '^File')));
dir_pos = find(~cellfun('isempty', regexp(directory_content, '^Directory')));

for n = 1: length(file_pos)
	file_number = sscanf(directory_content{file_pos(n)}, 'File%i');
	rows_to_be_used = (start_row + 1) : end_row_header;
	
	% horizontal entries
	range = ColumnNumbers_to_ExcelRange(sheet, rows_to_be_used, start_column + n - 1);
	range.Merge;
	range.Value = directory_structure.(directory_content{file_pos(n)});
	range.Orientation = 90;
	range.Font.Name = 'Arial';
	range.Border.Color = RGB_to_Excel_Color([0,0,0]);
	range.Borders.Item(9).Weight = 4;
	range.Interior.Color = RGB_to_Excel_Color(directory_name_color_level{directory_level});
	
	% vertical entries
	range = ColumnNumbers_to_ExcelRange(sheet, start_column + n - 1, rows_to_be_used);
	range.Merge;
	range.Value = directory_structure.(directory_content{file_pos(n)});
	range.HorizontalAlignment = 4;
	range.Font.Name = 'Arial';
	range.Border.Color = RGB_to_Excel_Color([0,0,0]);
	range.Borders.Item(10).Weight = 4;
	range.Interior.Color = RGB_to_Excel_Color(directory_name_color_level{directory_level});
	
	% collect all filenames
	filename_list = [filename_list, directory_structure.(directory_content{file_pos(n)})];
end

if length(file_pos) > 0
	% last filename should get right border
	range = ColumnNumbers_to_ExcelRange(sheet, start_row:end_row_table,  start_column + n - 1);
	range.Borders.Item(10).Color = RGB_to_Excel_Color([0,0,0]);
	range.Borders.Item(10).Weight = -4138;
	range = ColumnNumbers_to_ExcelRange(sheet,  start_column + n - 1, start_row:end_row_table);
	range.Borders.Item(9).Color = RGB_to_Excel_Color([0,0,0]);
	range.Borders.Item(9).Weight = -4138;
	
	% put borders to visualize blocks
	range = ColumnNumbers_to_ExcelRange(sheet, start_column + [0:length(file_pos)-1], start_column  + [0:length(file_pos)-1]);
	for n = 7:10
		range.Borders.Item(n).Color = RGB_to_Excel_Color([0,0,0]); % see    http://msdn.microsoft.com/en-us/library/office/ff835915.aspx
		range.Borders.Item(n).Weight = 4;
	end
	
	range.Interior.Color = RGB_to_Excel_Color(directory_name_color_level{directory_level});
% 		range.Interior.Color = RGB_to_Excel_Color([255, 229, 191]/255);
end

current_column = start_column + length(file_pos);
current_row = start_row + 1;
	
for n = 1: length(dir_pos)
	
 	inner_filename_list = Put_FileNames_to_Table(sheet, current_column, current_row, end_row_header, end_row_table, directory_level + 1, directory_structure.(directory_content{dir_pos(n)}));
	
	
	filename_list = [filename_list, inner_filename_list];
	
	current_column = current_column + directory_structure.(directory_content{dir_pos(n)}).Statistics_Num_Files_Below + directory_structure.(directory_content{dir_pos(n)}).Statistics_Num_Files_Current;
		
	
end



%% Create Excel range
function range = ColumnNumbers_to_ExcelRange(sheet, rows, columns)

rows = sort(rows);
columns = sort(columns);

% error checking
if isempty(rows) || (length(rows) > 1 && any(diff(rows)>1))
    error('Non-continuous rows provided')
end

if isempty(columns) || (length(columns) > 1 && any(diff(columns)>1))
    error('Non-continuous rows provided')
end

% get first an lat entry (minimum and maximum)
columns = columns([1, end]);
rows = rows([1, end]);

% translate to excel columns
char_list = [{' '}, cellstr(char([48:57,65:90])')'];
excel_col = arrayfun(@(x) cell2mat(char_list(cell2mat(cellfun(@(x) find(ismember(char_list, x)), cellstr(dec2base(x-1- sum(26.^[1:(ceil(log(25 * x + 26)/log(26) - 1)-1)]), 26, ceil(log(25 * x + 26)/log(26) - 1))'), 'UniformOutput', false))+10)), columns, 'UniformOutput', false);

% generate excel expression for the range
excel_range = sprintf('%s%i:%s%i', excel_col{1}, rows(1), excel_col{2}, rows(2));

range = get(sheet, 'Range', excel_range);

% #######################   SUBFUNCTION END   ############################

%% #######################    CALLBACK START   ############################


% #######################     CALLBACK END    ############################

