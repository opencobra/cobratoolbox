%% #######################     HEADER START    ############################
%*************************************************************************
%
% Filename:				Retrieve_Directory_Structure.m
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
%		Recursively analyze the directory structure and get all files according to defined file type(s).
% 
%
% Input parameter:
%		- root_dir:			Root directory from where to start the analysis
%		- file_types:		Cell array of file types to be take into account
%
% Output parameter:
%		- file_structure:	Structure containing information about all the files occuring
%		- num_files_below:  Number of files matching search expression within lower lying directories
%		- exclusion_list:	List of file names to be excluded
%
%*************************************************************************
%
% Intrinsic Subfunctions
%		- none
%
% Intrinsic Callbacks
%		- none
%
% #######################      HEADER END     ############################

%% #######################    FUNCTION START   ############################
function [directory_structure, num_files] = Retrieve_Directory_Structure(root_dir, file_types, exclusion_list)

%% Input Validation
% start with input checks

% Is the root_dir of type char and does the directory exist?
if ~ischar(root_dir) || ~exist(root_dir, 'dir')
	error('Input directory is not an existing directory!')
end

% Is filetype of type cell?
if ~iscell(file_types)
	% no? then make a cell out of it
	file_types = {file_types};
end

% Are all cell elements of type char?
if ~all(cellfun(@ischar, file_types))
	error('Invalid input for file types')
end

% Are all cell elements of the form '*....'?
if any(cellfun('isempty', regexp(file_types, '^\*\..+$')))
	error('File types should be of the form ''*.xyz''!')
end

%% PostProcess input parameters
% append '$' to identify files via regexp
file_types = cellfun(@(x) sprintf('%s$',x), file_types, 'UniformOutput', false);
file_types = regexprep(file_types, '\$*$', '\$');

%% Initialize
root_content = dir(root_dir);

max_num_found_files_string_length = ceil(log10(sum(~cell2mat({root_content.isdir})+1)));
max_num_found_subdirs_string_length = ceil(log10(sum(cell2mat({root_content.isdir})+1)));

num_found_files = 0;
num_found_subdirs = 0;
num_dir_level_below = 0;
num_files_below = 0;
num_files = 0;

directory_structure = struct();

%% Get directory content
for n = 1 : size(root_content)
	current_item = root_content(n);
		
	% Check for directory -> Recursion
	if current_item.isdir 
		
		if isempty(regexp(current_item.name, '^\.{1,2}$', 'once'))
			[directory_content, num_files_within] = Retrieve_Directory_Structure([root_dir,'\',current_item.name], file_types, exclusion_list);
			
			num_files_below = num_files_below + num_files_within;
			
			% Only append directories with found items
			if ~isempty(fieldnames(directory_content))
				
				num_dir_level_below = max([num_dir_level_below, directory_content.Statistics_Num_Dir_Level_Below + 1]);
				
				num_found_subdirs = num_found_subdirs + 1;
				
				structure_label = sprintf(['Directory%0',num2str(max_num_found_subdirs_string_length),'i'],num_found_subdirs);
			
				directory_structure.(structure_label) = directory_content;
				directory_structure.(structure_label).DirName = current_item.name;
		
				directory_structure.(structure_label) = orderfields(directory_structure.(structure_label));
			end
		end
		
	else
	
		% Check filetypes
		
		if ~ismember(current_item.name, exclusion_list)
			found_type_pos = find(~cellfun('isempty', regexp(current_item.name, regexprep(file_types, '^\*', '\'))),1);
			
			if any(strcmp(file_types, '*.*$')) || ~isempty(found_type_pos)
				num_found_files = num_found_files + 1;
				
				structure_label = sprintf(['File%0',num2str(max_num_found_files_string_length),'i'],num_found_files);
				
				directory_structure.(structure_label) = current_item.name;
				
			end
		end		
	end
	
end

num_files = num_files_below + num_found_files;

directory_structure = orderfields(directory_structure);
if num_found_subdirs  ~= 0 || num_found_files ~= 0
	directory_structure.Statistics_Num_Dirs = num_found_subdirs;
	directory_structure.Statistics_Num_Dir_Level_Below = num_dir_level_below;
	directory_structure.Statistics_Num_Files_Current = num_found_files;
	directory_structure.Statistics_Num_Files_Below = num_files_below;
	
	[~,directory_structure.DirName ] = fileparts(root_dir);
end


% #######################     FUNCTION END    ############################

%% #######################  SUBFUNCTION START  ############################


% #######################   SUBFUNCTION END   ############################

%% #######################    CALLBACK START   ############################


% #######################     CALLBACK END    ############################

