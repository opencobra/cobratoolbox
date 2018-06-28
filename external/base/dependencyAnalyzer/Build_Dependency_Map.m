%% #######################     HEADER START    ############################
%*************************************************************************
%
% Filename:				Build_Dependency_Map.m
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
%		Outer routine to build the dependency map for agiven directory with all subdirectories
% 
%
% Input parameter:
%		- root_dir:		Root directory for which the dependency map should be build
%		- varargin:		Optional arguments:
%				1:		List of filenames to be excluded
%
% Output parameter:
%		- none
%
%*************************************************************************
%
% Intrinsic Subfunctions
%		- Move_To_Temp:	Move files to temp directory
%
% Intrinsic Callbacks
%		- callback1
%
% #######################      HEADER END     ############################

%% #######################    FUNCTION START   ############################
function Build_Dependency_Map(root_dir, varargin)

%default_file_types = {'*.m','*.java', '*.mdl'};
default_file_types = {'*.m'}; %Ronan

%% Get the directory structure
if length(varargin) == 1
	exclusion_list = varargin{1};
else
	exclusion_list = {};
end
directory_structure = Retrieve_Directory_Structure(root_dir, default_file_types, exclusion_list);

%% Move all files within the directory structure to a temporary directory
temporary_dir = [tempdir, 'Dependency_Analyzer\']
if exist(temporary_dir, 'dir')
	rmdir(temporary_dir,'s')
end
mkdir(temporary_dir)
addpath(temporary_dir)

Copy_To_Temp(root_dir, directory_structure, temporary_dir)

%% Get list of filenames and extensions
dir_content = dir(temporary_dir);
[file_list{1:length(dir_content)}] = dir_content.name;
file_list = file_list(cellfun('isempty', regexp(file_list, '^\.{1,2}$'))); %remove '.' and '..' from list
extension_list = cell(1,length(file_list));


for n = 1:length(file_list)
	[~,file_list{n},extension_list{n}] = fileparts(file_list{n});
end

% Get the dependency report from MATLAB for each of the files

report_list = cell(length(file_list),1);
file_counter = 0;
old_numbering_string_length = 0;
usage_list = cell(1, length(file_list));

fprintf('\nAnalyzing file ')

for n = 1:length(file_list)
	filename = [temporary_dir, file_list{n}, extension_list{n}];
	
	
	if exist(filename, 'file') % to be on the save side
		file_counter = file_counter + 1;
		
		counting_string = sprintf('%i/%i: %s', n, length(file_list), filename);
		fprintf(1, [repmat('\b',1,old_numbering_string_length), '%s'],  counting_string)
		old_numbering_string_length = length(counting_string);
		
		% Get content of file and remove special cases
		fid = fopen(filename);
		file_content = textscan(fid, '%s', 'Delimiter', '\n');
		file_content = file_content{1};
		fclose(fid);
		
		file_content = file_content(cellfun('isempty', regexp(file_content, '^\ *%')));  % do not treat comments
		file_content = file_content(cellfun('isempty', regexp(file_content, '^\ *function')));  % do not treat function definitions (avoid self-referencing
		file_content = file_content(~cellfun('isempty', file_content));  % remove empty lines
		file_content = file_content(cellfun('isempty', regexp(file_content, '^\ *public class')));  % do not treat class definitions
		file_content = file_content(cellfun('isempty', regexp(file_content, '^\ *//')));  % do not treat java comments
		
		% Analyze dependencies
		usage_found = logical(zeros(1,length(file_list)));
		for m = 1:length(file_list)		
					
			file_name_positions_within_lines = regexp(file_content, [file_list{m},'[\''\ +-*\/\\\(\)\{\}\[\];,\.\&\|]']);
			lines_with_found_names = find(~cellfun('isempty', file_name_positions_within_lines));
			
			if isempty(lines_with_found_names)
				usage_found(m) = 0;
			else
				% possible dependency found - deeper analysis
				found_lines = file_content(lines_with_found_names);
				file_name_positions_within_lines = file_name_positions_within_lines(lines_with_found_names);
				
				
				
				% check for filenames occuring within inline comments
				for k = 1:length(found_lines)
					
					% get list of positions of various cases
					current_line = found_lines{k};
					quotations_marks_pos = regexp(found_lines{k},'''');
					percent_sign_pos = regexp(found_lines{k}, '%');
					
					% if there is no inline comment, its a hit
					if isempty(percent_sign_pos)
						usage_found(m) = 1;
						break
					end
					
					% there are no quation marks thus its quiet easy: just look for comments
					if isempty(quotations_marks_pos)
						if file_name_positions_within_lines{k} < percent_sign_pos(1)
							usage_found(m) = 1;
							break
						end
					else
						% this one is more tricky:
						
						% check if comment signs occurs within a string
						number_of_quotation_marks_before = cumsum(ismember(sort([percent_sign_pos, quotations_marks_pos]), quotations_marks_pos));
						usage_found(m) = any(mod(number_of_quotation_marks_before(ismember(sort([percent_sign_pos, quotations_marks_pos]), percent_sign_pos)),2)== 0);
						break
					end
					
				end				
			
			
			end
		end
		
		usage_list{n} = usage_found;

		full_file_name_list{n} = [file_list{n}, extension_list{n}];
		
	end
end
fprintf(1,'\n\n')

%% Generate dependency report
Write_Dependency_Report(directory_structure, full_file_name_list, usage_list)

%% Clean up
rmdir(temporary_dir,'s')


% #######################     FUNCTION END    ############################

%% #######################  SUBFUNCTION START  ############################
function Copy_To_Temp(root_dir, directory_structure, temporary_dir)

directory_content = fieldnames(directory_structure);

file_pos = find(~cellfun('isempty', regexp(directory_content, '^File')));
dir_pos = find(~cellfun('isempty', regexp(directory_content, '^Directory')));

for n = 1: length(file_pos)

	file_name = [root_dir, '\', directory_structure.(directory_content{file_pos(n)})];

	
	if exist(file_name)
		[status, message, messageid] = copyfile(file_name, temporary_dir);
	else
		error(['Somethings wrong with file: ', filename])
	end
	
	
end
	
for n = 1: length(dir_pos)

 	Copy_To_Temp([root_dir,'\', directory_structure.(directory_content{dir_pos(n)}).DirName], directory_structure.(directory_content{dir_pos(n)}), temporary_dir)
	
end

% #######################   SUBFUNCTION END   ############################

%% #######################    CALLBACK START   ############################


% #######################     CALLBACK END    ############################

